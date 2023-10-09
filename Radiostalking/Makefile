
LDLIBS = -lm -pthread -lpthread
SDLLIBS = `pkg-config --libs   SDL2_mixer`
SDLLIBS += `pkg-config --libs  sdl2` $(LDLIBS)
INCLUDE= ./Includes .
BINARY=Radiostalking.exe

SOURCES= . ./Sources
RESDIR= ./resources


FULL = -DA_CODE  -DNON_COMPAT_CODE $(SDLLIBS)
NON_AUDIO = -DNON_COMPAT_CODE $(LDLIBS)
COMPAT = $(LDLIBS)

MODE = $(COMPAT)

CURRDIR=echo `pwd`

CC= gcc

DEPFLAGS= -MP -MD

CFLAGS= -Wall -DPROGRAMPATHAUX="$(CURRDIR)" $(MODE)  -Wextra -g $(foreach D, $(INCLUDE), -I$(D)) $(DEPFLAGS)

SOURCEFILES=$(foreach D,$(SOURCES), $(wildcard $(D)/*.c))

RESOURCEFILES=$(foreach D,$(RESDIR), $(wildcard $(D)/*.res))



OBJECTS=$(patsubst %.c,%.o,$(SOURCEFILES))

RESOBJECTS=$(patsubst %.res,%.o,$(RESOURCEFILES))

ALLMODULES= $(RESOBJECTS) $(OBJECTS)

DEPFILES= $(patsubst %.c,%.d,$(SOURCEFILES))


all: $(BINARY)
	echo $(LDLIBS)
	echo $(CURRDIR)


$(BINARY): $(ALLMODULES)
	$(CC) -g -v  $(CFLAGS) -o  $@ $^ $(MODE)


%.o:%.c
	$(CC) -g  $(CFLAGS) -c -o $@ $<
	echo $(CFLAGS)
clean:
	rm -rf $(BINARY) $(ALLMODULES) $(DEPFILES)
