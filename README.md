# CMPS-3240-Hello-ARM

The lab consists of two parts. Using `as` and `ld` to assemble and link ARM code respectively, and implementing a hello world program.

## Part 1 - Using GDB to View Contents of Registers

The first 'Hello world!' in this class is not printing a string at all. The idea of hello world is to view the output of a simple operation. However, with CPU architecture, we are operating at such an atomic level that we can view the effect our instructions are having on the processor itself. Here is the first program we will consider:

```arm
.section .text
.global _start
_start:
	mov x1, 7
	add x2, x1, x1
```

This code is located in `hello.s` in this repo. Line-by-line:

```arm
.section .text
```

This line is not an instruction at all. It is an assembler/linker directive that indicates this chunk of code should be placed in the part of memory for instructions. This next line:

```arm
.global _start
``` 

This is a directive that indicates the following code is associated with the function `_start`. This next line:

```arm
_start:
```

This is the first line that is not a directive. It is a label. It is not an instruction. It indicates the line that follows should be associated with the identifier `_start`.  By default, `_start` is the start of the program. When executing a program, the processor has a register (a special type of memory) that indicates which instruction to execute. This is called the *program counter*, and it is initialized to `_start`. The CPU has a finite number of registers and they are identified by specific names. Now consider this line:

```arm
mov x1, 7
```

This is the first real instruction that is executed by the CPU. `mov` is the mnemonic, which tells the processor what to do. The remaining text are the arguments, `x1` is a registers. `mov` in this case takes the literal value of 7 and places it in the register `x0`, clobbering whatever value was previously there. It's important to note that registers in the processor *from the perspective of this class* may persist across various programs and function calls. This will come up later. Moving on to the next instruction:

```arm
add x2, x1, x1 
```

This is an arithmetic instruction that adds `x1` and `x1` and stores the result in `x2`. We hard coded `x1` to be 7, so the result should be 14. compile the program execute the following command line arguments:

```shell
$ as hello.s -o hello.o
$ ld hello.o -o hello.out
```

These commands assemble and link the code respectively. Note that this is already handled by the Make target `$ make hello.out`.  If you try to run the command, you will get the following:

```shell
$ ./hello.out
Illegal instruction (core dumped)
```

This is fine. Actually, at the end of the program, the program must inform the operating system that it is complete. This will be covered in another lab. For now, we will actually use `gdb` to debug the code and view the contents of the registers line by line. If you haven't used it before, `gdb` is capable of debugging your code by stopping at certain breakpoints and letting you view the contents of the CPU in depth. Fire it up as follows:

```shell
$ gdb ./hello.out
GNU gdb (Ubuntu 8.1-0ubuntu3) 8.1.0.20180409-git
...
Type "apropos word" to search for commands related to "word"...
Reading symbols from ./hello.out...(no debugging symbols found)...done.
(gdb) 
```

The `(gdb)` indicates you're in the `gdb` CLI. If you attempt to run the program now you will get a replay of when you attempted to run it in the regular terminal CLI. Instead, we are going to put a breakpoint at the start of the function `_start`. Use the following command:

```gdb
(gdb) br _start
Breakpoint 1 at 0x40007c
```

`0x40007c` is the default memory address of `_start`, a convention specified by some combination of the architecture and the OS. `gdb` has not actually run the program yet, it just noted that when we start the program, it should halt on the instruction labeled `_start` to let you examine the internals of the program. Run the program as follows:

```gdb
(gdb) run
Starting program: /home/albert/CMPS-3240-Hello-ARM/hello.out 

Breakpoint 1, 0x000000000040007c in _start ()
```

This confirms everything said above. As `hello.out` is executed, stop at address `0x400080` which corresponds to `_start` by convention. If you want to know the contents of all registers execute:

```gdb
(gdb) info registers
```

but this is information overkill perhaps. Note `pc` and how it echos the location of `_start`. If you want to know the specific contents of a register execute:

```gdb
(gdb) info registers x1
x1             0x7	7
```

Which is the hard coded value we specified. Executing `step` moves onto the next line:

```gdb
(gdb) step
Single stepping until exit from function _start,
which has no line number information.
0x0000000000400080 in ?? ()
(gdb) info registers x1 x2
x1             0x7	7
x2             0xe	14
```

*Note that you can provide a list of registers after `info registers`*. There you have it, hello CPU, we instructed it to add two numbers at a very low level.

### Footnotes

<sup>a</sup>Specifically we are using ARMv8-a.
