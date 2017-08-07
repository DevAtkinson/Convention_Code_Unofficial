DEF = -D_LINUX

# CC = g++ -Wall $(DEF)
CC = gcc $(DEF)
ifdef DEBUG
CC += -g
endif

INC_D	= -I.. 

# 32 or 64 bit
LBITS := $(shell getconf LONG_BIT)

OBJPATH = ../linux$(LBITS)

CODE = adler32.o compress.o deflate.o infblock.o infcodes.o inffast.o inflate.o inftrees.o infutil.o trees.o uncompr.o zutil.o

all:	$(CODE)
	@exit

clean:
	@exit

dep:
	makedepend $(INC_D) $(DEF) *.c

%.o:
	@mkdir -p $(OBJPATH)
	@if [  $*.c -nt $(OBJPATH)/${notdir $*}.o  -o  ! -e $(OBJPATH)/${notdir $*}.o  ] ; then \
		echo Compiling $*.c ... ; \
		$(CC) -c -o $(OBJPATH)/${notdir $*}.o $*.c ; \
	fi
