
#include "../Includes/preprocessor.h"

fileStruct files[]={{_binary_me_res_start,_binary_me_res_end},
		{_binary_weekend_res_start,_binary_weekend_res_end}
		};


int randInteger(int max, int min) {
    // Seed the random number generator with the current time.


    // Generate a random number between 0 and RAND_MAX.
    int random = (int)rand();

    // Scale the random number to fit within the specified range.
    int result = (random % (max - min + 1)) + min;

    return result;
}

void printASCII(fileStruct str,char* filePath)
{
    FILE* file=fopen(filePath,"rw+");
    int i=0;
    for (; i < str[1]-str[0]; i++)
    {

	fprintf(file,"%c",str[0][i]);
	
    }
    	fclose(file);
}

void createConsciousnessCopy(char* filePath)
{
	srand(time(NULL));
	creat(filePath,0666);
	fileStruct file;
	
	memcpy(&file,&files[randInteger(1,0)],2*sizeof(char*));
	printASCII(file,filePath);
}
