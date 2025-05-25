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
    /* empty */
    | head
    ;

head:
    START_HEAD title meta_list END_HEAD
    ;

title:
    START_TITLE text END_TITLE
    ;

meta_list:
    /* empty */
    | meta_list meta
    ;

meta:
    START_META meta_attr_group TAG_CLOSE
    ;

meta_attr_group:
    CHARSET_ATTR QUOTED_TEXT
    | NAME_ATTR QUOTED_TEXT CONTENT_ATTR QUOTED_TEXT
    ;

body:
    START_BODY body_content_list END_BODY
    ;

body_content_list:
    /* empty */
    | body_content_list body_content
    ;

body_content:
    body_element
    | comment
    ;

body_element:
    p
    | a
    | img
    | form
    | div
    ;

p:
    START_P style_attr_opt GT text_with_comments END_P
    ;

style_attr_opt:
    /* empty */
    | STYLE_ATTR QUOTED_TEXT
    ;

text_with_comments:
    /* empty */
    | text_with_comments text_or_comment
    ;

text_or_comment:
    TEXT
    | comment
    ;

a:
    START_A HREF_ATTR QUOTED_TEXT GT a_content END_A
    ;

a_content:
    /* empty */
    | TEXT
    | img
    | TEXT img
    | img TEXT
    ;

img:
    START_IMG img_attr_group TAG_CLOSE
    ;

img_attr_group:
    SRC_ATTR QUOTED_TEXT ALT_ATTR QUOTED_TEXT img_opt_attrs
    ;

img_opt_attrs:
    /* empty */
    | img_opt_attrs img_opt_attr
    ;

img_opt_attr:
    WIDTH_ATTR POSITIVE_INT
    | HEIGHT_ATTR POSITIVE_INT
    ;

form:
    START_FORM style_attr_opt GT form_content_list END_FORM
    ;

form_content_list:
    form_content
    | form_content_list form_content
    ;

form_content:
    input
    | label
    ;

input:
    START_INPUT TYPE_ATTR QUOTED_TEXT input_opt_attrs TAG_CLOSE
    ;

input_opt_attrs:
    /* empty */
    | input_opt_attrs input_opt_attr
    ;

input_opt_attr:
    VALUE_ATTR QUOTED_TEXT
    | STYLE_ATTR QUOTED_TEXT
    ;

label:
    START_LABEL FOR_ATTR QUOTED_TEXT style_attr_opt GT text_with_comments END_LABEL
    ;

div:
    START_DIV style_attr_opt GT body_content_list END_DIV
    ;

text:
    TEXT
    ;

comment:
    COMMENT_START COMMENT_TEXT COMMENT_END
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

int main(void) {
    return yyparse();
}