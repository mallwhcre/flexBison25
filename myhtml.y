%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <string.h>
void yyerror(const char *s);
int yylex(void);
void yyrestart(FILE * input_file);
extern int line_number;

#define MAX_ERRORS 100
#define MAX_IDS 100
#define MAX_ID_LEN 100

typedef enum
{
    title_err,
    id_err,
    href_err,
    src_err,
    type_err,
    for_err,
    style_err
} err_type_t;

typedef struct
{
    int line;
    err_type_t type;
} error_t;

error_t error_stack[MAX_ERRORS];
int error_pointer = 0;

char id_array[MAX_IDS][MAX_ID_LEN];
int id_count = 0;

bool check_id(const char *id)
{
    for (int i = 0; i < id_count; i++)
    {
        if (strcmp(id, id_array[i]) == 0)
        {
            return false;
        }
    }

    return true;
}

void insert_id(const char *id)
{
    strcpy(id_array[id_count], id);
    id_count++;
}

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

%type <str> text text_opt

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
            error_pointer++;
            error_stack[error_pointer].line = line_number;
            error_stack[error_pointer].type = title_err;
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
        // printf("Checking id %s", $1);
        if (!check_id($2))
        {
            error_pointer++;
            error_stack[error_pointer].line = line_number;
            error_stack[error_pointer].type = id_err;
        }
        else 
        {
            insert_id($1);
        }
    }
    | STYLE_ATTR QUOTED_TEXT ID_ATTR QUOTED_TEXT
    {
        // printf("Checking id %s", $3);
        if (!check_id($3))
        {
            error_pointer++;
            error_stack[error_pointer].line = line_number;
            error_stack[error_pointer].type = id_err;
        }
        else
        {
            insert_id($3);
        }
    }
    | ID_ATTR QUOTED_TEXT STYLE_ATTR QUOTED_TEXT
    {
        // printf("Checking id %s", $2);
        if (!check_id($2))
        {
            error_pointer++;
            error_stack[error_pointer].line = line_number;
            error_stack[error_pointer].type = id_err;
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
    ;

a:
    START_A a_attr GT a_content_list END_A
    ;

a_attr:
    HREF_ATTR QUOTED_TEXT ID_ATTR QUOTED_TEXT
    {
        if (!check_id($4))
        {
            error_pointer++;
            error_stack[error_pointer].line = line_number;
            error_stack[error_pointer].type = id_err;
        }
        else
        {
            insert_id($4);
        }
    }
    | ID_ATTR QUOTED_TEXT HREF_ATTR QUOTED_TEXT
    {
        if (!check_id($2))
        {
            error_pointer++;
            error_stack[error_pointer].line = line_number;
            error_stack[error_pointer].type = id_err;
        }
        else
        {
            insert_id($2);
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
    ID_ATTR QUOTED_TEXT
    {
        if (!check_id($2))
        {
            error_pointer++;
            error_stack[error_pointer].line = line_number;
            error_stack[error_pointer].type = id_err;
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
            error_pointer++;
            error_stack[error_pointer].line = line_number;
            error_stack[error_pointer].type = id_err;
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
            error_pointer++;
            error_stack[error_pointer].line = line_number;
            error_stack[error_pointer].type = id_err;
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
    TEXT { $$ = $1; }
    ;

text_opt:
    /*nothing*/ { $$ = NULL; }
    | text { $$ = $1; }
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

    while (error_pointer != 0)
    {
        printf("Error %d at line %d\n", (int)error_stack[error_pointer].type, (int)error_stack[error_pointer].line);
        error_pointer--;

    }

    if (result == 0)
    {
        printf("Program has correct syntax\n");
    }

    else 
    {
        printf("Syntax error on line %d\n", line_number);
    }

    return result;
}
