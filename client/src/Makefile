CC=gcc
OUT=../bin/debug

all: *.c
	$(CC) -g -Wall -Wextra *.c -o $(OUT)  `mysql_config --cflags --include --libs`
