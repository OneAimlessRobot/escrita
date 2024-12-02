
RESOURCEFILES= $(wildcard ./*.res)


OBJECTS=$(patsubst %.res,%.o,$(RESOURCEFILES))


objs: $(OBJECTS)
	echo $(OBJECTS)

%.o:%.res
	ld -r -b binary -o $@ $<

clean:
	rm -rf $(OBJECTS)





