CC		:= g++
LL		:= flex
YY		:= bison
C_FLAGS := -std=c++11 -march=native -Og

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
MAIN		:= main.cpp
IN			:= program.mil
OUT			:= program.cpp
TEST		:= gabarito
EXEC		:= program

all: $(BIN)/$(EXECUTABLE)

$(BIN)/$(EXECUTABLE): $(BIN)/$(YOUT) $(SRC)/$(MAIN)
	$(CC) $(C_FLAGS) -I$(INCLUDE) -L$(LIB) $(SRC)/$(MAIN) -o ${BIN}/${EXECUTABLE} $(LIBRARIES)

clean:
	$(RM) $(BIN)/*

try: ${BIN}/${EXEC}
	./$^

run: ${BIN}/${OUT}
	$(CC) ${C_FLAGS} $^ -o ${BIN}/${EXEC}

${BIN}/${OUT}: $(BIN)/$(EXECUTABLE)
	./$^ < ${SRC}/${IN} > $@
	./${RUN}/${TEST} < $@

$(BIN)/$(YOUT): $(SRC)/*.y $(BIN)/$(LOUT)
	$(YY) --output=$@ $(SRC)/*.y

$(BIN)/$(LOUT): $(SRC)/*.l
	$(LL) -o $@ $^
