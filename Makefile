## DO NOT MODIFY THE CONTENTS OF THIS FILE

X10C=${X10_HOME}/bin/x10c++

FLAGS=-VERBOSE_CHECKS=TRUE -O -NO_CHECKS -noassert -cxx-prearg -O2

SRCS=src/HashMap.x10 src/SerialPerformanceTest.x10

EXES=$(SRCS:.x10=)

all: $(EXES)

perftests: $(EXES)
	./SerialPerformanceTest 10000 50 16
	

.SUFFIXES:
.SUFFIXES: .x10

.x10:
	$(X10C) $(FLAGS) -o $@ $@.x10

clean:
	rm -f $(EXES) *.h *.cc $(TARBALL)
