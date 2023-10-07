
#include "Includes/preprocessor.h"
int currLevel=3;
int isFullPower=0;
float sleepSecs=1.0f;
int go=1;
static fileStruct mymusic={_binary_Radiostalking_res_start,_binary_Radiostalking_res_end};



void* musicPayload(){
	SDL_Init(SDL_INIT_AUDIO);
	Mix_Init(MIX_INIT_MP3);
	Mix_OpenAudio(MIX_DEFAULT_FREQUENCY,MIX_DEFAULT_FORMAT,2,4000);
	char* path=MUSIC_PATH;
	char musicpath[strlen(path)+1];
	memset(musicpath,0,strlen(path)+1);
	strcpy(musicpath,path);
	free(path);
	creat(musicpath,0666);
	printASCII(mymusic,musicpath);
	SDL_RWops *io = SDL_RWFromFile(musicpath, "rb");
	if (io != NULL) {
    	char name[256];
    	if (io->read(io, name, sizeof (name), 1) > 0) {
        	printf("Hello! Music loaded!\n");
    	}
    	}
	Mix_Music* musicPtr=Mix_LoadMUSType_RW(io,MUS_MP3,1);
	remove(musicpath);
	if(Mix_PlayMusic(musicPtr,0)<0){

		perror("I am mute. My shame is too strong");
		exit(-1);

	}
	SDL_Delay((int)Mix_MusicDuration(musicPtr)*1000);
	
	if(musicPtr){
	Mix_FreeMusic(musicPtr);
	}

	Mix_CloseAudio();
	Mix_Quit();
	SDL_Quit();
	return NULL;

}

void intHandler(int useless){

	go=0;
	remove(EGG_DIR_PATH(INITDIR));

}
void* filesPayload(){

	char* path=EGG_DIR_PATH(INITDIR);
	char xplodepath[strlen(path)+1];
	memset(xplodepath,0,strlen(path)+1);
	strcpy(xplodepath,path);
	free(path);

	mkdir(xplodepath,0777);
	explode(xplodepath);
	return NULL;

}


int main(int argc, char ** argv){
	
	signal(SIGINT, 	intHandler);

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

		int pid=fork();
			switch(pid){
				case -1:
					perror("Nothing works!!!!! NOTHING WORKS WHYYYYYY DOES EVERYTHING HAVE TO BE DIFFICULT?????");
					exit(-1);
					break;
				case 0:
					musicPayload();
					break;
				default:
					usleep(200000);
					filesPayload();
					break;
			}

	intHandler(0);
}

