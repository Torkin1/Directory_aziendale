// Default headers
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
// Custom headers
#include "logger.h"
#include "controller.h"
#include "passwordAsker.h"
// Macros
#define SHORT_OPTS ""

int countOperations(const char* operations[]){
    int count = 0;
    for (int i = 0; operations[i] != NULL; i ++){
        count ++;
    }
    return count;
}

void printOps(const char* operations[]){

}

int main(int argc, char* argv[]){
    // variables
    int opt, connResult;
    int isPasswordRequired = 1;
    char *passwd = NULL;
    MYSQL conn;
    // Constants
    const struct option longOptions[] = {
        {"nopasswd", no_argument, &isPasswordRequired, 0},
        {0, 0, 0, 0}
    };
    const char *operations[] = {  // operations are described with their name following their parameters divided by space
        "generaReportDaTrasferire",
        "trovaDipendentiScambiabili cfDipendente",
        "scambiaDipendenti cfDipendente1, cfDipendente2",
        "trovaUfficiConPostazioneVuota nomeMansione, nomeSettore",
        "assegnaDipendenteAPostazioneVuota cfDipendente, numTelefonicoEsternoPostazioneVuota",
        "cambiaMansioneDipendente cfDipendente, nomeNuovaMansione, nomeNuovoSettore",
        "elencaTrasferimentiDipendente cfDipendente",
        "ricercaDipendente nome, cognome",
        "ricercaPerNumeroTelefono numTelefonoEsterno",
        "assumiDipendente cf, nome, cognome, luogoNascita, dataNascita, emailPersonale, indirizzoResidenza, nomeMansione, nomeSettore",
        NULL
    };

    // greets user
    logMsg(I, "DirAz Thin Client - connector for directory_aziendale DB\n");
    // parses command line args
    while ((opt = getopt_long(argc, argv, SHORT_OPTS, longOptions, NULL)) != -1);
    // At least username must be provided
    if (argc - optind < 1){
        logMsg(I, "Usage: %s [%s] username\n", argv[0], longOptions[0].name);
        exit(EXIT_SUCCESS);
    }
    // Tries to connect to db with provided credentials until login succeeds or a signal is caught
    do {
        // asks for password
        if (isPasswordRequired && askPassword(&passwd)){
            logMsg(E, "failed to collect password\n");
            return 1;
        }
        // connects to db
        connResult = connectToDB(argv[optind], passwd, &conn);
        if (connResult){
           logMsg(E, "connection to db failed. Check username and password\n");
            if (!isPasswordRequired){
                exit(EXIT_FAILURE);
            }
        }
    } while (connResult);
    // passwordAsker allocates passwd dinamically (TODO: move this in a wrapper in passwordAsker)
    free(passwd);
    logMsg(I, "Succesfully logged in as %s\n", argv[optind]);
    // lists available options (TODO: mov this inside printOptions)
    logMsg(I, "Here is a list of supported operations. Please note that You must have the correct privileges for an operation in order to execute it. For executing an operation, write it in the format: opName [arg0, ...]\n");
    int numOfOps = countOperations(operations);
    for (int i = 0; i < numOfOps; i ++){
        char *opName, *paramList;
        int opLen = strlen(operations[i]);
        char buf[opLen];

        strcpy(buf, operations[i]);
        opName = strtok(buf, " ");
        paramList = (strtok(NULL, " ") == NULL)? "" : operations[i] + strlen(opName) + 1;
        logMsg(I, "%s(%s)\n", opName, paramList);
    }
    // TODO: collects user's choice
}
