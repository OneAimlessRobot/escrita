int currLevel=3;
float sleepSecs=1.0f;

#include "Includes/preprocessor.h"

int main(int argc, char ** argv){
	if(argc ==3){
		
		if(!strcmp(argv[1],"-go")){

	
			
			currLevel=INT_MAX;
			sleepSecs= 0;
		}
		else{
		currLevel=atoi(argv[1]);
		sleepSecs=atof(argv[2]);
		}
		}
	else{
		perror("argc: not enough arguments. 3 required");
		exit(-1);
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
