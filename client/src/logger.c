#include <stdio.h>
#include "logger.h"

static const char* tagStrings[] = {"I", "W", "E", "D"};

const char* getStringFromTag(enum Tag tag){
    return tagStrings[tag];
}

void logMsg(enum Tag tag, char* msg){
    printf("[%s] %s\n", getStringFromTag(tag), msg);
}
