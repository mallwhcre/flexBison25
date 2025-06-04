%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "checks.h"

void yyerror(const char *s);
int yylex(void);

extern int line_number;
extern int input_count_num;


%}

%union {
    char *str;
    int intval;
}

%token START_MYHTML END_MYHTML
%token START_HEAD END_HEAD
%token START_TITLE END_TITLE
%token START_META
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
%token <str> ID_ATTR
%token <intval>INPUT_COUNT

%type <str> text text_opt
%type <intval> input_count_opt

%start myhtml

%%

myhtml:
    START_MYHTML head_opt body END_MYHTML
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
    {
        if ($2 && strlen($2) > 60)
        {
            add_error(line_number, title_err);
        }
    }
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
    ID_ATTR QUOTED_TEXT
    {
        if (!check_id($2))
        {
            add_error(line_number, id_err);

        }
        else 
        {
            insert_id($1);
        }
    }
    | STYLE_ATTR QUOTED_TEXT ID_ATTR QUOTED_TEXT
    {
        if (!check_id($3))
        {
            add_error(line_number, id_err);

        }
        else
        {
            insert_id($3);
        }
    }
    | ID_ATTR QUOTED_TEXT STYLE_ATTR QUOTED_TEXT
    {
        if (!check_id($2))
        {
            add_error(line_number, id_err);

        }
        else
        {
            insert_id($2);
        }
    }
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
    {
        if (!is_valid_style($2))
        {
            add_error(line_number, style_err);
        }
    }
    ;

a:
    START_A a_attr GT a_content_list END_A
    ;

a_attr:
    HREF_ATTR QUOTED_TEXT ID_ATTR QUOTED_TEXT
    {
        if (!check_id($4))
        {
            add_error(line_number, id_err);

        }
        else
        {
            insert_id($4);
        }

        if (!is_valid_href($2))
        {
            add_error(line_number, href_err);

        }
    }
    | ID_ATTR QUOTED_TEXT HREF_ATTR QUOTED_TEXT
    {
        if (!check_id($2))
        {
            add_error(line_number, id_err);

        }
        else
        {
            insert_id($2);
        }

        if (!is_valid_href($4))
        {
            add_error(line_number, href_err);

        }

    }
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
    {
        if (!is_url($3))
        {
            add_error(line_number, src_err);

        }
    }
    ;

img_opt_attr:
    /* nothing */
    | WIDTH_ATTR POSITIVE_INT HEIGHT_ATTR POSITIVE_INT
    | HEIGHT_ATTR POSITIVE_INT WIDTH_ATTR POSITIVE_INT
    ;

form:
    START_FORM form_attr input_count_opt GT form_content_list END_FORM
    {
        if (get_checkbox_counter() > 0)
        {
            if ($3 != get_checkbox_counter())
            {
                add_error(line_number, input_count_err);
            }
        }

        else 
        {
            if ($3 != -1)
            {
                add_error(line_number, input_count_used_err);
            }
        }
    }
    ;

input_count_opt:
    {$$ = -1;}
    | INPUT_COUNT POSITIVE_INT
    {$$ = $2;}
    ;

form_attr:
    ID_ATTR QUOTED_TEXT
    {
        if (!check_id($2))
        {
            add_error(line_number, id_err);

        }
        else
        {
            insert_id($2);
        }
    }
    | STYLE_ATTR QUOTED_TEXT ID_ATTR QUOTED_TEXT
    {
        if (!check_id($4))
        {
            add_error(line_number, id_err);

        }
        else
        {
            insert_id($4);
        }
    }
    | ID_ATTR QUOTED_TEXT STYLE_ATTR QUOTED_TEXT
    {
        if (!check_id($2))
        {
            add_error(line_number, id_err);

        }
        else
        {
            insert_id($2);
        }
    }
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
    START_INPUT input_attrs input_opt_attr GT
    ;

input_attrs:
    ID_ATTR QUOTED_TEXT TYPE_ATTR QUOTED_TEXT
    {
        if (!check_id($2)) //if id already exists add an error
        {
            add_error(line_number, id_err);

        }

        else //else insert id to both general id array and input id array
        {
            insert_id($2);
            insert_input_id($2);
        }

        if (!type_is_valid($4))
        {
            add_error(line_number, type_err);

        }

        else
        {
            if (get_submit_found()) //if submit is already found in the file add an error
            {
                 add_error(line_number, type_err);

            }


            else if (strcmp($4, "submit") == 0)
            {

                set_submit_found(true); //set submit is found in the file
            }

            if (strcmp($4, "checkbox") == 0)
            {
                inc_checkbox_counter();
            }

            
        }
    }
    | TYPE_ATTR QUOTED_TEXT ID_ATTR QUOTED_TEXT
    {
        if (!check_id($4))
        {
            add_error(line_number, id_err);

        }

        else
        {
            insert_id($4);
            insert_input_id($4);
        }

        if (!type_is_valid($2))
        {
            add_error(line_number, type_err);

        }

        else
        {
            if (get_submit_found())
            {
                 add_error(line_number, type_err);

            }


            else if (strcmp($2, "submit") == 0)
            {

                set_submit_found(true);
            }

            if (strcmp($2, "checkbox") == 0)
            {
                inc_checkbox_counter();
            }

            
        }
    }
    ;

input_opt_attr:
    /* nothing */
    | VALUE_ATTR QUOTED_TEXT style_opt
    ;

label:
    START_LABEL FOR_ATTR QUOTED_TEXT style_opt GT text_opt END_LABEL
    {
        if (check_input_id($3))
        {
            add_error(line_number, for_err);

        }

        else 
        {
            insert_used_input_id($3);
        }
    }
    ;

div:
    START_DIV style_opt GT div_content_list END_DIV
    ;

div_content_list:
    /*nothing*/
    | div_content_list body_element
    ;

    

text:
    TEXT { $$ = $1; }
    ;

text_opt:
    /*nothing*/ { $$ = NULL; }
    | text { $$ = $1; }
    ;

%%

void yyerror(const char *s) 
{
    printf("ERROR: Syntax is not correct at line %d\n", line_number);
}


