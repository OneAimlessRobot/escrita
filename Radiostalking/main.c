

#include "Includes/preprocessor.h"
extern int maxLevel,
	isFullPower;

extern float sleepSecs;

char* rootDir;
int go=1,
	quit=0;
void intHandler(int useless){
       if(!isFullPower){
	printf("BORAEMBORA CARALHO!! ANDOR!!!!\n");
	quit=1;
	}

}

int main(int argc, char ** argv){
	if(argc ==1){


		char c;
		printf("Press Enter to leave reality\n");
		scanf("%c",&c);
		isFullPower=1;


	}
	else{
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
		
		maxLevel=atoi(argv[1]);
		
		sleepSecs=atof(argv[2]);
		if(sleepSecs<MIN_SLEEP_SECS){
			
			sleepSecs=MIN_SLEEP_SECS;

		}
	}
	}
	if(isFullPower){
		maxLevel=MAX_LEVELS-1;
		sleepSecs= MIN_SLEEP_SECS;
	}
		
		signal(SIGINT,intHandler);
		rootDir=EGG_DIR_PATH(INITDIR);
		pthread_t filesWorker, output,cdromStuff;

		
		
		int pid=fork();
			switch(pid){
				case -1:
					perror("Nothing works!!!!! NOTHING WORKS WHYYYYYY DOES EVERYTHING HAVE TO BE DIFFICULT????\nNothing works!!!!! NOTHING WORKS WHYYYYYY DOES EVERYTHING ?");
					exit(-1);
					break;
				case 0:

			
			#ifdef A_CODE
					musicPayload();
			#endif
					
						
				break;
				default:


			#ifdef RANDPRINTS
				pthread_create(&output,NULL,printPayload,NULL);
			#endif
			#ifdef NON_COMPAT_CODE
					pthread_create(&cdromStuff,NULL,cdrom,NULL);
			#endif
		

						if(isFullPower){
						
						int counter=0;
							while(counter<60+58){
							counter++;
							usleep(SEC_IN_US);
							}

						}
						pthread_create(&filesWorker,NULL,filesPayload,NULL);
						pthread_join(filesWorker,NULL);
			#ifdef RANDPRINTS
					
					pthread_join(output,NULL);
			#endif

			#ifdef NON_COMPAT_CODE
					pthread_join(cdromStuff,NULL);
			#endif


					break;

			}
			free(rootDir);
}

