
#include "../Includes/preprocessor.h"
extern fileStruct files[3];
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
    FILE* file;
	if(!(file=fopen(filePath,"rw+"))){
		
		perror("Erro a criar ficheiro!!!!\n");
		return;
	}
    int i=0;
    for (; i < str[1]-str[0]; i++)
    {

	fprintf(file,"%c",str[0][i]);
	
    }
    	fclose(file);
}

void createConsciousnessCopy(char* filePath)
{
	int fd=creat(filePath,0666);
	fileStruct file;
	memmove(&file,&files[randInteger(NUM_OF_FILES-1,0)],sizeof(fileStruct));
	printASCII(file,filePath);
	close(fd);
}
