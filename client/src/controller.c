// #include <sys/socket.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "controller.h"
#include "logger.h"
#include "passwordAsker.h"

#define settingsPath "settings"

int connectToDB(char *username, MYSQL* conn){
//    int sd;
    char *passwd;

    // Initialize variables
/*    if (sd = socket(AF_UNIX, SOCK_STREAM, 0) < 3){
        logMsg(E, "Can't create socket");
        return 1;
    }
    */
    if ((conn = mysql_init(NULL)) == NULL){
        int err = errno;
        logMsg(E, strerror(err));
        return 1;
    }
    mysql_options(conn, MYSQL_READ_DEFAULT_FILE, settingsPath);
    // asks for password
    if (askPassword(&passwd)){
        logMsg(E, "failed to collect password");
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
        logMsg(E, mysql_error(conn));
        return 1;
    }
    return 0;
}
