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
#include "liberty2xml.tab.hpp"
#include <string.h>

extern int lineno;
extern char buf[2048];
char *search_string_for_linefeeds(char *str);
%}

%x comment
%x stringx
%x include

VOLTAGE VDD|VCC|VSS
EXPR_OP "+"|"-"|"*"|"/"
FLOAT [-+]?([0-9]+\.?[0-9]*([Ee][-+]?[0-9]+)?|[0-9]*\.[0-9]*([Ee][-+]?[0-9]+)?)
SP  [ \t]*
%%

\,	{return COMMA;}
\;	{return SEMI;}
\(	{return LPAR;}
\)	{return RPAR;}
\{	{return LCURLY;}
\}[ \t]*\;?	{return RCURLY;}
[ \t]?\:	{return COLON;}
include_file[ \t]*\(	BEGIN(include);

[-+]?([0-9]+\.?[0-9]*([Ee][-+]?[0-9]+)?|[0-9]*\.[0-9]*([Ee][-+]?[0-9]+)?) {yylval.str = strdup(yytext); return NUM;}

{VOLTAGE}{SP}{EXPR_OP}{SP}{FLOAT}|{FLOAT}{SP}{EXPR_OP}{SP}{VOLTAGE} { yylval.str = strdup(yytext); return STRING;}

[A-Za-z!@#$%^&_+=\|~\?][A-Za-z0-9!@#$%^&_+=\|~\?]*[\<\{\[\(][-0-9:]+[\]\}\>\)] { yylval.str = strdup(yytext); return IDENT; }

[-+]?[0-9]*\.?[0-9]+([Ee][-+]?[0-9]+)?[ \t]*[-\+\*\/][ 	]*[-+]?[0-9]*\.?[0-9]+([Ee][-+]?[0-9]+)?         {yylval.str = strdup(yytext); return STRING;}
"define"                 {return KW_DEFINE;}
"define_group"           {return KW_DEFINE_GROUP;}
[Tt][Rr][Uu][Ee]         {return KW_TRUE;}
[Ff][Aa][Ll][Ss][Ee]     {return KW_FALSE;}
\\?\n	                 {ECHO; lineno++;}
\\[ \t]+\n	{printf("line %d -- Continuation char followed by spaces or tabs!\n\n", lineno); ECHO; lineno++; }
\r              { ECHO; }
\t              { ECHO; }
" "             { ECHO; }

"/*"	{BEGIN(comment); printf("<!-- "); }
\"	{BEGIN(stringx); }

<comment>[^*\n]*        {ECHO; /* eat anything that's not a '*' */ }
<comment>"*/"	        {printf("-->"); BEGIN(INITIAL); }
<comment>\n             {ECHO; ++lineno; }
<comment>"*"            {ECHO; /* eat up '*'s not followed by '/'s */ }

<stringx>\"	{ BEGIN(INITIAL);  yytext[yyleng-1] = '\0'; yylval.str = strdup(yytext); return STRING; }
<stringx>\n     { BEGIN(INITIAL);  yylval.str = strdup(yytext); return STRING; }
<stringx>\\\n 	{ yymore(); lineno++; }
<stringx>\\.    { yymore(); }
<stringx>[^\\\n\"]+ { yymore(); }

<include>[ \t]*         
<include>[^ \t\n);]+	
<include>")"
<include>";" 

[a-zA-Z0-9!@#$%^&_+=\|~\?<>\.\-]+ { yylval.str = strdup(yytext); return IDENT; }

%%

int yywrap()
{
    return(1);
}

char *search_string_for_linefeeds(char *str)
{
   char *s;
   s = str;
   while (*s){ if( *s++ == '\n' ) {lineno++; if( *(s-2) != '\\' ){printf("Warning: line %d: String constant spanning input lines does not use continuation character.\n",lineno);} } }
   return str;
}

