// Default headers
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// MySQL header

// Custom headers
#include "logger.h"
#include "controller.h"
// Constants

int main(int argc, char* argv[]){
    // declaring variables
    MYSQL conn;

    logMsg(I, "DirAz Thin Client - connector for directory_aziendale DB\n");
    // At least username must be provided
    if (argc < 2){
        logMsg(E, "An username is required to connect to DB. Try asking your manager\n");
        exit(EXIT_FAILURE);
    }
    // Tries to connect to db with provided credentials until login succeeds or a signal is caught
    while (connectToDB(argv[1], &conn)){
        logMsg(E, "connection to db failed. Check username and password");
    }
    char msg[64];
    snprintf(msg, sizeof(char) * 64, "Succesfully logged in as %s", argv[1]);
    logMsg(I, msg);
}
