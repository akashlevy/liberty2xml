
/* bison input file */
%{
/******************************************************************************
    Copyright (c) 1996-2000 Synopsys, Inc.    ALL RIGHTS RESERVED

  The contents of this file are subject to the restrictions and limitations
  set forth in the SYNOPSYS Open Source License Version 1.0  (the "License"); 
  you may not use this file except in compliance with such restrictions 
  and limitations. You may obtain instructions on how to receive a copy of 
  the License at

  http://www.synopsys.com/partners/tapin/tapinprogram.html. 

  Software distributed by Original Contributor under the License is 
  distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either 
  expressed or implied. See the License for the specific language governing 
  rights and limitations under the License.

******************************************************************************/
#include <stdio.h>
#include <string.h>
char buf[2048];
int lineno;  

extern int yylex(void);
extern void yyerror(char *s);
%}

%union {
	char *str;
	double num;
}

%token COMMA SEMI LPAR RPAR LCURLY RCURLY COLON KW_DEFINE KW_DEFINE_GROUP KW_TRUE KW_FALSE
%token <str> NUM
%token <str> STRING IDENT

%type <str>  define define_group
%type <str>  param_list attr_val
%type <str>  s_or_i
%type <str>  head

%%

file	: {lineno = 1; 
           printf("<?xml version='1.0' encoding='UTF-8'?>\n"); } 
           group
	;

group	: head { printf(">");} LCURLY statements RCURLY {printf("</%s>",$1); free($1); }
        | head { printf("/>"); free($1); } LCURLY RCURLY 
	;

statements 	: statement 
		| statements statement 
		;

statement 	: simple_attr 
		| complex_attr 
		| define 
		| define_group 
		| group  
		;

simple_attr	: IDENT COLON attr_val SEMI {printf("<%s>%s</%s>",$1,$3,$1); free($1); free($3);}
		| IDENT COLON attr_val {printf("<%s>%s</%s>",$1,$3,$1); free($1); free($3); }
		;

complex_attr 	: head  SEMI  { printf("/>"); free($1);}
                | head  { printf("/>"); free($1); }
		;

head	: IDENT LPAR param_list RPAR 
          { printf("<%s params=\"%s\"", $1, $3); free($3); $$ = $1; }
        | IDENT LPAR RPAR { printf("<%s", $1); $$ = $1;} 
	;

param_list  : attr_val { $$ = $1; }
            | param_list COMMA attr_val 
              { sprintf(buf,"%s, %s", $1, $3); free($1); free($3); $$ = strdup(buf); }
            | param_list attr_val
              { sprintf(buf,"%s %s", $1, $2); free($1); free($2); $$ = strdup(buf); }
	    ;

define 	: KW_DEFINE LPAR s_or_i COMMA s_or_i COMMA s_or_i RPAR SEMI  
          {printf("<define>%s, %s, %s</define>",$3,$5,$7); free($3); free($5); free($7); }
	;

define_group : KW_DEFINE_GROUP LPAR s_or_i COMMA s_or_i RPAR SEMI
          {printf("<define_group>%s, %s</define_group>",$3,$5); free($3); free($5);}
             ;

s_or_i  : STRING { $$ = $1; }
        | IDENT  { $$ = $1; }
        ;

attr_val : NUM { $$ = $1; }
         | s_or_i { $$ = $1; }
         | KW_TRUE { $$ = strdup("true"); }
         | KW_FALSE { $$ = strdup("false"); }
	 ;
%%

#include <stdio.h>
int yyparse();
extern int yylex();

void yyerror(char *s)
{
  fprintf(stderr, "line %d: %s \n", lineno, s);
}

int main()
{
  yyparse();
}
