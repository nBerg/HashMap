X10C=${X10_HOME}/bin/x10c++
FLAGS=-VERBOSE_CHECKS=TRUE -O -NO_CHECKS -noassert -cxx-prearg -O2
SRCS= SerialFunctionTest.x10 SerialPerformanceTest.x10 HashMap.x10
EXES=$(SRCS:.x10=)


perftests: SerialPerformanceTest.x10 HashMap.x10
	$(X10C) $(FLAGS) -o SerialPerformanceTest SerialPerformanceTest.x10
	./SerialPerformanceTest 50000 10 16

functests: SerialFunctionTest.x10 HashMap.x10
	$(X10C) $(FLAGS) -o SerialFunctionTest SerialFunctionTest.x10
	./SerialFunctionTest
	

.SUFFIXES:
.SUFFIXES: .x10

clean:
	rm -f $(EXES) *.h *.cc
