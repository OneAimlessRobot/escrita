BINARY= Radiostalking

LDLIBS=  -lm -lpthread
INCLUDE= ./Includes .
SOURCES= . ./Sources
RESDIR= ./resources
 
CURRDIR=echo `pwd`
 
CC= gcc
DEPFLAGS= -MP -MD

CFLAGS= -Wall -DPROGRAMPATHAUX="$(CURRDIR)"  -Wextra -g $(foreach D, $(INCLUDE), -I$(D)) $(DEPFLAGS) `sdl2-config --libs`

SOURCEFILES=$(foreach D,$(SOURCES), $(wildcard $(D)/*.c))

RESOURCEFILES=$(foreach D,$(RESDIR), $(wildcard $(D)/*.res))


RESOURCEFILES=$(wildcard $(RESDIR)/*.o)


RESBINS=$(patsubst %.res,%.o,$(RESOURCEFILES))

OBJECTS=$(patsubst %.c,%.o,$(SOURCEFILES))

ALLMODULES= $(RESBINS) $(OBJECTS)

DEPFILES= $(patsubst %.c,%.d,$(SOURCEFILES))

all: $(BINARY)
	echo $(LDLIBS)
	echo $(CURRDIR)


$(BINARY): $(ALLMODULES)
	make -C $(RESDIR)
	$(CC) -g -v  $(CFLAGS) -o  $@ $^  $(LDLIBS)


%.o:%.c
	$(CC) -g  $(CFLAGS) -c -o $@ $<  $(LDLIBS)
	echo $(CFLAGS)

clean:
	rm -rf $(BINARY) $(ALLMODULES) $(DEPFILES)
