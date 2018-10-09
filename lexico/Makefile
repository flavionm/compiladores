CC		:= g++
LL		:= flex
C_FLAGS := -std=c++11 -pedantic -pedantic-errors -Wall -Wextra -march=native -Og

BIN		:= bin
SRC		:= src
INCLUDE	:= include
LIB		:= lib

LIBRARIES	:= -lfl

ifeq ($(OS),Windows_NT)
EXECUTABLE	:= main.exe
else
EXECUTABLE	:= main
endif
LOUT		:= lex.yy.c

all: $(BIN)/$(EXECUTABLE)

clean:
	$(RM) $(BIN)/$(EXECUTABLE)

run: all
	./$(BIN)/$(EXECUTABLE)

$(BIN)/$(EXECUTABLE): $(BIN)/$(LOUT)
	$(CC) $(C_FLAGS) -I$(INCLUDE) -L$(LIB) $^ -o $@ $(LIBRARIES)

$(BIN)/$(LOUT): $(SRC)/*.l
	$(LL) -o $(BIN)/$(LOUT) $^
