CC=gcc

hello.s: hello.c
	${CC} -S $< -o $@

clean:
	rm -r -f *.out *.o *.s