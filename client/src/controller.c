#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "controller.h"
#include "logger.h"

#define settingsPath "settings"

char *users[] = {"dip", "dipSetSpazi", "dipSetAmm", "man"};
char op;

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
