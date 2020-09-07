#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdbool.h>
#include <mysql_time.h>

#include "controller.h"
#include "logger.h"

#define MAX_LENGTH 1024

struct op {
    const char* name;
    const char* params;
    const char* stmt;
};

static const char* db_name = "directory_aziendale";
static const char* host_name = "localhost";
static struct op operations[NUM_OPS];
static char *opStrings[NUM_OPS];

void initController(){
    // populates opStrings with literal form of opCode
    opStrings[op1] = "op1";
    opStrings[op2_1] = "op2_1";
    opStrings[op2_2] = "op2_2";
    opStrings[op3_1] = "op3_1";
    opStrings[op3_2] = "op3_2";
    opStrings[op4] = "op4";
    opStrings[op5] = "op5";
    opStrings[op6] = "op6";
    opStrings[op7] = "op7";
    opStrings[op9] = "op9";

    // Populates structures in operations with data for each op. (TODO: data should be read from a file)
    operations[op1].name = "generaReportDaTrasferire";
    operations[op1].params = "";
    operations[op1].stmt = "call generaReportDaTrasferire()";

    operations[op2_1].name = "trovaDipendentiScambiabili";
    operations[op2_1].params = "cfDipendente";
    operations[op2_1].stmt = "call trovaDipendentiScambiabili(?)";

    operations[op2_2].name = "scambiaDipendenti";
    operations[op2_2].params = "cfDipendente1, cfDipendente2";
    operations[op2_2].stmt = "call scambiaDipendenti(?, ?)";

    operations[op3_1].name = "trovaUfficiConPostazioneVuota";
    operations[op3_1].params = "nomeMansione, nomeSettore";
    operations[op3_1].stmt = "call trovaUfficiConPostazioneVuota(?, ?)";

    operations[op3_2].name = "assegnaDipendenteAPostazioneVuota";
    operations[op3_2].params = "cfDipendente, numTelefonicoEsternoPostazioneVuota";
    operations[op3_2].stmt = "call assegnaDipendenteAPostazioneVuota(?, ?)";

    operations[op4].name = "cambiaMansioneDipendente";
    operations[op4].params = "cfDipendente, nomeNuovaMansione, nomeNuovoSettore";
    operations[op4].stmt = "call cambiaMansioneDipendente(?, ?, ?)";

    operations[op5].name = "elencaTrasferimentiDipendente";
    operations[op5].params = "cfDipendente";
    operations[op5].stmt = "call elencaTrasferimentiDipendente(?)";

    operations[op6].name = "ricercaDipendente";
    operations[op6].params = "nome, cognome";
    operations[op6].stmt = "call ricercaDipendente(?, ?)";

    operations[op7].name = "ricercaPerNumeroTelefono";
    operations[op7].params = "numTelefonoEsterno";
    operations[op7].stmt = "call ricercaPerNumeroTelefono(?)";

    operations[op9].name = "assumiDipendente";
    operations[op9].params = "cf, nome, cognome, luogoNascita, dataNascita, emailPersonale, indirizzoResidenza, nomeMansione, nomeSettore";
    operations[op9].stmt = "call assumiDipendente(?, ?, ?, ?, ?, ?, ?, ?, ?)";

}

int prepareOp(MYSQL *conn, enum opCode op, MYSQL_STMT **stmtAddr){
    // init stmt
    if ((*stmtAddr = mysql_stmt_init(conn)) == NULL){
        logMsg(E, "mysql_stmt_init: %s\n", mysql_error(conn));
        return 1;
    }
    // prepares stmt
    MYSQL_STMT *stmt = *stmtAddr;
    if (mysql_stmt_prepare(stmt, operations[op].stmt, strlen(operations[op].stmt)) != 0){
        logMsg(E, "mysql_stmt_prepare: %s\n", mysql_stmt_error(stmt));
        return 1;
    }
    return 0;
}

