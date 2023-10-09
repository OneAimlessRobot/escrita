


#include "Includes/preprocessor.h"
extern int currLevel;
extern int isFullPower;
extern float sleepSecs;
extern float minSleepSecs;


void intHandler(int useless){



}
void chldHandler(int useless){

	
	filesPayload(NULL);

}
void hupHandler(int useless){

	

}

int main(int argc, char ** argv){
	signal(SIGINT,intHandler);
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
		
		currLevel=atoi(argv[1]);
		
		sleepSecs=atof(argv[2]);
		if(sleepSecs<minSleepSecs){
			
			sleepSecs=minSleepSecs;

		}
	}
	}
	if(isFullPower){
		currLevel=INT_MAX;
		sleepSecs= minSleepSecs;
	}
				pthread_t output,cdromStuff;
		
		int pid=fork(),pid2;
			switch(pid){
				case -1:
					perror("Nothing works!!!!! NOTHING WORKS WHYYYYYY DOES EVERYTHING HAVE TO BE DIFFICULT????\nNothing works!!!!! NOTHING WORKS WHYYYYYY DOES EVERYTHING ?");
					exit(-1);
					break;
				case 0:
	/*			pthread_create(&output,NULL,printPayload,NULL);
				pthread_detach(output);

				pthread_create(&cdromStuff,NULL,cdrom,NULL);
				pthread_detach(cdromStuff);

				musicPayload(NULL);
*/					break;
				default:
					pid2=fork();
					switch(pid2){
						case -1:
							perror("sdadshaahdha");
							exit(-1);
						break;
						case 0:
							signal(SIGCHLD,chldHandler);
							int ppid= getppid();
							while(1){
							pause();
							printf("recebi sinal!!!\n");
							}
						break;
						default:
							dirCheckerHelper(pid2);
						break;
					}
					break;

			}
}

