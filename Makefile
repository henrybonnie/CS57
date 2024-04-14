filename = miniC
VALGRIND = valgrind --leak-check=full --show-leak-kinds=all
CFLAGS = -Wno-deprecated -Wno-return-type -Wno-write-strings
CC = g++

## -DYYDEBUG=0

VALGRIND = valgrind --leak-check=full --show-leak-kinds=all

(filename).out: $(filename).l
	yacc -d -v $(filename).y
	lex $(filename).l
	$(CC) $(CFLAGS) -g lex.yy.c y.tab.c ast.c semantic_analysis.c main_comp.c -o $(filename).out

clean:
	rm -rf $(filename).out lex.yy.c y.tab.c ast.o y.tab.hm y.output vgcore.*