#ifndef CONTROLLER_H_INCLUDED
#define CONTROLLER_H_INCLUDED

#include <mysql.h>

int connectToDB(char *username,  MYSQL *conn, bool isPasswordRequired);

#endif // CONTROLLER_H_INCLUDED
