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
#include "fileCopier.h"
#define CWD(buff,size) (strcat(getcwd(buff,size),"\n"))
