#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "controller.h"
#include "logger.h"

#define SETTINGS_PATH "settings"
#define MAX_VARCHAR_LENGTH 45

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
    operations[op2_2].params = "cfDipendente1, cfDipendente";
    operations[op2_2].stmt = "call scambiaDipendenti(?, ?))";

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
    operations[op9].stmt = "call assumiDipenente(?, ?, ?, ?, ?, ?, ?, ?)";

}

int prepareOp(MYSQL *conn, enum opCode op, MYSQL_STMT **stmtAddr){
    if ((*stmtAddr = mysql_stmt_init(conn)) == NULL){
        logMsg(E, "mysql_stmt_init: %s\n", mysql_error(conn));
        return 1;
    }
    MYSQL_STMT *stmt = *stmtAddr;
    if (mysql_stmt_prepare(stmt, operations[op].stmt, strlen(operations[op1].stmt)) != 0){
        logMsg(E, "mysql_stmt_prepare: %s\n", mysql_stmt_error(stmt));
        return 1;
    }
}

void printResSet(MYSQL_STMT* stmt, MYSQL_RES *metaRes, MYSQL_BIND *resultSetCols){
    int resNumCol = mysql_num_fields(metaRes);
    int width[resNumCol];
    logMsg(I, "");
    for (int c = 0; c < resNumCol; c ++){
        printf("%s%n | ", mysql_fetch_field(metaRes) -> name, width + c);
    }
    printf("\n");
    fflush(stdout);
    for (int r = 0; mysql_stmt_fetch(stmt) == 0; r ++){
        logMsg(I, "");
        for (int c = 0; c < resNumCol; c ++){
            printf("%*s | ", width[c], (*(resultSetCols + c) -> is_null)? "NULL" : resultSetCols[c].buffer);
        }
        printf("\n");
    }
    printf("\n");
    fflush(stdout);
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

MYSQL_BIND *callocResultSetCols(int resNumCol){
   MYSQL_BIND *resultSetCols = calloc(resNumCol, sizeof(MYSQL_BIND));
    for (int i = 0; i < resNumCol; i ++){
    resultSetCols[i].buffer_type = MYSQL_TYPE_STRING;
    resultSetCols[i].buffer = (char *) calloc(MAX_VARCHAR_LENGTH, sizeof(char));
    resultSetCols[i].buffer_length  = MAX_VARCHAR_LENGTH;
    resultSetCols[i].length = (unsigned long*) calloc(1, sizeof(unsigned long));
    resultSetCols[i].is_null = (bool *) calloc(1, sizeof(bool));
    resultSetCols[i].error = (bool *) calloc(1, sizeof(bool));
    }
    return resultSetCols;
}

int callOp1(MYSQL *conn){
    MYSQL_STMT *stmt;
    MYSQL_BIND *resultSetCols;
    MYSQL_RES *metaRes;
    int hasNext;
    int resNumCol = 0;
    if (prepareOp(conn, op1, &stmt)){
        logMsg(E, "failed to prepare statement");
        return 1;
    }

    if (mysql_stmt_execute(stmt)){
        logMsg(E, "mysql_stmt_execute: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    if ((metaRes = mysql_stmt_result_metadata(stmt)) == NULL){
        logMsg(E, "mysql_stmt_result_metadata: %s\n", mysql_stmt_error(stmt));
        return 1;
    }
    resNumCol = mysql_num_fields(metaRes);

    // bind result set
    resultSetCols = callocResultSetCols(resNumCol);
    if (mysql_stmt_bind_result(stmt, resultSetCols)){
        logMsg(E, "mysql_stmt_bind_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // buffers result set
    if (mysql_stmt_store_result(stmt) != 0){
        logMsg(E, "mysql_stmt_store_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }

    // displays report
    printResSet(stmt, metaRes, resultSetCols);

    // consumes all remaining result sets
    do {
       if (mysql_stmt_free_result(stmt) != 0){
        logMsg(E, "mysql_stmt_free_result: %s\n", mysql_stmt_error(stmt));
        return 1;
        }
    } while ((hasNext = mysql_stmt_next_result(stmt) == 0));
    if (hasNext > 0){
        logMsg(E, "mysql_stmt_next_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }
    // frees memory
    mysql_free_result(metaRes);
    if (mysql_stmt_close(stmt) != 0){
        logMsg(E, "mysql_stmt_close: %s\n", mysql_error(conn));
        return 1;
    }
    freeResultSet(resultSetCols, resNumCol);

    return 0;
}

int callOp(MYSQL *conn, const enum opCode op, char *opArgs){
    // TODO: Binding of in and out params and collecting the result set are demanded to the particular op
    switch(op){
        case op1:
            callOp1(conn);
            break;
        default:
            logMsg(E, "There is no operation with provided opCode\n");
            return 1;
    }
    return 0;
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
                        CLIENT_MULTI_RESULTS)) == NULL){
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

