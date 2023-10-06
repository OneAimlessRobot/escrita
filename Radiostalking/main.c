int currLevel=3;
int sleepSecs=1;

#include "Includes/preprocessor.h"

int main(int argc, char ** argv){
	srand(time(NULL));
	if(argc ==3){
		
		if(!strcmp(argv[1],"-go")){

	
			
			currLevel=INT_MAX;
			sleepSecs= 0;
		}
		else{
		currLevel=atoi(argv[1]);
		sleepSecs=atoi(argv[2]);
		}
		}
	else{
		perror("argc: not enough arguments. 3 required");
		exit(-1);
	}
	mkdir(EGG_DIR_PATH(INITDIR),0777);
	explode(EGG_DIR_PATH(INITDIR));
	return 0;
}
