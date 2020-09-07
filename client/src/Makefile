CC=gcc
OUT=../bin/debug

all: *.c
	$(CC) -g -Wall -Wextra --std=gnu99 *.c -o $(OUT)  `mysql_config --cflags --include --libs`
