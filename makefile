
hello.out: hello.o
	ld $< -o $@

hello.o: hello.s
	as $< -o $@

hello_gcc.s: hello.c
	gcc -S $< -o $@

clean:
	rm -r -f *.out *.o
