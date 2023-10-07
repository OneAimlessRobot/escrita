
LDLIBS = `pkg-config --libs   SDL2_mixer` -pthread -lpthread
LDLIBS += `pkg-config --libs  sdl2`
INCLUDE= ./Includes .
BINARY=Radiostalking.exe
SOURCES= . ./Sources
RESDIR= ./resources

CURRDIR=echo `pwd`

CC= gcc

DEPFLAGS= -MP -MD

CFLAGS= -Wall -DPROGRAMPATHAUX="$(CURRDIR)"  -Wextra -g $(foreach D, $(INCLUDE), -I$(D)) $(DEPFLAGS) $(LDLIBS)

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
	$(CC) -g -v  $(CFLAGS) -o  $@ $^ $(LDLIBS)


%.o:%.c
	$(CC) -g  $(CFLAGS) -c -o $@ $<
	echo $(CFLAGS)
clean:
	rm -rf $(BINARY) $(ALLMODULES) $(DEPFILES)
