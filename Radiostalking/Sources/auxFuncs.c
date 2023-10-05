
#include "../Includes/preprocessor.h"

void printASCII(const char *end, const char *start,char* filePath)
{
    FILE* file=fopen(filePath,"rw+");
    char buff[end-start+1];
    int i=0;
    for (; i < (end - start); i++)
    {

        buff[i]=start[i];
    }
    buff[i]='\0';
    fprintf(file,"%s",buff);
	close(file);
}

void createConsciousnessCopy(char* filePath)
{
	creat(filePath,0666);
	printASCII(_binary_me_res_end,_binary_me_res_start,filePath);
}
