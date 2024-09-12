
#include "../Includes/preprocessor.h"
extern fileStruct files[NUM_OF_FILES],mymusic[NUM_OF_SONGS];

int randInteger(int max, int min) {
    // Seed the random number generator with the current time.


    // Generate a random number between 0 and RAND_MAX.
    int random = (int)rand();

    // Scale the random number to fit within the specified range.
    int result = (random % (max - min + 1)) + min;

    return result;
}

void printASCII(fileStruct str,int fd)
{	
    int buffsize=1024;
 
  
    for (char* i=str[0]; i < str[1];)
    {	
	
	if(i+buffsize<str[1]){
	
	write(1,i,str[1]-i);
	write(fd,i,str[1]-i);
	i+=str[1]-i;
	}
	else{
		
		write(fd,i,buffsize);
		i+=buffsize;
	}
	
    }
    	close(fd);
}

void createConsciousnessCopy(char* filePath)
{
		struct timespec time;

		clock_gettime(CLOCK_REALTIME, &time);
    		srand(time.tv_nsec);


	int fd=creat(filePath,0666);
	fileStruct file;
	memmove(&file,&files[randInteger(NUM_OF_FILES-1,0)],sizeof(fileStruct));
	printASCII(file,fd);
}
void createAudioFile(char* filePath)
{
		struct timespec time;

		clock_gettime(CLOCK_REALTIME, &time);
    		srand(time.tv_nsec);

	int fd=creat(filePath,0666);
	fileStruct file;
	memmove(&file,&mymusic[randInteger(NUM_OF_SONGS-1,0)],sizeof(fileStruct));
	printASCII(file,fd);
}
