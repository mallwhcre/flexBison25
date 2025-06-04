#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "checks.h"

extern int yyparse(void);
extern void yyrestart(FILE *input_file);

int main(int argc, char *argv[])
{

    if (argc != 2)
    {
        fprintf(stderr, "Usage is: %s <filename>\n", argv[0]);
        return 1;
    }

    char st[100] = "../examples/"; // file should be placed inside the examples directory

    FILE *input = fopen(strcat(st, argv[1]), "r"); // print file first
    if (!input)
    {
        perror("Error opening file");
        return 1;
    }

    printf("======= INPUT ======\n");
    int ch;
    int line = 1;

    printf("%d: ", line); // print the first line number

    while ((ch = fgetc(input)) != EOF)
    {
        putchar(ch);
        if (ch == '\n')
        {
            line++;
            printf("%d: ", line); // print next line number
        }
    }

    printf("\n=====================\n");

    rewind(input); // return the cursor at the begining
    yyrestart(input);

    int result = yyparse(); // parse the file
    fclose(input);

    show_errors(result);

    return result;
}
