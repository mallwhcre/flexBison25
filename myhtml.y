%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void yyerror(const char *s);
int yylex(void);
%}

%union {
    char *str;
    int intval;
}

%token START_MYHTML END_MYHTML
%token START_HEAD END_HEAD
%token START_TITLE END_TITLE
%token START_META TAG_CLOSE
%token START_BODY END_BODY
%token START_P END_P
%token START_A END_A
%token START_IMG
%token START_FORM END_FORM
%token START_INPUT
%token START_LABEL END_LABEL
%token START_DIV END_DIV
%token COMMENT_START COMMENT_TEXT COMMENT_END
%token CHARSET_ATTR NAME_ATTR CONTENT_ATTR
%token HREF_ATTR SRC_ATTR ALT_ATTR
%token TYPE_ATTR VALUE_ATTR FOR_ATTR
%token STYLE_ATTR WIDTH_ATTR HEIGHT_ATTR
%token <str> QUOTED_TEXT TEXT
%token <intval> POSITIVE_INT
%token GT

%%

myhtml:
    START_MYHTML head_opt body END_MYHTML
    ;

head_opt:
    /*nothing*/
    | head
    ;

head:
    START_HEAD title meta_list END_HEAD
    ;

title:
    START_TITLE text END_TITLE
    ;

meta_list:
    /* nothing */
    | meta_list meta
    ;

meta:
    START_META meta_attr_group GT
    ;

meta_attr_group:
    CHARSET_ATTR QUOTED_TEXT
    ;


body:
    START_BODY END_BODY
    ;

text:
    TEXT
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

int main(void) {
    return yyparse();
}
