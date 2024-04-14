%{
#include "ast.h"
#include "semantic_analysis.h"
#include <stdio.h>
#include <cstddef>
#include <vector>
extern int yylex();
extern int yylex_destroy();
extern int yywrap();
int yyerror(char *);
extern FILE * yyin;
%}
%union{
	int iVal;
	char *sName;
	astNode *ast;
  	vector<astNode*> *stmt_list;
}

%token EXTERN IF ELSE VOID PRINT INT WHILE LE GE EQ RETURN
%token <iVal> NUM 
%token <sName> VARIABLE READ
%type <stmt_list> statements declarations
%type <ast> function program extern statement conditional operation declaration while_statement if_statement assignment while_body if_body return print block_statement
%type <ast> var uminus

%nonassoc IFX
%nonassoc ELSE

%start program

%%
// program
program : extern extern function { $$ = createProg($1, $2, $3); 
									semantic_analysis($$);}

// extern


extern : EXTERN VOID PRINT '(' INT ')' ';' { $$ = createExtern("print"); }
	| EXTERN INT READ '(' ')' ';' { $$ = createExtern("read"); }

// Function Declaration
function : INT VARIABLE '(' INT var ')' block_statement  { $$ = createFunc($2, $5, $7); }
	| INT VARIABLE '(' ')' '{' block_statement '}' { $$ = createFunc($2, NULL, $6); }


block_statement : '{' declarations statements '}' { vector<astNode*> *new_vec = new vector<astNode*>(); 
													new_vec->insert(new_vec->end(), $2->begin(), $2->end());
													new_vec->insert(new_vec->end(), $3->begin(), $3->end());
													$$ = createBlock(new_vec);
													delete($2);
													delete($3);

}
	| '{' statements '}' { $$ = createBlock($2); }

// statements
statements : statements statement {$$ = $1;
								$$->push_back($2); }

		   | statement { $$ = new vector<astNode*>();
						$$->push_back($1);} 


statement : while_statement
	| if_statement
	| assignment 
	| return
	| print
	;


while_statement: WHILE '(' conditional ')'  while_body  { $$ = createWhile($3, $5); }

if_statement: IF '(' conditional ')'  if_body  %prec IFX { $$ = createIf($3, $5); }
	| IF '(' conditional ')' if_body ELSE if_body { $$ = createIf($3, $5, $7); }

if_body: block_statement { $$ = $1; }
	| statement { $$ = $1; }

while_body: block_statement { $$ = $1; }

declarations: declarations declaration {$$ = $1;
								$$->push_back($2);}

		   | declaration { $$ = new vector<astNode*>();
						$$->push_back($1); }

declaration: INT VARIABLE ';' { $$ = createDecl($2); }

assignment: var '=' var ';' { $$ = createAsgn($1, $3); }
	| var '=' operation ';'{ $$ = createAsgn($1, $3); }
	| var '=' READ '(' ')' ';' { astNode* call = createCall($3); $$ = createAsgn($1, call); }

conditional: var '<' var { $$ = createRExpr($1, $3, lt); }
	| var '>' var { $$ = createRExpr($1, $3, gt); }
	| var LE var { $$ = createRExpr($1, $3, le); }
	| var GE var { $$ = createRExpr($1, $3, ge); }
	| var EQ var { $$ = createRExpr($1, $3, eq); }
	

operation : var '+' var { $$ = createBExpr($1, $3, add); }
	| var '-' var { $$ = createBExpr($1, $3, sub); }
	| var '*' var { $$ = createBExpr($1, $3, mul); }
	| var '/' var { $$ = createBExpr($1, $3, divide); }
	| uminus {$$ = $1;}


// Need to edit
print: PRINT '(' var ')' ';' { }

return: RETURN var ';' { $$ = createRet($2); }
	| RETURN '(' var ')' ';' { $$ = createRet($3); }
	| RETURN '(' operation ')' ';' { $$ = createRet($3); }
	| RETURN operation ';' { $$ = createRet($2); }

uminus: '-' var {$$ = createUExpr($2, uminus);}

var : NUM { $$ = createCnst($1); }
	| VARIABLE { $$ = createVar($1); }
	| uminus
%%

int yyerror(char *s){
	fprintf(stderr,"%s\n", s);
	return 0;
}

int main(int argc, char* argv[]){
		if (argc == 2){
			yyin = fopen(argv[1], "r");
			if (yyin == NULL) {
				fprintf(stderr, "File open error\n");
				return 1;
			}
		}
		#ifdef YYDEBUG
    	//	 yydebug = 1;
   	 	#endif
		yyparse();
		if (argc == 2) fclose(yyin);
	        yylex_destroy();
		return 0;
}