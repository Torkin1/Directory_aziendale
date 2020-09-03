#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "controller.h"
#include "logger.h"
#include "passwordAsker.h"

#define settingsPath "settings"

int connectToDB(char *username, MYSQL* conn, bool IsPasswordRequired){
    char *passwd = NULL;

    // Initialize variables
    if ((conn = mysql_init(NULL)) == NULL){
        int err = errno;
        logMsg(E, strerror(err));
        return 1;
    }
    mysql_options(conn, MYSQL_READ_DEFAULT_FILE, settingsPath);
    // asks for password

    if (IsPasswordRequired && askPassword(&passwd)){
        logMsg(E, "failed to collect password\n");
        return 1;
    }
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

//int getAvailableOperations(char* username){
//
//}
