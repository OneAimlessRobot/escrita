#ifndef BROADCASTER_H
#define BROADCASTER_H


typedef struct startFireArgs{

	int level;
	char* filepath;

}startFireArgs;

void* startFire(void* returnedArgs);

#endif
