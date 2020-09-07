// Default headers
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <stdbool.h>
#include <errno.h>
// Custom headers
#include "logger.h"
#include "controller.h"
#include "passwordAsker.h"
// Macros
#define SHORT_OPTS ""
void printOps(){
    logMsg(I, "Here is a list of supported operations. Please note that You must have the correct privileges for an operation in order to execute it. For executing an operation, type it in the format: opCode[:arg0:arg1 ...]\n");
    for (enum opCode c = op1; c < NUM_OPS; c ++){
        logMsg(I, "%s: %s(%s)\n", getOpString(c), getOpName(c), getOpParams(c));
    }
}

int main(int argc, char* argv[]){
    // variables
    int opt, connResult;
    int isPasswordRequired = 1;
    char *passwd = NULL;
    MYSQL *conn;
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
        }
        // connects to db
        initController();
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
    char *input, *buf;
    char *inOpString = "";
    char *inOpArgs = "";
    size_t inputLen;
    int c;
    enum opCode selectedOpCode;
    while (true){
        // collects user's input and partially parses it
        logMsg(I, "Type here:\n");
        input = NULL;
        inputLen = 0;
        while (getline(&input, &inputLen, stdin) < 0){
            int err = errno;
            logMsg(E, "scanf: %s\n", strerror(err));
            while ((c = getchar()) != '\n' && c != EOF);
        }
        input[strlen(input) - 1] = '\0';
        buf = strtok(input, ARG_DEL);
        if (buf != NULL){
            inOpString = buf;
            inOpArgs = input + strlen(inOpString) + 1;
        }

        // calls matched op. No op could never have NUM_OPS has opCode, so it can be used as a invalid op code too
        selectedOpCode = NUM_OPS;
        for (enum opCode op = op1; op < NUM_OPS; op ++){
            if (strcmp(inOpString, getOpString(op)) == 0){
                selectedOpCode = op;
                break;
            }
        }
        if (callOp(conn, selectedOpCode, inOpArgs)){
            logMsg(E, "Failed to execute %s\n", inOpString);
        }
        else{
            logMsg(I, "Done!\n");
        }
        // disposes of user input
        free(input);
    }
}
