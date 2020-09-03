#ifndef CONTROLLER_H_INCLUDED
#define CONTROLLER_H_INCLUDED

#include <mysql.h>
#include <stdbool.h>

int connectToDB(char *username,  MYSQL *conn, bool isPasswordRequired);
int getAvailableOperations(char *username);

#endif // CONTROLLER_H_INCLUDED
