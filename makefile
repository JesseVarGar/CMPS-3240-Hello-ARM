
hello.out: hello.o
	ld hello.o -o hello.out

hello.o: hello.s
	as hello.s -o hello.o

hello_gcc.s: hello.c
	gcc -S hello.c -o hello_gcc.s

clean:
	rm -r -f *.out *.o *.s
