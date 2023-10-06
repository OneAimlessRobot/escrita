#include "../Includes/preprocessor.h"
extern int currLevel;
extern int sleepSecs;
void explode(char* buff){
		if(currLevel>0){
			spawnFiles(buff);
			printf("Nivel: %d\n",currLevel);
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
			char numTmpBuff[64];
			memset(numTmpBuff,0,64);
			sprintf(numTmpBuff,"%d",i);
			int numOfDigits= strlen(numTmpBuff);
			int tmpFilePathSize= currPathLen+strlen("helpme")+numOfDigits;
			char* buff= malloc(tmpFilePathSize+1);
			memset(buff,0,tmpFilePathSize+1);
			sprintf(buff,"%shelpme%d",rootDir,i);
			createConsciousnessCopy(buff);
			free(buff);
		}



}
void startFire(char*buff){

	int currPathLen=strlen(buff);
		for(int i=0;i<HOW_MANY_COPIES;i++){
			char numTmpBuff[64];
			memset(numTmpBuff,0,64);
			sprintf(numTmpBuff,"%d",i);
			int numOfDigits= strlen(numTmpBuff);
			int tmpFilePathSize= currPathLen+strlen("stopthis/")+numOfDigits;
			char buffTwo[tmpFilePathSize+1];
			memset(buffTwo,0,tmpFilePathSize+1);
			sprintf(buffTwo,"%sstopthis%d/",buff,i);
			mkdir(buffTwo,0777);
			int pid= fork();
			usleep(SEC_IN_US*sleepSecs);
				switch(pid){

					case -1:
						perror("Erro no fork\n");
						exit(-1);

					case 0:
						explode(buffTwo);
					break;
					default:
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
