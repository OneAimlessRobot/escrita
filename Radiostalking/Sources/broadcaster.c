#include "../Includes/preprocessor.h"
extern int currLevel;
extern float sleepSecs;
extern int isFullPower;
extern int go;
static char* createNumberedFile(char* str,int len,int num,char*buff,int isDir){

			char numTmpBuff[64]={0};
			sprintf(numTmpBuff,"%d",num);
			int tmpFilePathSize= len+strlen(str)+strlen(numTmpBuff)+1;
			char* buffTwo=malloc(tmpFilePathSize+1);
			memset(buffTwo,0,tmpFilePathSize+1);
			struct stat st={0};
			if(isDir){
			sprintf(buffTwo,"%s%s%d/",buff,str,num);
			mkdir(buffTwo,0777);
		/*	if(stat(buffTwo,&st)<0){
				memset(buffTwo,0,tmpFilePathSize+1);
				char* dir= EGG_DIR_PATH(INITDIR);
				
				strcpy(buffTwo,dir);
				
				free(dir);
				
				mkdir(buffTwo,0777);

			}
		*/	return buffTwo;
			}
			else{
			sprintf(buffTwo,"%s%s%d",buff,str,num);
			createConsciousnessCopy(buffTwo);
		/*	if(stat(buffTwo,&st)<0){
				memset(buffTwo,0,tmpFilePathSize+1);
				char* file= EGG_DIR_PATH(INITDIR);
				
				mkdir(file,0777);
				sprintf(buffTwo,"%s%s%d",file,str,num);
				
				free(file);
				createConsciousnessCopy(buffTwo);
				
			}
		*/	free(buffTwo);
			return NULL;
			}

}

void startFire(char*buff){
	
	int currPathLen=strlen(buff);
	
		char*path=NULL;
		if(currLevel>0){
		for(int i=0;i<HOW_MANY_COPIES;i++){
			path=createNumberedFile(SUB_EGG_DIR_NAME,currPathLen,i,buff,1);

        	char path2[strlen(path)+1];
       	 	memset(path2,0,strlen(path)+1);
        	strcpy(path2,path);
	        free(path);
		struct timespec start;

		clock_gettime(CLOCK_REALTIME, &start);
    		srand(start.tv_nsec);
			usleep((int)(((float)SEC_IN_US)*sleepSecs));
		
		


		int pid=fork();
		

		switch(pid){		
			
			case -1: perror("Nothing works. NOTHING WORKS! WHY DOES NOTHING WORK????!!!!!!!!!!!!!!!!!!!!Nothing works. NOTHING WORKS! WHY DOES NOTHING"); 
				exit(-1);
			case 0:	
				currLevel--;
				startFire(path2);
				break;
			default:
				
				createNumberedFile(SPAM_FILE_NAME,currPathLen,i,buff,0);
				break;
			}

		}
		}
		else{
			printf("Done!\n");
		}


}
