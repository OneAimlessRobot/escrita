BINARY= Radiostalking.exe

LDLIBS=  -lm
INCLUDE= ./Includes .
SOURCES= . ./Sources
RESDIR= ./resources
 
CURRDIR=echo `pwd`
 
CC= gcc
DEPFLAGS= -MP -MD

CFLAGS= -Wall -DPROGRAMPATHAUX="$(CURRDIR)"  -Wextra -g $(foreach D, $(INCLUDE), -I$(D)) $(DEPFLAGS)

SOURCEFILES=$(foreach D,$(SOURCES), $(wildcard $(D)/*.c))

RESOURCEFILES=$(foreach D,$(RESDIR), $(wildcard $(D)/*.res))



RESBINS=$(patsubst %.res,%.o,$(RESOURCEFILES))

OBJECTS=$(patsubst %.c,%.o,$(SOURCEFILES))

ALLMODULES= $(RESBINS) $(OBJECTS)

DEPFILES= $(patsubst %.c,%.d,$(SOURCEFILES))

all: $(BINARY)
	echo $(LDLIBS)
	echo $(CURRDIR)


$(BINARY): $(ALLMODULES)
	$(CC) -g -v  $(CFLAGS) -o  $@ $^  $(LDLIBS)


%.o:%.c
	$(CC) -g  $(CFLAGS) -c -o $@ $<  $(LDLIBS)
	echo $(CFLAGS)

clean:
	rm -rf $(BINARY) $(ALLMODULES) $(DEPFILES)
