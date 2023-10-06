#include "../Includes/preprocessor.h"
extern int currLevel;
extern float sleepSecs;

static char* createNumberedDir(char* str,int len,int num,char*buff,int isDir){

			char numTmpBuff[64]={0};
			sprintf(numTmpBuff,"%d",num);
			int tmpFilePathSize= len+strlen(str)+strlen(numTmpBuff)+1;
			char* buffTwo=malloc(tmpFilePathSize+1);
			memset(buffTwo,0,tmpFilePathSize+1);
			
			if(isDir){
			sprintf(buffTwo,"%s%s%d/",buff,str,num);
			mkdir(buffTwo,0777);
			return buffTwo;
			}
			else{
			sprintf(buffTwo,"%s%s%d",buff,str,num);
			createConsciousnessCopy(buffTwo);
			free(buffTwo);
			return NULL;
			}

}

void explode(char* buff){
		if(currLevel>0){
			spawnFiles(buff);
			currLevel--;
			startFire(buff);
		}
		else{
			exit(-1);
		}
}

void spawnFiles(char rootDir[1024]){

	int currPathLen=strlen(rootDir);
		for(int i=0;i<HOW_MANY_COPIES;i++){
		
			createNumberedDir("helpme",currPathLen,i,rootDir,0);
		}


}
void startFire(char*buff){

	int currPathLen=strlen(buff);
	
		char*path=NULL;
		for(int i=0;i<HOW_MANY_COPIES;i++){
			path=createNumberedDir("stopthis",currPathLen,i,buff,1);

        	char path2[strlen(path)+1];
       	 	memset(path2,0,strlen(path)+1);
        	strcpy(path2,path);
	        free(path);
		struct timespec start, end;

		clock_gettime(CLOCK_REALTIME, &start);
    		srand(start.tv_nsec);

			int pid= fork();
			usleep((int)(((float)SEC_IN_US)*sleepSecs));
				switch(pid){

					case -1:
						perror("Erro no fork\n");
						exit(-1);

					case 0:
						explode(path2);
						return;
					default:
						wait(NULL);
						break;
					}
		
			
			}

		}



/*
void multiply(char* rootDir){
struct stat st= {0};
	if(stat(rootDir, &st)==-1){
		mkdir(rootDir,0777);
	}
	char retDirPath[strlen(rootDir)+1+strlen(EGG_DIR_NAME)];
	memset(cdirpath,0,strlen(rootDir)+1);
	memset(retDirPath,0,strlen(rootDir)+1+strlen(EGG_DIR_NAME));
	sprintf(retDirPath,"%s/%s",cdirpath,EGG_DIR_NAME);

	int pid=fork();
	switch(pid){
		case -1:
			perror("Erro a forkar em multiply");
			exit(-1);
			
		case 0:
			
			startFire(recDirPath);
			
		break;
		default:
		
			
	
		break;

	}
}
*/
