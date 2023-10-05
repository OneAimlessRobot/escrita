int currLevel=3;

#include "Includes/preprocessor.h"

int main(int argc, char ** argv){
	if(argc ==2){

	currLevel=atoi(argv[1]);
	}
	mkdir(EGG_DIR_PATH(INITDIR),0777);
	explode(EGG_DIR_PATH(INITDIR));
	return 0;
}
