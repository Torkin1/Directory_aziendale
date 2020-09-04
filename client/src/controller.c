#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "controller.h"
#include "logger.h"

#define settingsPath "settings"

struct op {
    const char* name;
    const char* params;
    const char* stmt;
};

static struct op operations[NUM_OPS] = {
    {
        "generaReportDaTrasferire",
        "",
        "call generaReportDaTrasferire()"
    },
    {
        "trovaDipendentiScambiabili",
        "cfDipendente",
        "call trovaDipendentiScambiabili(?)"
    },
    {
        "scambiaDipendenti",
        "cfDipendente1, cfDipendente",
        "call scambiaDipendenti(?, ?)"
    },
    {
        "trovaUfficiConPostazioneVuota",
        "nomeMansione, nomeSettore",
        "call trovaUfficiConPostazioneVuota(?, ?)"
    },
    {
        "assegnaDipendenteAPostazioneVuota",
        "cfDipendente, numTelefonicoEsternoPostazioneVuota",
        "call assegnaDipendenteAPostazioneVuota(?, ?)"
    },
    {
        "cambiaMansioneDipendente",
        "cfDipendente, nomeNuovaMansione, nomeNuovoSettore",
        "call cambiaMansioneDipendente(?, ?, ?)"
    },
    {
        "elencaTrasferimentiDipendente",
        "cfDipendente",
        "call elencaTrasferimentiDipendente(?)"
    },
    {
        "ricercaDipendente",
        "nome, cognome",
        "call ricercaDipendente(?, ?)"
    },
    {
        "ricercaPerNumeroTelefono",
        "numTelefonoEsterno",
        "call ricercaPerNumeroTelefono(?)"
    },
    {
        "assumiDipendente",
        "cf, nome, cognome, luogoNascita, dataNascita, emailPersonale, indirizzoResidenza, nomeMansione, nomeSettore",
        "call assumiDipenente(?, ?, ?, ?, ?, ?, ?, ?)"
    }
};

const char* getOpName(enum opCode code){
    return operations[code].name;
}

const char* getOpParams(enum opCode code){
    return operations[code].params;
}

int collectResultSet(MYSQL_STMT *stmt, MYSQL_BIND *bind){
    if (mysql_stmt_bind_result(stmt, bind) != 0){
        logMsg(E, "mysql_stmt_bind_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }
    int fetchResult;
    while ((fetchResult = mysql_stmt_fetch(stmt)) != MYSQL_NO_DATA){
        if (fetchResult != 0){
            logMsg(E, "mysql_stmt_fetch: %s\n", mysql_stmt_error(stmt));
            return 1;
        }
    }
    if (mysql_stmt_free_result(stmt) != 0){
        logMsg(E, "mysql_stmt_free_result: %s\n", mysql_stmt_error(stmt));
        return 1;
    }
    return 0;
}

int prepareAndLaunchStatement(MYSQL *conn, char *statement, MYSQL_BIND *in, MYSQL_STMT **prepStatAddr){
    if ((*prepStatAddr = mysql_stmt_init(conn)) == NULL){
        logMsg(E, "mysql_stmt_init: %s\n", mysql_error(conn));
        return 1;
    }
    if (mysql_stmt_prepare(*prepStatAddr, statement, strlen(statement)) != 0){
        logMsg(E, "mysql_stmt_prepare: %s\n", mysql_stmt_error(*prepStatAddr));
        return 1;
    }
    if (mysql_stmt_bind_param(*prepStatAddr, in) != 0){
        logMsg(E, "mysql_stmt_bind_param: %s\n", mysql_stmt_error(*prepStatAddr));
        return 1;
    }
    if (mysql_stmt_execute(*prepStatAddr) != 0){
        logMsg(E, "mysql_stmt_execute: %s\n", mysql_stmt_error(*prepStatAddr));
        return 1;
    }
    return 0;
}

int connectToDB(char *username, char* passwd, MYSQL* conn){
    // Initialize connection
    if ((conn = mysql_init(NULL)) == NULL){
        int err = errno;
        logMsg(E, "mysql_init: %s\n", strerror(err));
        return 1;
    }
    mysql_options(conn, MYSQL_READ_DEFAULT_FILE, settingsPath);
    // Tries to connect with db. NULL values are read from settings file
    if ((mysql_real_connect(conn,
                        NULL, // host name
                        username,
                        passwd,
                        NULL, // db name
                        0, // port number
                        NULL, // socket name
                        CLIENT_MULTI_RESULTS)) == NULL){
        logMsg(E, "mysql_real_connect: %s\n", mysql_error(conn));
        return 1;
    }
    return 0;
}

