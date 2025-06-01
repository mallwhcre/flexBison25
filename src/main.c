#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "checks.h"

extern int yyparse(void);
extern void yyrestart(FILE * input_file);


int main(int argc, char *argv[]) {

    if (argc != 2)
    {
        fprintf(stderr, "Usage is: %s <filename>\n", argv[0]);
        return 1;
    }

    char st[23] = "../";

    FILE *input = fopen(strcat(st, argv[1]), "r");
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

    show_errors(result);

    return result;
}
