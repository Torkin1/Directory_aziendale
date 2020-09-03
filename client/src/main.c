// Default headers
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include<unistd.h>
#include <getopt.h>
// Custom headers
#include "logger.h"
#include "controller.h"
// Constants
#define SHORT_OPTS ""


int main(int argc, char* argv[]){
    int isPasswordRequired = 1;

    // greets user
    logMsg(I, "DirAz Thin Client - connector for directory_aziendale DB\n");
    // parses command line args
    const struct option longOptions[] = {
        {"nopasswd", no_argument, &isPasswordRequired, 0},
        {0, 0, 0, 0}
    };
    int opt;
    while ((opt = getopt_long(argc, argv, SHORT_OPTS, longOptions, NULL)) != -1);
    // At least username must be provided
    if (argc - optind < 1){
        logMsg(I, "Usage: %s [%s] username\n", argv[0], longOptions[0].name);
        exit(EXIT_SUCCESS);
    }
    // Tries to connect to db with provided credentials until login succeeds or a signal is caught
    MYSQL conn;
    while (connectToDB(argv[optind], &conn, (bool) isPasswordRequired)){
        logMsg(E, "connection to db failed. Check username and password\n");
        if (!isPasswordRequired){
            exit(EXIT_FAILURE);
        }
    }
    logMsg(I, "Succesfully logged in as %s\n", argv[optind]);
    // TODO: lists available options
}
