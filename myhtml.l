%{
#include "myhtml.tab.h"  
#include <string.h>
#include <stdio.h>
void yyerror(const char *s);
%}

%option noyywrap

%x COMMENT

DQUOTE \"
SQUOTE \'
IDENT [a-zA-Z_][a-zA-Z0-9_-]*
POSITIVE_INT [1-9][0-9]*|[0-9]
WHITESPACE [ \t\r\n]+
TEXTDATA [^<>\n]+
COMMENT_BODY ([^-]|(-[^-]))*

%%

"<!--"                      { BEGIN(COMMENT); return COMMENT_START; }
<COMMENT>{COMMENT_BODY}     { yylval.str = strdup(yytext); return COMMENT_TEXT; }
<COMMENT>"-->"              { BEGIN(INITIAL); return COMMENT_END; }

"<MYHTML>"                  { return START_MYHTML; }
"</MYHTML>"                 { return END_MYHTML; }
"<head>"                    { return START_HEAD; }
"</head>"                   { return END_HEAD; }
"<title>"                   { return START_TITLE; }
"</title>"                  { return END_TITLE; }
"<meta "                    { return START_META; }
"/>"                        { return TAG_CLOSE; }
"<body>"                    { return START_BODY; }
"</body>"                   { return END_BODY; }
"<p "                       { return START_P; }
"</p>"                      { return END_P; }
"<a "                       { return START_A; }
"</a>"                      { return END_A; }
"<img "                     { return START_IMG; }
"<form "                    { return START_FORM; }
"</form>"                   { return END_FORM; }
"<input "                   { return START_INPUT; }
"<label "                   { return START_LABEL; }
"</label>"                  { return END_LABEL; }
"<div "                     { return START_DIV; }
"</div>"                    { return END_DIV; }
">"                         { return GT; }

"charset="                  { return CHARSET_ATTR; }
"name="                     { return NAME_ATTR; }
"content="                  { return CONTENT_ATTR; }
"href="                     { return HREF_ATTR; }
"src="                      { return SRC_ATTR; }
"alt="                      { return ALT_ATTR; }
"type="                     { return TYPE_ATTR; }
"value="                    { return VALUE_ATTR; }
"for="                      { return FOR_ATTR; }
"style="                    { return STYLE_ATTR; }
"width="                    { return WIDTH_ATTR; }
"height="                   { return HEIGHT_ATTR; }

{DQUOTE}[^"]*{DQUOTE}       {
    yylval.str = strdup(yytext);
    return QUOTED_TEXT;
}

{SQUOTE}[^']*{SQUOTE}       {
    yylval.str = strdup(yytext);
    return QUOTED_TEXT;
}

{POSITIVE_INT}              {
    yylval.intval = atoi(yytext);
    return POSITIVE_INT;
}

{TEXTDATA}                  {
    yylval.str = strdup(yytext);
    return TEXT;
}

{WHITESPACE}                {           }

.                           { printf("Unknown token: %s\n", yytext); }

%%