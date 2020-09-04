#include <termios.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

#include "passwordAsker.h"
#include "logger.h"

static struct termios oldTermConf;

int restoreEchoing(){
    if (tcsetattr(fileno(stdin), TCSANOW, &oldTermConf)){
        int err = errno;
        logMsg(E, "tctsetattr: %s\n", strerror(err));
        return 1;
    }
    return 0;
}

void handler(int sig){
    if (sig == SIGINT){
        if (restoreEchoing()){
            logMsg(E, "can't restore term\n");
            exit(EXIT_FAILURE);
        }
    exit(EXIT_SUCCESS);
    }
}

int disableEchoing(){
    struct termios newTermConf;
    memset(&newTermConf, 0, sizeof(struct termios));
    // save current terminal conf
    if (tcgetattr(fileno(stdin), &oldTermConf)){
        int err = errno;
        logMsg(E, "tcgetattr: %s\n", strerror(err));
        return 1;
    }
    // Sets an handler for SIGINT
    struct sigaction sa_sigint;
    memset(&sa_sigint, 0, sizeof(struct sigaction));
    sa_sigint.sa_handler = handler;
    if (sigaction(SIGINT, &sa_sigint, NULL) < 0){
        int err = errno;
        logMsg(E, "sigaction: %s\n", strerror(err));
        return 1;
    }
    // Sets terminal conf to obfuscate password
    memcpy(&newTermConf, &oldTermConf, sizeof(struct termios));
    newTermConf.c_lflag &= ~ECHO;
    if (tcsetattr(fileno(stdin), TCSANOW, &newTermConf)){
        int err = errno;
        logMsg(E, "tcsetattr: %s\n", strerror(err));
        return 1;
    }
    return 0;
}

int askPassword(char** passwd){

    // prompts user to type password
    logMsg(I, "Please enter password:\n");
    // sets term in non-echoing mode
    if (disableEchoing()){
        logMsg(E, "failed to set term in non-echoing mode\n");
        return 1;
    }
    // collects user password
    if(scanf("%ms[^;-#`$|\n]", passwd) != 1){
        int err = errno;
        logMsg(E, "scanf: %s\n", strerror(err));
        return 1;
    }
    int c;
    while((c = getchar()) != '\n' && c != EOF);
    // sets term in echoing mode
    if (restoreEchoing()){
        logMsg(E, "failed to set term in echoing mode\n");
        return 1;
    }
    return 0;
}

void disposePassword(char* password){
    // more actions could be taken to securely dispose of the password
    int passLen = strlen(password);
    memset(password, 0, passLen);
    // password must be disposed coerently to the collecting method used in askPassword (for istance, if scanf("%ms") is used function free() must be called)
    free(password);
}
