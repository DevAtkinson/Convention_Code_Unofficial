DEF	= -D_LINUX 

CC = g++ -Wall $(DEF) -Wno-unknown-pragmas
ifdef DEBUG
CC += -g
endif

# 32 or 64 bit
LBITS := $(shell getconf LONG_BIT)

OBJPATH = linux$(LBITS)

CODE = zlib/adler32.o zlib/compress.o zlib/deflate.o zlib/infblock.o zlib/infblock.o zlib/infcodes.o zlib/infutil.o zlib/trees.o zlib/uncompr.o zlib/zutil.o

all:	ReadIMX.o ReadIM7.o Read_Examples.o LabViewInterface.o
	cd zlib; make
	$(CC) $(OBJPATH)/*.o -o ReadIMX 

clean:
	@rm -f $(OBJPATH)/*.o

%.o:	%.cpp
	@mkdir -p $(OBJPATH)
	@if [  $*.cpp -nt $(OBJPATH)/${notdir $*}.o  -o  ! -e $(OBJPATH)/${notdir $*}.o  ] ; then \
		echo Compiling $*.cpp ... ; \
		$(CC) -c -o $(OBJPATH)/${notdir $*}.o $*.cpp ; \
	fi
