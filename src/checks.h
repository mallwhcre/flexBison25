#ifndef CHECKS_H
#define CHECKS_H

#include <stdbool.h>

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

bool check_id(char *id);
bool check_input_id(char *id);
void insert_id(char *id);
void insert_input_id(char *id);
void insert_used_input_id(char *id);
bool is_url(char *url);
bool is_valid_href(char *href);
bool is_valid_style(char *style);
bool type_is_valid(char *type);

void add_error(int line_number, err_type_t err);
void show_errors();
void set_submit_found(bool submit);
bool get_submit_found();



#endif