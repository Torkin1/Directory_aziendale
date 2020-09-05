#ifndef CONTROLLER_H_INCLUDED
#define CONTROLLER_H_INCLUDED
#define ARG_DEL " "
#include <mysql.h>

enum opCode {
    op1,
    op2_1,
    op2_2,
    op3_1,
    op3_2,
    op4,
    op5,
    op6,
    op7,
    op9,
    NUM_OPS     // must be last
};

void initController();   // must be called first
int connectToDB(char *username, char* passwd, MYSQL **conn);
int callOp(MYSQL* conn, const enum opCode, char *opArgs);
const char* getOpName(enum opCode code);
const char* getOpParams(enum opCode code);
const char* getOpString(enum opCode code);
#endif // CONTROLLER_H_INCLUDED
