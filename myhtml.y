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
    | NAME_ATTR QUOTED_TEXT CONTENT_ATTR QUOTED_TEXT
    ;


body:
    START_BODY body_content_list END_BODY
    ;

body_content_list:
    /* nothing */
    | body_content_list body_content
    ;

body_content:
    body_element
    ;

body_element:
    p
    | a
    | img 
    | form 
    | div 
    ;

p_opt:
    /* nothing */
    | p;

a_opt:
    /*nothing*/
    | a
    ;

img_opt:
    /*nothing*/
    | img;

form_opt:
    /*nothing*/
    | form
    ;


p:
    START_P style_opt GT END_P
    ;

style_opt:
    /* nothing */
    | STYLE_ATTR QUOTED_TEXT
    ;

a:
    START_A HREF_ATTR QUOTED_TEXT GT a_content END_A
    ;

a_content:
    /* nothing */
    | TEXT
    | img 
    | TEXT img
    | img TEXT
    ;

img:
    START_IMG SRC_ATTR QUOTED_TEXT ALT_ATTR QUOTED_TEXT img_opt_attr GT
    ;

img_opt_attr:
    /* nothing */
    | WIDTH_ATTR POSITIVE_INT HEIGHT_ATTR POSITIVE_INT
    ;

form:
    START_FORM style_opt GT form_content_list END_FORM
    ;

form_content_list:
    form_content_list form_content
    | form_content 
    ;

form_content:
    input
    | label 
    ;

input:
    START_INPUT TYPE_ATTR QUOTED_TEXT input_opt_attr GT
    ;

input_opt_attr:
    /* nothing */
    | VALUE_ATTR QUOTED_TEXT style_opt
    ;

label:
    START_LABEL FOR_ATTR QUOTED_TEXT style_opt GT text_opt END_LABEL
    ;

div:
    START_DIV style_opt GT p_opt a_opt img_opt form_opt END_DIV
    

text:
    TEXT
    ;

text_opt:
    /*nothing*/
    | TEXT
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

int main(void) {
    return yyparse();
}
