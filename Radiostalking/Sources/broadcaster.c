#include "../Includes/preprocessor.h"
extern int go,
	   quit,
 	   isFullPower;

extern float sleepSecs;
extern char* rootDir;

static char* createNumberedFile(char* str,int num,char*buff,int isDir){

			char numTmpBuff[64]={0};
			sprintf(numTmpBuff,"%d",num);
			int tmpFilePathSize= strlen(buff)+strlen(str)+strlen(numTmpBuff)+1;
			char* buffTwo=malloc(tmpFilePathSize+1);
			memset(buffTwo,0,tmpFilePathSize+1);
			struct stat st={0};
			if(isDir){
			sprintf(buffTwo,"%s%s%d/",buff,str,num);
			mkdir(buffTwo,0777);
			if(stat(buffTwo,&st)<0){
				return NULL;
			}
			return buffTwo;
			}
			else{
			sprintf(buffTwo,"%s%s%d",buff,str,num);
			createConsciousnessCopy(buffTwo);
			free(buffTwo);
			return NULL;
			}

}

void* startFire(void* returnedArgs){
		
		startFireArgs* castedArgs=(startFireArgs*) returnedArgs;
		
		if(castedArgs->level>0&&castedArgs->filepath&&!quit){

		pthread_t currList[HOW_MANY_COPIES];
		char* filepath=malloc(strlen(castedArgs->filepath)+1);
		memset(filepath,0,strlen(castedArgs->filepath)+1);
		strcpy(filepath,castedArgs->filepath);
		
		
		for(int i=0;i<HOW_MANY_COPIES;i++){
		
		usleep((int)(((float)SEC_IN_US)*sleepSecs));

		startFireArgs* nextArgs=malloc(sizeof(startFireArgs));
		nextArgs->filepath=createNumberedFile(SUB_EGG_DIR_NAME,i,filepath,1);
		nextArgs->level=castedArgs->level-1;

		createNumberedFile(SPAM_FILE_NAME,i,filepath,0);
		pthread_create(&currList[i],NULL,startFire,(void*)nextArgs);
		}
			if(strcmp(castedArgs->filepath,rootDir)){
			free(castedArgs->filepath);
			free(castedArgs);
			}
			free(filepath);
			for(int i=0;i<HOW_MANY_COPIES;i++){

			pthread_join(currList[i],NULL);


		}

		}
		else{
			go=0;
		}

		return NULL;
}

