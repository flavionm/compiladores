CC		:= g++
LL		:= flex
YY		:= bison
C_FLAGS := -std=c++11 -pedantic -pedantic-errors -Wall -Wextra -march=native -Og

BIN		:= bin
SRC		:= src
INCLUDE	:= include
LIB		:= lib
RUN		:= exec

LIBRARIES	:= -lfl

ifeq ($(OS),Windows_NT)
EXECUTABLE	:= main.exe
else
EXECUTABLE	:= main
endif
LOUT		:= lex.yy.c
YOUT		:= y.tab.c
IN			:= program.mil
OUT			:= program.cpp
TEST		:= gabarito
EXEC		:= program

all: $(BIN)/$(YOUT)
	$(CC) $(C_FLAGS) -I$(INCLUDE) -L$(LIB) $^ -o ${BIN}/${EXECUTABLE} $(LIBRARIES)

clean:
	$(RM) $(BIN)/*

run: ${BIN}/${EXEC}
	./$^

${BIN}/${EXEC}: ${BIN}/${OUT}
	$(CC) ${C_FLAGS} $^ -o $@

${BIN}/${OUT}: all
	./$(BIN)/$(EXECUTABLE) < ${SRC}/${IN} > $@
	./${RUN}/${TEST} < $@

$(BIN)/$(YOUT): $(SRC)/*.y $(BIN)/$(LOUT)
	$(YY) --output=$@ $(SRC)/*.y

$(BIN)/$(LOUT): $(SRC)/*.l
	$(LL) -o $@ $^
