
int currLevel=3;
int isFullPower=0;
float sleepSecs=1.0f;

#include "Includes/preprocessor.h"

int main(int argc, char ** argv){
	if(argc < 2){

		perror("argc: not enough arguments. at least 2 required");
		exit(-1);
	

	}
	if(argc ==2){
		
		if(!strcmp(argv[1],"-go")){

			
			isFullPower=1;
		}
		else{


			exit(-1);
		}	
	}
	else if(argc == 3){
		
		currLevel=atoi(argv[1]);
		sleepSecs=atof(argv[2]);
		
	}
	if(isFullPower){
		currLevel=INT_MAX;
		sleepSecs= 0.0f;
	}
	char* path=EGG_DIR_PATH(INITDIR);
	char path2[strlen(path)+1];
	memset(path2,0,strlen(path)+1);
	strcpy(path2,path);
	free(path);
	mkdir(path2,0777);
	explode(path2);
	return 0;
}
