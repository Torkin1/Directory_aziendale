#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include "logger.h"

static const char* tagStrings[] = {"I", "W", "E", "D"};

const char* getStringFromTag(enum Tag tag){
    return tagStrings[tag];
}

void logMsg(enum Tag tag, const char* format, ...){

    char buf[MSG_MAX_LEN];
    int firstHalfLen;
    va_list ap;
    va_start(ap, format);

    snprintf(buf, sizeof(char) * MSG_MAX_LEN, "[%s] ", getStringFromTag(tag));
    firstHalfLen = strlen(buf);
    vsnprintf(buf + firstHalfLen, MSG_MAX_LEN - firstHalfLen, format, ap);
    fprintf(stdout, buf, getStringFromTag(tag), format);
    fflush(stdout);
    va_end(ap);
}
