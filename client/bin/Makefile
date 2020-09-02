CC=gcc
SRC=*.c
OUT=debug

all: *.c
	$(CC) -g -Wall -Wextra $(SRC) -o $(OUT)  `mysql_config --cflags --include --libs`
