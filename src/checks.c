#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include "checks.h"

#define MAX_ERRORS 100
#define MAX_IDS 100
#define MAX_ID_LEN 100

static error_t error_stack[MAX_ERRORS];
static int error_pointer = 0;

static char id_array[MAX_IDS][MAX_ID_LEN];
static char input_id_array[MAX_IDS][MAX_ID_LEN];
static char used_input_id_array[MAX_IDS][MAX_ID_LEN];
static int id_count = 0;
static int input_id_count = 0;
static int used_input_id_count = 0;

static bool submit_type_found = false;

static const char *valid_properties[] = {
    "color",
    "background_color",
    "font_family",
    "font_size"};

static char *strip_quotes(char *str)
{
    size_t len = strlen(str);
    if (len >= 2 && str[0] == '"' && str[len - 1] == '"')
    {
        memmove(str, str + 1, len - 2);
        str[len - 2] = '\0';
    }

    return str;
}

static char *error_to_mesg(err_type_t err)
{

    switch (err)
    {
    case title_err:
        return "Title contains more than 60 characters";
        break;

    case id_err:
        return "ID is not unique";
        break;

    case href_err:
        return "HREF value is not valid";
        break;

    case src_err:
        return "SRC value is not valid";
        break;

    case type_err:
        return "Type attribute is not valid";
        break;

    case for_err:
        return "For label is not valid";
        break;

    case style_err:
        return "Style properties are not valid";
        break;
    }
}

static bool is_valid_property(const char *prop)
{
    for (int i = 0; i < 4; i++)
    {
        if (strcmp(prop, valid_properties[i]) == 0)
        {
            return true;
        }
    }
    return false;
}

static bool is_valid_font_size(const char *value)
{
    if (!value || strlen(value) < 3)
    {
        return false;
    }

    int len = strlen(value);

    if (len >= 3 && strcmp(value + len - 2, "px") == 0)
    {
        len -= 2;
    }

    else if (len >= 2 && value[len - 1] == '%')
    {
        len -= 1;
    }

    else
    {
        return false;
    }

    for (int i = 0; i < len; i++)
    {
        if (value[i] < '0' || value[i] > '9')
        {
            return false;
        }
    }

    return true;
}

bool is_valid_style(char *str)
{
    strip_quotes(str);
    if (!str || strlen(str) == 0)
    {
        return false;
    }

    char temp[1000];
    strcpy(temp, str);

    if (strchr(temp, ';') == NULL)
    {

        char *colon = strchr(temp, ':');
        if (!colon)
        {
            return false;
        }

        *colon = '\0';
        char *property = temp;
        char *value = colon + 1;

        while (*property == ' ')
            property++;
        char *prop_end = property + strlen(property) - 1;
        while (prop_end > property && *prop_end == ' ')
        {
            *prop_end = '\0';
            prop_end--;
        }

        while (*value == ' ')
            value++;
        char *val_end = value + strlen(value) - 1;
        while (val_end > value && *val_end == ' ')
        {
            *val_end = '\0';
            val_end--;
        }

        if (!is_valid_property(property))
        {
            return false;
        }

        if (strlen(value) == 0)
        {
            return false;
        }

        if (strcmp(property, "font_size") == 0)
        {
            if (!is_valid_font_size(value))
            {
                return false;
            }
        }

        return true;
    }

    char *token = strtok(temp, ";");
    int property_count = 0;
    bool seen_properties[4] = {false};

    while (token != NULL)
    {

        if (strlen(token) == 0)
        {
            token = strtok(NULL, ";");
            continue;
        }

        property_count++;
        if (property_count > 4)
        {
            return false;
        }

        char *colon = strchr(token, ':');
        if (!colon)
        {
            return false;
        }

        *colon = '\0';
        char *property = token;
        char *value = colon + 1;

        while (*property == ' ')
            property++;
        char *prop_end = property + strlen(property) - 1;
        while (prop_end > property && *prop_end == ' ')
        {
            *prop_end = '\0';
            prop_end--;
        }

        while (*value == ' ')
            value++;
        char *val_end = value + strlen(value) - 1;
        while (val_end > value && *val_end == ' ')
        {
            *val_end = '\0';
            val_end--;
        }

        if (!is_valid_property(property))
        {
            return false;
        }

        if (strlen(value) == 0)
        {
            return false;
        }

        if (strcmp(property, "font_size") == 0)
        {
            if (!is_valid_font_size(value))
            {
                return false;
            }
        }

        int prop_index = -1;
        for (int i = 0; i < 4; i++)
        {
            if (strcmp(property, valid_properties[i]) == 0)
            {
                prop_index = i;
                break;
            }
        }

        if (seen_properties[prop_index])
        {
            return false;
        }
        seen_properties[prop_index] = true;

        token = strtok(NULL, ";");
    }

    return true;
}

void set_submit_found(bool submit)
{
    submit_type_found = submit;
}

bool get_submit_found()
{
    return submit_type_found;
}

void add_error(int line_number, err_type_t err)
{
    error_pointer++;
    error_stack[error_pointer].line = line_number;
    error_stack[error_pointer].type = err;
}

void show_errors()
{
    while (error_pointer != 0)
    {
        printf("ERROR: %s at line %d\n", error_to_mesg(error_stack[error_pointer].type), error_stack[error_pointer].line);
        error_pointer--;
    }
}

bool check_id(char *id)
{
    // printf("checking %s", id);

    strip_quotes(id);
    for (int i = 0; i < id_count; i++)
    {
        if (strcmp(id, id_array[i]) == 0)
        {
            return false;
        }
    }

    return true;
}

bool check_input_id(char *id)
{
    strip_quotes(id);

    for (int i = 0; i < used_input_id_count; i++)
    {
        if (strcmp(id, used_input_id_array[i]) == 0)
        {
            return true;
        }
    }

    for (int i = 0; i < input_id_count; i++)
    {
        if (strcmp(id, input_id_array[i]) == 0)
        {
            return false;
        }
    }

    return true;
}

void insert_id(char *id)
{
    strip_quotes(id);
    strcpy(id_array[id_count], id);
    id_count++;
}

void insert_input_id(char *id)
{
    strip_quotes(id);
    strcpy(input_id_array[input_id_count], id);
    input_id_count++;
}

void insert_used_input_id(char *id)
{
    strip_quotes(id);
    strcpy(used_input_id_array[used_input_id_count], id);
    used_input_id_count++;
}

bool is_url(char *url)
{
    strip_quotes(url);
    if (strncmp(url, "http://", 7) == 0 || strncmp(url, "https://", 8) == 0 || strncmp(url, "./", 2) == 0 || strncmp(url, "../", 3) == 0)
    {
        return true;
    }

    return false;
}

bool is_valid_href(char *href)
{
    strip_quotes(href);
    if (is_url(href) || (href[0] == '#' && !check_id(href + 1)))
    {
        return true;
    }

    return false;
}

bool type_is_valid(char *type)
{
    strip_quotes(type);
    return (strcmp(type, "text") == 0 || strcmp(type, "checkbox") == 0 || strcmp(type, "radio") == 0 || strcmp(type, "submit") == 0);
}
