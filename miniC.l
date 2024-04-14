%{
#include "ast.h"
#include<stdio.h>
#include "y.tab.h"
int yyerror(char *);
%}

digit [0-9]

%%
if { return IF; }
else { return ELSE; }
int { return INT; }
read { return READ; }
while { return WHILE; }
print { return PRINT; }
extern { return EXTERN; }
void { return VOID; }
return { return RETURN; }


[a-zA-Z][a-zA-Z0-9_]* {
    yylval.sName = yytext;
    return VARIABLE;
}

[1-9]?{digit}+ {
    yylval.iVal = atoi(yytext);
    return NUM;
}

[-<>=+/*{}.]            { return yytext[0]; }
"("                     { return yytext[0]; }
")"                     { return yytext[0]; }
";"                     { return yytext[0]; }
"-"                     { return yytext[0]; }
">=" { return GE; }
"<=" { return LE; }
"==" { return EQ; }



%%
int yywrap(){
    return(1);
}
