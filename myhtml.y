%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void yyerror(const char *s);
int yylex(void);
void yyrestart(FILE * input_file);
extern int line_number;
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
%token ID_ATTR

%%

myhtml:
    START_MYHTML head_opt body END_MYHTML
    ;

id:
    ID_ATTR QUOTED_TEXT
    ;

comment:
    COMMENT_START COMMENT_TEXT COMMENT_END
    ;

head_opt:
    /*nothing*/
    | head
    ;

head:
    START_HEAD title head_opt_list END_HEAD
    ;

head_opt_list:
    /*nothing*/
    | head_opt_list head_content
    ;

head_content:
    meta
    | comment
    ;

title:
    START_TITLE text_opt END_TITLE
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
    START_P p_attr GT p_contents_list END_P
    ;

p_attr:
    id
    | STYLE_ATTR QUOTED_TEXT id
    | id STYLE_ATTR QUOTED_TEXT
    ;

p_contents_list:
    /*nothing*/
    | p_contents_list p_contents
    ;

p_contents:
    TEXT 
    | comment
    ;

style_opt:
    /* nothing */
    | STYLE_ATTR QUOTED_TEXT
    ;

a:
    START_A a_attr GT a_content_list END_A
    ;

a_attr:
    HREF_ATTR QUOTED_TEXT id
    | id HREF_ATTR QUOTED_TEXT
    ;

a_content_list:
    comments_opt a_content comments_opt
    ;

a_content:
    TEXT
    | img 
    | TEXT img
    | img TEXT
    ;

comments_opt:
    /*nothing*/
    | comment
    ;

img:
    START_IMG SRC_ATTR QUOTED_TEXT ALT_ATTR QUOTED_TEXT img_opt_attr GT
    ;

img_opt_attr:
    /* nothing */
    | WIDTH_ATTR POSITIVE_INT HEIGHT_ATTR POSITIVE_INT
    | HEIGHT_ATTR POSITIVE_INT WIDTH_ATTR POSITIVE_INT
    ;

form:
    START_FORM form_attr GT form_content_list END_FORM
    ;

form_attr:
    id
    | STYLE_ATTR QUOTED_TEXT id
    | id STYLE_ATTR QUOTED_TEXT
    ;

form_content_list:
    form_content_list form_content comments_opt
    | comments_opt form_content comments_opt
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
    START_DIV style_opt GT div_content_list END_DIV

div_content_list:
    /*nothing*/
    | div_content_list body_element
    ;

    

text:
    TEXT
    ;

text_opt:
    /*nothing*/
    | text
    ;

%%

void yyerror(const char *s) {
}


int main(int argc, char *argv[]) {

    if (argc != 2)
    {
        fprintf(stderr, "Usage is: %s <filename>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        perror("Error opening file");
        return 1;
    }

    printf("======= INPUT ======\n");
    int ch;
    while ((ch = fgetc(input)) != EOF) {
        putchar(ch);
    }
    printf("\n=====================\n");

    rewind(input);
    yyrestart(input);

    int result = yyparse();
    fclose(input);

    if (result == 0)
    {
        printf("Program parsed successfully\n");
    }

    else 
    {
        printf("Syntax error on line %d\n", line_number);
    }

    return result;
}
