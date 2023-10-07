#include "Includes/preprocessor.h"





#define ARGVMAX 100
#define LINESIZE 1024


/* makeargv - build an argv vector from words in a string
 * in: s points a text string with words
 * out: argv[] will point to all words in the string s (*s is modified!)
 * pre: array provided by caller: argv should be declared as char *argv[ARGVMAX]
 * return: number of words pointed to by argv (or -1 in case of error)
 */
int makeargv(char *s, char *argv[ARGVMAX]) {
    int ntokens = 0;

    if (s == NULL || argv == NULL || ARGVMAX == 0)
        return -1;
    argv[ntokens] = strtok(s, " \t\n");
    while ((argv[ntokens] != NULL) && (ntokens < ARGVMAX)) {
        ntokens++;
        argv[ntokens] = strtok(NULL, " \t\n");
    }
    argv[ntokens] = NULL; // it must terminate with NULL
    return ntokens;
}



int main(int argc, char ** argv){
	char cwd[LINESIZE];
	CWD(cwd,LINESIZE);


	return 0;
}
