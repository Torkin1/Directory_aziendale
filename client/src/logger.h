#ifndef LOGGER_H_INCLUDED
#define LOGGER_H_INCLUDED

enum Tag {I, W, E, D};

void logMsg(enum Tag tag, char* msg);

#endif // LOGGER_H_INCLUDED
