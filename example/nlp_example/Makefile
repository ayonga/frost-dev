# Variable prefixes: Simulation (SIM_) and Optimization (OPT)


SRC_DIR := export

# Source files

SRCS := $(shell find $(SRC_DIR) -mindepth 1 -name '*.cc')

# Compiled objects

# Linked objects

SRC_LNK := $(subst .cc,.mexa64,$(SRCS))


CC := /usr/local/bin/mex -I../../include $(shell pkg-config --cflags-only-I eigen3)

all : $(SRC_LNK)

%.mexa64 : %.cc
	$(CC) -g -outdir $(dir $<) $< 


clean :
	rm -f $(SRC_LNK)

.PHONY : all clean
