// Default headers
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <stdbool.h>
// Custom headers
#include "logger.h"
#include "controller.h"
#include "passwordAsker.h"
// Macros
#define SHORT_OPTS ""

void printOps(){
    logMsg(I, "Here is a list of supported opStrings. Please note that You must have the correct privileges for an operation in order to execute it. For executing an operation, write it in the format: opName [arg0, ...]\n");
    for (enum opCode c = op1; c < NUM_OPS; c ++){
        logMsg(I, "%s(%s)\n", getOpName(c), getOpParams(c));
    }
}

int main(int argc, char* argv[]){
    // variables
    int opt, connResult;
    int isPasswordRequired = 1;
//    char *input;
    char *passwd = NULL;
    MYSQL conn;
    // Constants
    const struct option longOptions[] = {
        {"nopasswd", no_argument, &isPasswordRequired, 0},
        {0, 0, 0, 0}
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
        disposePassword(passwd);
    } while (connResult);
    logMsg(I, "Succesfully logged in as %s\n", argv[optind]);
    // lists available options
    printOps();
    // TODO: collects user's choice
//    if (scanf("%ms[^\n]", &input) != 1){
//
//    }
}
