X10C=${X10_HOME}/bin/x10c++
FLAGS=-VERBOSE_CHECKS=TRUE -O -NO_CHECKS -noassert -cxx-prearg -O2
SRCS= ParallelFunctionTest.x10 SerialFunctionTest.x10 HashMap.x10
EXES=$(SRCS:.x10=)

perftests: PerformanceTest.x10 HashMap.x10
	$(X10C) $(FLAGS) -o PerformanceTest PerformanceTest.x10
	./PerformanceTest 50000 10 16	

parfunc: ParFuncTest.x10 HashMap.x10
	$(X10C) $(FLAGS) -o ParFuncTest ParFuncTest.x10

functests: ParallelFunctionTest.x10 HashMap.x10
	$(X10C) $(FLAGS) -o ParallelFunctionTest ParallelFunctionTest.x10
	./ParallelFunctionTest

.SUFFIXES:
.SUFFIXES: .x10

clean:
	rm -f $(EXES) *.h *.cc