int launchOp(MYSQL *conn, MYSQL_STMT *stmt, MYSQL_BIND *inParams){
    // bind params
    if (inParams != NULL && mysql_stmt_bind_param(stmt, inParams)){
        logMsg(E, "mysql_stmt_bind_param: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // execute statement
    if (mysql_stmt_execute(stmt)){
        logMsg(D, "%s\n", mysql_sqlstate(conn));
        logMsg(E, "mysql_stmt_execute: %s\n", mysql_stmt_error(stmt));
        return 1;
    }
    // buffers result set
    if (mysql_stmt_store_result(stmt) != 0){
        logMsg(E, "mysql_stmt_store_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }
    return 0;
}

int prepareAndLaunchOp(MYSQL *conn, enum opCode op, MYSQL_BIND *inParams, MYSQL_STMT **stmtAddr){
    // prepares stmt
    if (prepareOp(conn, op, stmtAddr)){
        logMsg(E, "failed to prepare statement\n");
        return 1;
    }
    MYSQL_STMT *stmt = *stmtAddr;
    // launches op
    if (launchOp(conn, stmt, inParams)){
        logMsg(E, "failed to launch statement\n");
        return 1;
    }
    return 0;
}

int printRes(MYSQL_STMT* stmt, MYSQL_RES *metaRes, MYSQL_BIND *resultSetCols){
    mysql_field_seek(metaRes, 0);
    int resNumCol = mysql_num_fields(metaRes);
    int width[resNumCol], res;
    logMsg(I, "r)   ");
    for (int c = 0; c < resNumCol; c ++){
        printf("%s%n | ", mysql_fetch_field(metaRes) -> name, width + c);
    }
    printf("\n");
    fflush(stdout);
    for (int r = 0; ; r ++){
        if ((res = mysql_stmt_fetch(stmt)) == MYSQL_NO_DATA){
            break;
        }
        switch(res) {
            case 1:
                logMsg(E, "mysql_stmt_fetch: %d\n", mysql_stmt_error(stmt));
                return 1;
            case MYSQL_DATA_TRUNCATED:
                logMsg(W, "data truncation occurred\n", r);
            case 0:
                break;
        }
        logMsg(I, "%d) ", r);
        for (int c = 0; c < resNumCol; c ++){
            switch((resultSetCols + c) -> buffer_type){
            case MYSQL_TYPE_STRING:
            case MYSQL_TYPE_VAR_STRING:
            case MYSQL_TYPE_NEWDECIMAL:
                printf("%*s | ", width[c], (*((bool *) ((resultSetCols + c) -> is_null)))? "NULL" : (char *) resultSetCols[c].buffer);
                break;
            case MYSQL_TYPE_TINY:
            case MYSQL_TYPE_SHORT:
            case MYSQL_TYPE_INT24:
            case MYSQL_TYPE_LONG:
            case MYSQL_TYPE_LONGLONG:
                if (*((bool *) ((resultSetCols + c) -> is_null))){
                    printf("%*s | ", width[c], "NULL");
                }
                else {
                    printf("%*d | ", width[c], *((int *)(resultSetCols[c].buffer)));
                }
                break;
            case MYSQL_TYPE_FLOAT:
            case MYSQL_TYPE_DOUBLE:
                if (*((bool *) ((resultSetCols + c) -> is_null))){
                    printf("%*s | ", width[c], "NULL");
                }
                else {
                    printf("%*f | ", width[c], *((double *)(resultSetCols[c].buffer)));
                }
                break;
            case MYSQL_TYPE_DATE:
                if (*((bool *) ((resultSetCols + c) -> is_null))){
                    printf("%s/ ", "NULL");
                }
                else {
                    printf("%d/%d/%d | ",
                        ((MYSQL_TIME *)(resultSetCols[c].buffer)) -> day,
                        ((MYSQL_TIME *)(resultSetCols[c].buffer)) -> month,
                        ((MYSQL_TIME *)(resultSetCols[c].buffer)) -> year
                    );
                }
                break;
            default:
                printf("(not supported) | ");
            }
        }
        printf("\n");
    }
    fflush(stdout);

    return 0;
}

void freeResultSet(MYSQL_BIND *resultSetCols, int resNumCol){
   for (int i = 0; i < resNumCol; i ++){
        free(resultSetCols[i].buffer);
        free(resultSetCols[i].length);
        free(resultSetCols[i].is_null);
        free(resultSetCols[i].error);
    }
    free(resultSetCols);
}

MYSQL_BIND *callocResultSetCols(MYSQL_RES *metaRes){
    int resNumCol = mysql_num_fields(metaRes);
    MYSQL_BIND *resultSetCols = calloc(resNumCol, sizeof(MYSQL_BIND));
    MYSQL_FIELD *currentField;

    mysql_field_seek(metaRes, 0);
    for (int i = 0; i < resNumCol; i ++){
    currentField = mysql_fetch_field(metaRes);
    resultSetCols[i].buffer_type = currentField -> type;
    resultSetCols[i].buffer = calloc(MAX_LENGTH, sizeof(char));
    resultSetCols[i].buffer_length  = MAX_LENGTH;
    resultSetCols[i].length = (unsigned long*) calloc(1, sizeof(unsigned long));
    resultSetCols[i].is_null = (bool *) calloc(1, sizeof(bool));
    resultSetCols[i].error = (bool *) calloc(1, sizeof(bool));
    }
    return resultSetCols;
}

int bindRes(MYSQL_STMT *stmt, MYSQL_BIND **resultSetColsAddr, MYSQL_RES **metaResAddr){
    MYSQL_RES *metaRes;
    MYSQL_BIND *resultSetCols;
    int resNumCol;
    int numRes = 0;
    if ((*metaResAddr = mysql_stmt_result_metadata(stmt)) == NULL){
            logMsg(E, "mysql_stmt_result_metadata: %s\n", mysql_stmt_error(stmt));
            return -1;
    }
    metaRes = *metaResAddr;
    resNumCol = mysql_num_fields(metaRes);
    if (resNumCol > 0){
        numRes ++;
        // binds result set dinamically
        *resultSetColsAddr = callocResultSetCols(metaRes);
        resultSetCols = *resultSetColsAddr;
        if (mysql_stmt_bind_result(stmt, resultSetCols)){
            logMsg(E, "mysql_stmt_bind_result: %s\n", mysql_stmt_error(stmt));
            return -1;
        }
    }
    return numRes;
}

int callOp1(MYSQL *conn){
    MYSQL_STMT *stmt;
    MYSQL_BIND *resSet;
    MYSQL_RES *metaRes;
    int hasNext;

    // prepare and launches stmt
    if (prepareAndLaunchOp(conn, op1, NULL, &stmt)){
        logMsg(E, "failed to prepare and launch statement\n");
        return 1;
    }

    // binds res set
    if (bindRes(stmt, &resSet, &metaRes) <= 0){
        logMsg(W, "Either failed to bind a result set or no result set was available to bind\n");
    }

    // prints res set;
    if (printRes(stmt, metaRes, resSet)){
        logMsg(E, "Error while printing results\n");
        return 1;
    }

    // discards remaining result sets
    do {mysql_stmt_free_result(stmt);} while ((hasNext = mysql_stmt_next_result(stmt) == 0));
    if (hasNext > 0){
        logMsg(E, "mysql_stmt_next_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // frees memory allocated dinamically
    freeResultSet(resSet, mysql_num_fields(metaRes));
    mysql_free_result(metaRes);
    if (mysql_stmt_close(stmt) != 0){
        logMsg(E, "mysql_stmt_close: %s\n", mysql_error(conn));
        return 1;
    }

    return 0;
}

int callOp2_1(MYSQL *conn, int numOfArgs, char *cfDipendente){
    MYSQL_STMT *stmt;
    MYSQL_BIND *resSet;
    MYSQL_BIND *inParams = calloc(numOfArgs, sizeof(MYSQL_BIND));
    MYSQL_RES *metaRes;
    int hasNext;
    unsigned long len[numOfArgs];
    bool isNull[numOfArgs];

    // prepares params

    memset(isNull, false, sizeof(bool) * numOfArgs);

    if (cfDipendente == NULL || !strcmp(cfDipendente, ARG_NULL)){
        cfDipendente = "";
        isNull[0] = true;
        inParams -> is_null = isNull;
    }
    len[0] = sizeof(char) * strlen(cfDipendente);
    inParams -> buffer_type = MYSQL_TYPE_STRING;
    inParams -> buffer = cfDipendente;
    inParams -> buffer_length = len[0];
    inParams -> length = len;

    // prepare and launches stmt
    if (prepareAndLaunchOp(conn, op2_1, inParams, &stmt)){
        logMsg(E, "failed to prepare and launch statement\n");
        return 1;
    }

    // binds res set
    if (bindRes(stmt, &resSet, &metaRes) <= 0){
        logMsg(W, "Either failed to bind a result set or no result set was available to bind\n");
    }

    // prints res set;
    if (printRes(stmt, metaRes, resSet)){
        logMsg(E, "Error while printing results\n");
        return 1;
    }
    // discards remaining result sets
    do {mysql_stmt_free_result(stmt);} while ((hasNext = mysql_stmt_next_result(stmt) == 0));
    if (hasNext > 0){
        logMsg(E, "mysql_stmt_next_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // frees memory allocated dinamically
    free(inParams);
    freeResultSet(resSet, mysql_num_fields(metaRes));
    mysql_free_result(metaRes);
    if (mysql_stmt_close(stmt) != 0){
        logMsg(E, "mysql_stmt_close: %s\n", mysql_error(conn));
        return 1;
    }

    return 0;
}

int callOp2_2(MYSQL *conn, int numOfArgs, char *cfDipendente1, char *cfDipendente2){
    MYSQL_STMT *stmt;
    MYSQL_BIND *inParams = calloc(numOfArgs, sizeof(MYSQL_BIND));
    int hasNext;
    unsigned long len[numOfArgs];
    bool isNull[numOfArgs];

    // prepares params

    memset(isNull, false, sizeof(bool) * numOfArgs);

    if (cfDipendente1 == NULL || !strcmp(cfDipendente1, ARG_NULL)){
        cfDipendente1 = "";
        isNull[0] = true;
        inParams -> is_null = isNull;
    }
    len[0] = sizeof(char) * strlen(cfDipendente1);
    inParams -> buffer_type = MYSQL_TYPE_STRING;
    inParams -> buffer = cfDipendente1;
    inParams -> buffer_length = len[0];
    inParams -> length = len;

    if (cfDipendente2 == NULL || !strcmp(cfDipendente2, ARG_NULL)){
        cfDipendente2 = "";
        isNull[1] = true;
        (inParams + 1) -> is_null = isNull + 1;
    }
    len[1] = sizeof(char) * strlen(cfDipendente2);
    (inParams + 1) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 1) -> buffer = cfDipendente2;
    (inParams+ 1) -> buffer_length = len[1];
    (inParams + 1) -> length = len + 1;

    // prepare and launches stmt
    if (prepareAndLaunchOp(conn, op2_2, inParams, &stmt)){
        logMsg(E, "failed to prepare and launch statement\n");
        return 1;
    }

    // no res set has to be printed

    // discards remaining result sets
    do {mysql_stmt_free_result(stmt);} while ((hasNext = mysql_stmt_next_result(stmt) == 0));
    if (hasNext > 0){
        logMsg(E, "mysql_stmt_next_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // frees memory allocated dinamically
    free(inParams);
    if (mysql_stmt_close(stmt) != 0){
        logMsg(E, "mysql_stmt_close: %s\n", mysql_error(conn));
        return 1;
    }

    return 0;
}

int callOp3_1(MYSQL *conn, int numOfArgs, char *nomeMansione, char *nomeSettore){
    MYSQL_STMT *stmt;
    MYSQL_BIND *resSet;
    MYSQL_BIND *inParams = calloc(numOfArgs, sizeof(MYSQL_BIND));
    MYSQL_RES *metaRes;
    int hasNext;
    unsigned long len[numOfArgs];
    bool isNull[numOfArgs];

    // prepares params

    memset(isNull, false, sizeof(bool) * numOfArgs);

    if (nomeMansione == NULL || !strcmp(nomeMansione, ARG_NULL)){
        nomeMansione = "";
        isNull[0] = true;
        inParams -> is_null = isNull;
    }
    len[0] = sizeof(char) * strlen(nomeMansione);
    inParams -> buffer_type = MYSQL_TYPE_STRING;
    inParams -> buffer = nomeMansione;
    inParams -> buffer_length = len[0];
    inParams -> length = len;

    if (nomeSettore == NULL || !strcmp(nomeSettore, ARG_NULL)){
        nomeSettore = "";
        isNull[1] = true;
        (inParams + 1) -> is_null = isNull + 1;
    }
    len[1] = sizeof(char) * strlen(nomeSettore);
    (inParams + 1) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 1) -> buffer = nomeSettore;
    (inParams+ 1) -> buffer_length = len[1];
    (inParams + 1) -> length = len + 1;

    // prepare and launches stmt
    if (prepareAndLaunchOp(conn, op3_1, inParams, &stmt)){
        logMsg(E, "failed to prepare and launch statement\n");
        return 1;
    }

    // binds res set
    if (bindRes(stmt, &resSet, &metaRes) <= 0){
        logMsg(W, "Either failed to bind a result set or no result set was available to bind\n");
    }

    // prints res set;
    if (printRes(stmt, metaRes, resSet)){
        logMsg(E, "Error while printing results\n");
        return 1;
    }

    // discards remaining result sets
    do {mysql_stmt_free_result(stmt);} while ((hasNext = mysql_stmt_next_result(stmt) == 0));
    if (hasNext > 0){
        logMsg(E, "mysql_stmt_next_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // frees memory allocated dinamically
    free(inParams);
    freeResultSet(resSet, mysql_num_fields(metaRes));
    mysql_free_result(metaRes);
    if (mysql_stmt_close(stmt) != 0){
        logMsg(E, "mysql_stmt_close: %s\n", mysql_error(conn));
        return 1;
    }

    return 0;
}

int callOp3_2(MYSQL *conn, int numOfArgs, char *cfDipendente, char *numTelefonicoEsternoPostazione){
    MYSQL_STMT *stmt;
    MYSQL_BIND *resSet;
    MYSQL_BIND *inParams = calloc(numOfArgs, sizeof(MYSQL_BIND));
    MYSQL_RES *metaRes;
    int hasNext;
    unsigned long len[numOfArgs];
    bool isNull[numOfArgs];

    // prepares params

    memset(isNull, false, sizeof(bool) * numOfArgs);

    if (cfDipendente == NULL || !strcmp(cfDipendente, ARG_NULL)){
        cfDipendente = "";
        isNull[0] = true;
        inParams -> is_null = isNull;
    }
    len[0] = sizeof(char) * strlen(cfDipendente);
    inParams -> buffer_type = MYSQL_TYPE_STRING;
    inParams -> buffer = cfDipendente;
    inParams -> buffer_length = len[0];
    inParams -> length = len;

    if (numTelefonicoEsternoPostazione == NULL || !strcmp(numTelefonicoEsternoPostazione, ARG_NULL)){
        numTelefonicoEsternoPostazione = "";
        isNull[1] = true;
        (inParams + 1) -> is_null = isNull + 1;
    }
    len[1] = sizeof(char) * strlen(numTelefonicoEsternoPostazione);
    (inParams + 1) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 1) -> buffer = numTelefonicoEsternoPostazione;
    (inParams+ 1) -> buffer_length = len[1];
    (inParams + 1) -> length = len + 1;

    // prepare and launches stmt
    if (prepareAndLaunchOp(conn, op3_2, inParams, &stmt)){
        logMsg(E, "failed to prepare and launch statement\n");
        return 1;
    }

    // binds res set
    if (bindRes(stmt, &resSet, &metaRes) <= 0){
        logMsg(W, "Either failed to bind a result set or no result set was available to bind\n");
    }

    // discards remaining result sets
    do {mysql_stmt_free_result(stmt);} while ((hasNext = mysql_stmt_next_result(stmt) == 0));
    if (hasNext > 0){
        logMsg(E, "mysql_stmt_next_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // frees memory allocated dinamically
    free(inParams);
    freeResultSet(resSet, mysql_num_fields(metaRes));
    mysql_free_result(metaRes);
    if (mysql_stmt_close(stmt) != 0){
        logMsg(E, "mysql_stmt_close: %s\n", mysql_error(conn));
        return 1;
    }

    return 0;
}

int callOp4(MYSQL *conn, int numOfArgs, char *cfDipendente, char *nomeNuovaMansione, char* nomeNuovoSettore){
    MYSQL_STMT *stmt;
    MYSQL_BIND *inParams = calloc(numOfArgs, sizeof(MYSQL_BIND));
    int hasNext;
    unsigned long len[numOfArgs];
    bool isNull[numOfArgs];

    // prepares params

    memset(isNull, false, sizeof(bool) * numOfArgs);

    if (cfDipendente == NULL || !strcmp(cfDipendente, ARG_NULL)){
        cfDipendente = "";
        isNull[0] = true;
        inParams -> is_null = isNull;
    }
    len[0] = sizeof(char) * strlen(cfDipendente);
    inParams -> buffer_type = MYSQL_TYPE_STRING;
    inParams -> buffer = cfDipendente;
    inParams -> buffer_length = len[0];
    inParams -> length = len;

    if (nomeNuovaMansione == NULL || !strcmp(nomeNuovaMansione, ARG_NULL)){
        nomeNuovaMansione = "";
        isNull[1] = true;
        (inParams + 1) -> is_null = isNull + 1;
    }
    len[1] = sizeof(char) * strlen(nomeNuovaMansione);
    (inParams + 1) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 1) -> buffer = nomeNuovaMansione;
    (inParams+ 1) -> buffer_length = len[1];
    (inParams + 1) -> length = len + 1;

    if (nomeNuovoSettore == NULL || !strcmp(nomeNuovoSettore, ARG_NULL)){
        nomeNuovoSettore = "";
        isNull[1] = true;
        (inParams + 2) -> is_null = isNull + 2;
    }
    len[2] = sizeof(char) * strlen(nomeNuovoSettore);
    (inParams + 2) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 2) -> buffer = nomeNuovoSettore;
    (inParams+ 2) -> buffer_length = len[2];
    (inParams + 2) -> length = len + 2;

    // prepare and launches stmt
    if (prepareAndLaunchOp(conn, op4, inParams, &stmt)){
        logMsg(E, "failed to prepare and launch statement\n");
        return 1;
    }

    // discards remaining result sets
    do {mysql_stmt_free_result(stmt);} while ((hasNext = mysql_stmt_next_result(stmt) == 0));
    if (hasNext > 0){
        logMsg(E, "mysql_stmt_next_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // frees memory allocated dinamically
    free(inParams);
    if (mysql_stmt_close(stmt) != 0){
        logMsg(E, "mysql_stmt_close: %s\n", mysql_error(conn));
        return 1;
    }

    return 0;
}

int callOp5(MYSQL *conn, int numOfArgs, char *cfDipendente){
    MYSQL_STMT *stmt;
    MYSQL_BIND *resSet;
    MYSQL_BIND *inParams = calloc(numOfArgs, sizeof(MYSQL_BIND));
    MYSQL_RES *metaRes;
    int hasNext;
    unsigned long len[numOfArgs];
    bool isNull[numOfArgs];

    // prepares params

    memset(isNull, false, sizeof(bool) * numOfArgs);

    if (cfDipendente == NULL || !strcmp(cfDipendente, ARG_NULL)){
        cfDipendente = "";
        isNull[0] = true;
        inParams -> is_null = isNull;
    }
    len[0] = sizeof(char) * strlen(cfDipendente);
    inParams -> buffer_type = MYSQL_TYPE_STRING;
    inParams -> buffer = cfDipendente;
    inParams -> buffer_length = len[0];
    inParams -> length = len;

    // prepare and launches stmt
    if (prepareAndLaunchOp(conn, op5, inParams, &stmt)){
        logMsg(E, "failed to prepare and launch statement\n");
        return 1;
    }


    // binds res set
    if (bindRes(stmt, &resSet, &metaRes) <= 0){
        logMsg(W, "Either failed to bind a result set or no result set was available to bind\n");
    }

    // prints res set;
    if (printRes(stmt, metaRes, resSet)){
        logMsg(E, "Error while printing results\n");
        return 1;
    }
    // discards remaining result sets
    do {mysql_stmt_free_result(stmt);} while ((hasNext = mysql_stmt_next_result(stmt) == 0));
    if (hasNext > 0){
        logMsg(E, "mysql_stmt_next_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // frees memory allocated dinamically
    free(inParams);
    freeResultSet(resSet, mysql_num_fields(metaRes));
    mysql_free_result(metaRes);
    if (mysql_stmt_close(stmt) != 0){
        logMsg(E, "mysql_stmt_close: %s\n", mysql_error(conn));
        return 1;
    }

    return 0;
}

int callOp6(MYSQL *conn, int numOfArgs, char *nome, char* cognome){
    MYSQL_STMT *stmt;
    MYSQL_BIND *resSet;
    MYSQL_BIND *inParams = calloc(numOfArgs, sizeof(MYSQL_BIND));
    MYSQL_RES *metaRes;
    int hasNext;
    unsigned long len[numOfArgs];
    bool isNull[numOfArgs];

    logMsg(D, "args are: %s, %s\n", nome, cognome);

    // prepares params

    memset(isNull, false, sizeof(bool) * numOfArgs);

    if (nome == NULL || !strcmp(nome, ARG_NULL)){
        nome = "";
        isNull[0] = true;
        inParams -> is_null = isNull;
    }
    len[0] = sizeof(char) * strlen(nome);
    inParams -> buffer_type = MYSQL_TYPE_STRING;
    inParams -> buffer = nome;
    inParams -> buffer_length = len[0];
    inParams -> length = len;
    logMsg(D, "buffer is: %s\n", inParams -> buffer);

    if (cognome == NULL || !strcmp(cognome, ARG_NULL)){
        cognome = "";
        isNull[1] = true;
        (inParams + 1) -> is_null = isNull + 1;
    }
    len[1] = sizeof(char) * strlen(cognome);
    (inParams + 1) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 1) -> buffer = cognome;
    (inParams+ 1) -> buffer_length = len[1];
    (inParams + 1) -> length = len + 1;
    logMsg(D, "buffer is: %s, %d\n", (inParams + 1) -> buffer);

    // prepare and launches stmt
    if (prepareAndLaunchOp(conn, op6, inParams, &stmt)){
        logMsg(E, "failed to prepare and launch statement\n");
        return 1;
    }

    // binds res set
    if (bindRes(stmt, &resSet, &metaRes) <= 0){
        logMsg(W, "Either failed to bind a result set or no result set was available to bind\n");
    }

    // prints res set;
    if (printRes(stmt, metaRes, resSet)){
        logMsg(E, "Error while printing results\n");
        return 1;
    }
    // discards remaining result sets
    do {mysql_stmt_free_result(stmt);} while ((hasNext = mysql_stmt_next_result(stmt) == 0));
    if (hasNext > 0){
        logMsg(E, "mysql_stmt_next_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // frees memory allocated dinamically
    free(inParams);
    freeResultSet(resSet, mysql_num_fields(metaRes));
    mysql_free_result(metaRes);
    if (mysql_stmt_close(stmt) != 0){
        logMsg(E, "mysql_stmt_close: %s\n", mysql_error(conn));
        return 1;
    }

    return 0;
}

int callOp7(MYSQL *conn, int numOfArgs, char *numTelefonoEsterno){
    MYSQL_STMT *stmt;
    MYSQL_BIND *resSet;
    MYSQL_BIND *inParams = calloc(numOfArgs, sizeof(MYSQL_BIND));
    MYSQL_RES *metaRes;
    int hasNext;
    unsigned long len[numOfArgs];
    bool isNull[numOfArgs];

    // prepares params

    memset(isNull, false, sizeof(bool) * numOfArgs);

    if (numTelefonoEsterno == NULL || !strcmp(numTelefonoEsterno, ARG_NULL)){
        numTelefonoEsterno = "";
        isNull[0] = true;
        inParams -> is_null = isNull;
    }
    len[0] = sizeof(char) * strlen(numTelefonoEsterno);
    inParams -> buffer_type = MYSQL_TYPE_STRING;
    inParams -> buffer = numTelefonoEsterno;
    inParams -> buffer_length = len[0];
    inParams -> length = len;

    // prepare and launches stmt
    if (prepareAndLaunchOp(conn, op7, inParams, &stmt)){
        logMsg(E, "failed to prepare and launch statement\n");
        return 1;
    }

    // binds res set
    if (bindRes(stmt, &resSet, &metaRes) <= 0){
        logMsg(W, "Either failed to bind a result set or no result set was available to bind\n");
    }

    // prints res set;
    if (printRes(stmt, metaRes, resSet)){
        logMsg(E, "Error while printing results\n");
        return 1;
    }
    // discards remaining result sets
    do {mysql_stmt_free_result(stmt);} while ((hasNext = mysql_stmt_next_result(stmt) == 0));
    if (hasNext > 0){
        logMsg(E, "mysql_stmt_next_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // frees memory allocated dinamically
    free(inParams);
    freeResultSet(resSet, mysql_num_fields(metaRes));
    mysql_free_result(metaRes);
    if (mysql_stmt_close(stmt) != 0){
        logMsg(E, "mysql_stmt_close: %s\n", mysql_error(conn));
        return 1;
    }

    return 0;
}

int callOp9(MYSQL *conn, int numOfArgs, char *cf, char *nome, char *cognome, char *luogoNascita, MYSQL_TIME *dataNascita, char *emailPersonale, char *indirizzoResidenza, char *nomeMansione, char *nomeSettore){
    MYSQL_STMT *stmt;
    MYSQL_BIND *inParams = calloc(numOfArgs, sizeof(MYSQL_BIND));
    int hasNext;
    unsigned long len[numOfArgs];
    bool isNull[numOfArgs];

    // prepares params

    memset(isNull, false, sizeof(bool) * numOfArgs);

    if (cf == NULL || !strcmp(cf, ARG_NULL)){
        cf = "";
        isNull[0] = true;
        inParams -> is_null = isNull;
    }
    len[0] = sizeof(char) * strlen(cf);
    inParams -> buffer_type = MYSQL_TYPE_STRING;
    inParams -> buffer = cf;
    inParams -> buffer_length = len[0];
    inParams -> length = len;

    if (nome == NULL || !strcmp(nome, ARG_NULL)){
        nome = "";
        isNull[1] = true;
        inParams -> is_null = isNull + 1;
    }
    len[1] = sizeof(char) * strlen(nome);
    (inParams + 1) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 1) -> buffer = nome;
    (inParams + 1) -> buffer_length = len[1];
    (inParams + 1) -> length = len + 1;

    if (cognome == NULL || !strcmp(cognome, ARG_NULL)){
        cognome = "";
        isNull[2] = true;
        inParams -> is_null = isNull + 2;
    }
    len[2] = sizeof(char) * strlen(cognome);
    (inParams + 2) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 2) -> buffer = cognome;
    (inParams + 2) -> buffer_length = len[2];
    (inParams + 2) -> length = len + 2;

    if (luogoNascita == NULL || !strcmp(luogoNascita, ARG_NULL)){
        luogoNascita = "";
        isNull[3] = true;
        inParams -> is_null = isNull + 3;
    }
    len[3] = sizeof(char) * strlen(luogoNascita);
    (inParams + 3) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 3) -> buffer = luogoNascita;
    (inParams + 3) -> buffer_length = len[3];
    (inParams + 3) -> length = len + 3;

    if (dataNascita == NULL){
        isNull[4] = true;
        inParams -> is_null = isNull + 4;
    }
    len[4] = 0;
    (inParams + 4) -> buffer_type = MYSQL_TYPE_DATE;
    (inParams + 4) -> buffer = dataNascita;
    (inParams + 4) -> buffer_length = len[4];
    (inParams + 4) -> length = len + 4;

    if (emailPersonale == NULL || !strcmp(emailPersonale, ARG_NULL)){
        emailPersonale = "";
        isNull[5] = true;
        inParams -> is_null = isNull + 5;
    }
    len[5] = sizeof(char) * strlen(emailPersonale);
    (inParams + 5) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 5) -> buffer = emailPersonale;
    (inParams + 5) -> buffer_length = len[5];
    (inParams + 5) -> length = len + 5;

    if (indirizzoResidenza == NULL || !strcmp(indirizzoResidenza, ARG_NULL)){
        indirizzoResidenza = "";
        isNull[6] = true;
        inParams -> is_null = isNull + 6;
    }
    len[6] = sizeof(char) * strlen(indirizzoResidenza);
    (inParams + 6) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 6) -> buffer = indirizzoResidenza;
    (inParams + 6) -> buffer_length = len[6];
    (inParams + 6) -> length = len + 6;

    if (nomeMansione == NULL || !strcmp(nomeMansione, ARG_NULL)){
        nomeMansione = "";
        isNull[7] = true;
        inParams -> is_null = isNull + 7;
    }
    len[7] = sizeof(char) * strlen(nomeMansione);
    (inParams + 7) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 7) -> buffer = nomeMansione;
    (inParams + 7) -> buffer_length = len[7];
    (inParams + 7) -> length = len + 7;

    if (nomeSettore == NULL || !strcmp(nomeSettore, ARG_NULL)){
        nomeSettore = "";
        isNull[8] = true;
        inParams -> is_null = isNull + 8;
    }
    len[8] = sizeof(char) * strlen(nomeSettore);
    (inParams + 8) -> buffer_type = MYSQL_TYPE_STRING;
    (inParams + 8) -> buffer = nomeSettore;
    (inParams + 8) -> buffer_length = len[8];
    (inParams + 8) -> length = len + 8;

    // prepare and launches stmt
    if (prepareAndLaunchOp(conn, op9, inParams, &stmt)){
        logMsg(E, "failed to prepare and launch statement\n");
        return 1;
    }

    // discards remaining result sets
    do {mysql_stmt_free_result(stmt);} while ((hasNext = mysql_stmt_next_result(stmt) == 0));
    if (hasNext > 0){
        logMsg(E, "mysql_stmt_next_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // frees memory allocated dinamically
    free(inParams);
    if (mysql_stmt_close(stmt) != 0){
        logMsg(E, "mysql_stmt_close: %s\n", mysql_error(conn));
        return 1;
    }

    return 0;
}


int callOp(MYSQL *conn, const enum opCode op, char *opArgs){
    int res;
    int numOfArgs = 1;
    char **strArgs;
    MYSQL_TIME *dateArgs = NULL;
    switch(op){
        case op1:
            res = callOp1(conn);
            break;
        case op2_1:
            ;
            res = callOp2_1(conn, numOfArgs, strtok(opArgs, ARG_DEL));
            break;
        case op2_2:
            ;
            numOfArgs = 2;
            strArgs = calloc(numOfArgs, sizeof(char*));
            strArgs[0] = strtok(opArgs, ARG_DEL);
            for(int i = 1; i < numOfArgs; i ++){
                strArgs[i] = strtok(NULL, ARG_DEL);
            }
            res = callOp2_2(conn, numOfArgs, strArgs[0], strArgs[1]);
            free(strArgs);
            break;
        case op3_1:
            ;
            numOfArgs = 2;
            strArgs = calloc(numOfArgs, sizeof(char*));
            strArgs[0] = strtok(opArgs, ARG_DEL);
            for(int i = 1; i < numOfArgs; i ++){
                strArgs[i] = strtok(NULL, ARG_DEL);
            }
            res = callOp3_1(conn, numOfArgs, strArgs[0], strArgs[1]);
            free(strArgs);
            break;
        case op3_2:
            // FIXME: [E] mysql_stmt_execute: ERROR: provided employer is not registered to be transferred to the job assigned to the physical office which contains the seat
            ;
            numOfArgs = 2;
            strArgs = calloc(numOfArgs, sizeof(char*));
            strArgs[0] = strtok(opArgs, ARG_DEL);
            for(int i = 1; i < numOfArgs; i ++){
                strArgs[i] = strtok(NULL, ARG_DEL);
            }
            res = callOp3_2(conn, numOfArgs, strArgs[0], strArgs[1]);
            free(strArgs);
            break;
        case op4:
            ;
            numOfArgs = 3;
            strArgs = calloc(numOfArgs, sizeof(char*));
            strArgs[0] = strtok(opArgs, ARG_DEL);
            for(int i = 1; i < numOfArgs; i ++){
                strArgs[i] = strtok(NULL, ARG_DEL);
            }
            res = callOp4(conn, numOfArgs, strArgs[0], strArgs[1], strArgs[2]);
            free(strArgs);
            break;
        case op5:
            ;
            res = callOp5(conn, numOfArgs, strtok(opArgs, ARG_DEL));
            break;
        case op6:
            ;
            numOfArgs = 2;
            strArgs = calloc(numOfArgs, sizeof(char*));
            strArgs[0] = strtok(opArgs, ARG_DEL);
            for(int i = 1; i < numOfArgs; i ++){
                strArgs[i] = strtok(NULL, ARG_DEL);
            }
            res = callOp6(conn, numOfArgs, strArgs[0], strArgs[1]);
            free(strArgs);
            break;
        case op7:
            ;
            res = callOp7(conn, numOfArgs, strtok(opArgs, ARG_DEL));
            break;
        case op9:
            ;
            char *bufDate = NULL;
            int bufNum;
            numOfArgs = 9;
            // parses string arguments
            strArgs = calloc(numOfArgs, sizeof(char*));
            strArgs[0] = strtok(opArgs, ARG_DEL);
            for(int i = 1; i < numOfArgs; i ++){
                if (i != 4){
                    strArgs[i] = strtok(NULL, ARG_DEL);
                    logMsg(D, "strArgs[%d] is: %s\n", i, strArgs[i]);
                } else{
                    bufDate = strtok(NULL, ARG_DEL);
                    logMsg(D, "bufDate is: %s\n", bufDate);
                }
            }
            // parses date arguments
            if (bufDate == NULL || !strcmp(bufDate, ARG_NULL)){}
            else {
                dateArgs = calloc(1, sizeof(MYSQL_TIME));
                sscanf(strtok(bufDate, ARG_DATE_DEL), "%d", &bufNum);
                dateArgs -> day = bufNum;
                sscanf(strtok(NULL, ARG_DATE_DEL), "%d", &bufNum);
                dateArgs -> month = bufNum;
                sscanf(strtok(NULL, ARG_DATE_DEL), "%d", &bufNum);
                dateArgs -> year = bufNum;

            }
            res = callOp9(conn, numOfArgs, strArgs[0], strArgs[1], strArgs[2], strArgs[3], dateArgs, strArgs[5], strArgs[6], strArgs[7], strArgs[8]);
            free(strArgs);
            if (dateArgs != NULL){
                free(dateArgs);
            }
            break;
        default:
            logMsg(E, "There is no such operation with provided opCode\n");
            return 1;
    }
    return res;
}

int connectToDB(char *username, char* passwd, MYSQL** connAddr){
    // Initialize connection
    if ((*connAddr = mysql_init(NULL)) == NULL){
        int err = errno;
        logMsg(E, "mysql_init: %s\n", strerror(err));
        return 1;
    }
    MYSQL *conn = *connAddr;
    // Tries to connect with db. NULL values are read from settings file
    if ((mysql_real_connect(conn,
                        host_name,
                        username,
                        passwd,
                        db_name,
                        0, // port number
                        NULL, // socket name
                        CLIENT_MULTI_STATEMENTS )) == NULL){
        logMsg(E, "mysql_real_connect: %s\n", mysql_error(conn));
        return 1;
    }
    return 0;
}

const char* getOpName(enum opCode code){
    return operations[code].name;
}

const char* getOpParams(enum opCode code){
    return operations[code].params;
}

const char* getOpString(enum opCode code){
    return opStrings[code];
}

