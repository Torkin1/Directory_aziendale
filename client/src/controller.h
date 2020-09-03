#ifndef CONTROLLER_H_INCLUDED
#define CONTROLLER_H_INCLUDED

#include <mysql.h>
#include <stdbool.h>

int connectToDB(char *username, char* passwd, MYSQL *conn);
#endif // CONTROLLER_H_INCLUDED
