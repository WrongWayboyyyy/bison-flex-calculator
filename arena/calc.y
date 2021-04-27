%{
#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>
#include "arena_ast.h"
#include "carena.h"
int yylex();
int yyparse(arena*);
%}

%union {
    int a;
    double d;
}

%token <d> NUMBER
%token EOL

%left '+' '-'
%left '*' '/'
%nonassoc '|' UMINUS

%type <a> exp

%param { arena* arg }

%code requires {
    #include "arena.h"
}

%%

calclist: 
    | calclist exp EOL { printf("= %f\n", eval(arg, &(arg->arena[$2]))); 
    //arena_free(arg);
    }
    | calclist EOL { printf("> "); }
;

exp: exp '+' exp {$$ = newast(arg, '+', $1, $3); }
    | exp '-' exp {$$ = newast(arg, '-', $1, $3); }
    | exp '*' exp {$$ = newast(arg, '*', $1, $3); }
    | exp '/' exp {$$ = newast(arg, '/', $1, $3); }
    | '|' exp {$$ = newast(arg, '|', $2, -1); } 
    | '(' exp ')' {$$ = $2; }
    | '-' exp %prec UMINUS {$$ = newast(arg, 'M', $2, -1); }
    | NUMBER {$$ = newnum(arg, $1); }
;   

%%


/* void yyerror(char* s) {
    fprintf(stderr, "%d: error: ", yylineno);
    fprintf(stderr, "\n");
} */


int main(int argc, char** argv) {
    arena* arena = malloc(sizeof(arena));
    arena_construct(arena);
    printf("> ");
    return yyparse(arena);
}