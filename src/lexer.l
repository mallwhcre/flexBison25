%{
#include "parser.h"
#include <string.h>
#include <stdio.h>

#define debug_token(tok)

int line_number = 1;
int input_count_num = 0;
%}

%option noyywrap

%x COMMENT

DQUOTE \"
SQUOTE \'
POSITIVE_INT [1-9][0-9]*|[0-9]
WHITESPACE [ \t\r]+
TEXTDATA [a-zA-Z][^"<>\n=]+
COMMENT_BODY ([^-]|(-[^-]))*

%%


"<!--"                      { BEGIN(COMMENT); debug_token("COMMENT_START"); return COMMENT_START; }
<COMMENT>{COMMENT_BODY}     { yylval.str = strdup(yytext); debug_token("COMMENT_TEXT"); return COMMENT_TEXT; }
<COMMENT>"-->"              { BEGIN(INITIAL); debug_token("COMMENT_END"); return COMMENT_END; }

"<MYHTML>"                  { debug_token("START_MYHTML"); return START_MYHTML; }
"</MYHTML>"                 { debug_token("END_MYHTML"); return END_MYHTML; }
"<head>"                    { debug_token("START_HEAD"); return START_HEAD; }
"</head>"                   { debug_token("END_HEAD"); return END_HEAD; }
"<title>"                   { debug_token("START_TITLE"); return START_TITLE; }
"</title>"                  { debug_token("END_TITLE"); return END_TITLE; }
"<body>"                    { debug_token("START_BODY"); return START_BODY; }
"</body>"                   { debug_token("END_BODY"); return END_BODY; }
"</p>"                      { debug_token("END_P"); return END_P; }
"</a>"                      { debug_token("END_A"); return END_A; }
"</form>"                   { debug_token("END_FORM"); return END_FORM; }
"</label>"                  { debug_token("END_LABEL"); return END_LABEL; }
"</div>"                    { debug_token("END_DIV"); return END_DIV; }

"<p>"                       { debug_token("START_P"); return START_P; }
"<p "                       { debug_token("START_P"); return START_P; }
"<a "                       { debug_token("START_A"); return START_A; }
"<img "                     { debug_token("START_IMG"); return START_IMG; }
"<form>"                    { debug_token("START_FORM"); return START_FORM; }
"<form "                    { debug_token("START_FORM"); return START_FORM; }
"<input "                   { debug_token("START_INPUT"); return START_INPUT; }
"<label "                   { debug_token("START_LABEL"); return START_LABEL; }
"<div>"                     { debug_token("START_DIV"); return START_DIV; }
"<div "                     { debug_token("START_DIV"); return START_DIV; }
"<meta "                    { debug_token("START_META"); return START_META; }

">"                         { debug_token("GT"); return GT; }

"charset="                  { debug_token("CHARSET_ATTR"); return CHARSET_ATTR; }
"name="                     { debug_token("NAME_ATTR"); return NAME_ATTR; }
"content="                  { debug_token("CONTENT_ATTR"); return CONTENT_ATTR; }
"href="                     { debug_token("HREF_ATTR"); return HREF_ATTR; }
"src="                      { debug_token("SRC_ATTR"); return SRC_ATTR; }
"alt="                      { debug_token("ALT_ATTR"); return ALT_ATTR; }
"type="                     { debug_token("TYPE_ATTR"); return TYPE_ATTR; }
"value="                    { debug_token("VALUE_ATTR"); return VALUE_ATTR; }
"for="                      { debug_token("FOR_ATTR"); return FOR_ATTR; }
"style="                    { debug_token("STYLE_ATTR"); return STYLE_ATTR; }
"width="                    { debug_token("WIDTH_ATTR"); return WIDTH_ATTR; }
"height="                   { debug_token("HEIGHT_ATTR"); return HEIGHT_ATTR; }
"id="                       {return ID_ATTR;}
"input_count="              {return INPUT_COUNT;}


{DQUOTE}[^"]*{DQUOTE}       {
    yylval.str = strdup(yytext);
    debug_token("QUOTED_TEXT");
    return QUOTED_TEXT;
}

{SQUOTE}[^']*{SQUOTE}       {
    yylval.str = strdup(yytext);
    debug_token("QUOTED_TEXT");
    return QUOTED_TEXT;
}

{POSITIVE_INT}              {
    yylval.intval = atoi(yytext);
    debug_token("POSITIVE_INT");
    return POSITIVE_INT;
}

{TEXTDATA}                  {
    yylval.str = strdup(yytext);
    debug_token("TEXT");
    return TEXT;
}

{WHITESPACE}                { /* skip whitespace */ }

\n                          {line_number++;} //increment a variable to know the number of the line




%%
