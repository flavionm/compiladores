CC		:= g++
LL		:= flex
YY		:= bison
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
YOUT		:= y.tab.c
IN			:= lista.txt
OUT			:= lista.c
TEST		:= main.cpp
FINAL		:= lista

all: $(BIN)/$(EXECUTABLE)

clean:
	$(RM) $(BIN)/*

run: all
	./$(BIN)/$(EXECUTABLE) < $(SRC)/$(IN) > $(BIN)/$(OUT); $(CC) $(C_FLAGS) $(SRC)/$(TEST) $(BIN)/$(OUT) -o $(BIN)/$(FINAL); ./$(BIN)/$(FINAL)

$(BIN)/$(EXECUTABLE): $(BIN)/$(YOUT)
	$(CC) $(C_FLAGS) -I$(INCLUDE) -L$(LIB) $^ -o $@ $(LIBRARIES)

$(BIN)/$(YOUT): $(SRC)/*.y $(BIN)/$(LOUT)
	$(YY) --output=$(BIN)/$(YOUT) $(SRC)/*.y

$(BIN)/$(LOUT): $(SRC)/*.l
	$(LL) -o $(BIN)/$(LOUT) $^
