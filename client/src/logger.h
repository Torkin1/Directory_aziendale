#ifndef LOGGER_H_INCLUDED
#define LOGGER_H_INCLUDED

#define MSG_MAX_LEN 1024

enum Tag {I, W, E, D};

void logMsg(enum Tag tag, const char* msg, ...);

#endif // LOGGER_H_INCLUDED
