# CMPS 3240 Lab: Hello, World! ARM

## Objectives

During this lab you will:

* Code ARM64 (ARMv8-A) assembly language
* Assemble and link assembly code with `as` and `ld`
* Use `gdb` to debug a binary process

## Prerequisites

This lab assumes you have read or are familiar with the following topics:

* Difference between compiler, assembler and linker. Refer to Appendix A-1.<sup>a</sup>
* Concept of CPU registers
* Concept of load-store architecture
* Use software interrupts to halt a program and print to the screen

Please study these topics if you are not familiar with them so that the lab can be completed in a timely manner.

## Requirements

The following is a list of requirements to complete the lab. Some labs can completed on any machine, whereas some require you to use a specific departmental teaching server. You will find this information here.

### Software

We will use the following programs:

* `as`
* `ld`
* `git`
* `gdb`

### Compatability

This lab requires the departmental ARM server, `fenrir.cs.csubak.edu`. It will not work on `odin.cs.csubak.edu`, `sleipnir.cs.csubak.edu`, other PCs, etc. that have x86 processors. It may work on a Raspberry Pi or similar system on chip with ARM, but it must be ARMv8-a.

| Linux | Mac | Windows |
| :--- | :--- | :--- |
| Limited | No | No |


## Background

This lab will cover two important concepts. First, we cover interacting with data on microprocessors. Second, we cover running processes on microprocessors. 

Microprocessors have two types of storage for data: registers and memory. Registers are special. You only have a finite amount of them. We will learn why so later on in class. If you didn't know it beforehand, this a staggering concept. Your processor only has a capacity operate on only tens of values at once. At a given time it is juggling intermediate values between registers and memory. MIPS has 32 general purpose registers. ARM64 has roughly 31 general purpose registers. Registers use SRAM technology and are faster than memory. Registers have a given identifier, you cannot rename them. Examples: `x0`, `x1`, `x2`, etc. Note that names change across different versions of ARM, and this will probably impact how useful external resources are if you have an issue. Registers values are generally static across subroutine calls in your process. Some registers are *scratch registers* for use with internal logic of your code. Others have are reserved and have some specific use. Further, some are protected and access will cause an error without proper permissions. Register usage convention may change across different versions of ARM and the operating system you are using.

Some architectures can only perform arithmetic values in registers. Some examples being MIPS and ARM. If you want to change a value in memory you must load it to a register with a single instruction. Then, it becomes possible to change the value with arithmetic operations. When finished, you store it back into memory with a third operation. This is called *load-store architecture*.

The second concept we will cover is the idea that your program is a *user process*. It runs some commands, etc. There are some situations when I/O is needed or the program is complete. Your process will have to get the help of the *supervisor process* to do this goal. This handoff is called a *system call* or syscall for short. Your process hands off control to the supervisor. The supervisor then returns control when finished. You can think of this as a sort of function call that you would see in a higher-level language.

## Approach

The lab consists of two parts. Using `as` and `ld` to assemble and link ARM code respectively and implementing a Hello, World! program. Start by cloning this repository:

```shell
$ git clone https://github.com/DrAlbertCruz/CMPS-3240-Hello-ARM.git
...
$ cd CMPS-3240-Hello-ARM
```

Use `ls` to take a look at the files in the directory and take some time to familiarize yourself with them.

### Part 1 - Using GDB to View Contents of Registers

The first "Hello, World!" in this class will not print a string at first. The idea of "Hello, World!" is to view the output of a simple operation. Yet, we are operating at an atomic level. We can view the effect our instructions are having on the registers themselves. `hello.s` is the first program we will consider. Open it up in any text editor:

```bash
$ vim hello.s
```

The contents are as follows:

```arm
.text
.global _start
_start:
	mov x1, #7
	add x2, x1, x1
```

In the following, we explain this code line-by-line:

```arm
.text
```

This code line is not an instruction at all. It is an assembler/linker directive that indicates where the following lines of code should be placed.<sup>b</sup> Generally there are five parts of memory:

1. Code (the process being executed) which is readable but not writable,
2. Read only static data,
3. Writeable static data,
4. The heap, and
5. The stack.

`.text` indiates that these instructions should be placed in the code section. Another common directive is `.data`, which would place what follows in the static data section. This next line:

```arm
.global _start
``` 

This is also a directive. It indicates the following code is associated with the subroutine `_start`. It will be useful for the debugger (`gdb`) later on. This next line:

```arm
_start:
```

This is the first line that is not a directive. Yet, it is not an instruction. It is a *label*. It indicates the line that follows should be associated with the identifier `_start`. With `as` and `ld`, `_start` is the start of the program. When executing a program, the processor has a reserved register that indicates which instruction to execute. This is called the *program counter* or PC, and it is initialized to `_start`. Now consider this line:

```arm
mov x1, #7
```

This is the first real instruction that is executed by the CPU. `mov` is the mnemonic, which tells the processor what to do. The remaining text are the arguments. `x1` is a register. `mov` in this case takes the literal value of 7 and places it in the register `x1`, clobbering whatever value was previously there. Move on to the next instruction:

```arm
add x2, x1, x1 
```

This is an arithmetic instruction that adds `x1` and `x1` and stores the result in `x2`. We hard coded `x1` to be 7, so the result should be 14. Compile the program with the following command line arguments:

```shell
$ as hello.s -o hello.o
$ ld hello.o -o hello.out
```

These commands assemble and link the code respectively. Note that these instructions are defined by the Make target `$ make hello.out` in `makefile`. If you try to run the command, you will get the following:

```shell
$ ./hello.out
Illegal instruction (core dumped)
```

Believe it or not this is a success. At the end of the program, the user process must inform the supervisor that it is complete. We did not add this code, so the processor keeps executing lines of code beyond the last instruction `add x2, x1, x1`. These lines we did not explicitly specify may be garbage or zero, but when read by the processor it is generally invalid, hence why it tells us that it executed an illegal instruction. We will handle proper exiting later. 

For now, use `gdb` to debug the code and view the contents of the registers line by line. If you haven't used it before, `gdb` is capable of debugging your code by stopping at certain breakpoints and letting you view the contents of the CPU in depth. Fire it up as follows:

```shell
$ gdb ./hello.out
GNU gdb (Ubuntu 8.1-0ubuntu3) 8.1.0.20180409-git
...
Reading symbols from ./hello.out...(no debugging symbols found)...done.
(gdb) 
```

The first argument to `gdb` should be the process you want to execute. The `(gdb)` prefix indicates you're in the `gdb` CLI. If you attempt to run the program now you will get a replay of when you attempted to run it in the regular terminal CLI:

```bash
(gdb) run
Starting program: /home/albert/CMPS-3240-Hello-ARM/hello.out 

Program received signal SIGILL, Illegal instruction.
0x0000000000400080 in ?? ()
```

At this point you can restart `gdb` by `quit`ing and starting over, or executing `run` again which will cause `gdb` to ask if you want to want to restart the program. Now, insert a breakpoint at the start of the function `_start`. Use the following command:

```gdb
(gdb) br _start
Breakpoint 1 at 0x40007c
```

`0x40007c` is the default memory address of `_start`, a convention specified by some combination of the architecture and the OS. `gdb` has not actually run the program yet, it just noted that when we start the program, it should halt on the instruction labeled `_start` to let you examine the internals of the program. This is called a *breakpoint*. When executing commands if `gdb` runs into a breakpoint it will halt. Run the program as follows:

```gdb
(gdb) run
Starting program: /home/albert/CMPS-3240-Hello-ARM/hello.out 

Breakpoint 1, 0x000000000040007c in _start ()
```

This confirms everything said above. As `hello.out` is executed, stop at address `0x40007c` which corresponds to `_start` by convention. If you want to know the contents of all registers execute:

```gdb
(gdb) info registers
```

but this is information overkill perhaps. Note `pc` and how it echos the location of `_start`. If you want to know the specific contents of a register execute:

```gdb
(gdb) info registers x1
x1             0x7	7
```

This is the hard coded value we specified. Note that x2 hasn't been assigned a value yet. Supposed that you wanted to view the format of the instruction instead. You would execute:<sup>d</sup>

```gdb
(gdb) x/4tb 0x40007c
0x40007c <_start+4>:	00100010	00000000	00000001	10001011
```

In a later lab I will explain the `x/4tb` command, just take it as given for now. This is mostly fun to look at since the textbook covers MIPS encoding, and we don't really cover ARM encoding. Now, execute `step` to move onto the next instruction:

```gdb
(gdb) step
Single stepping until exit from function _start,
which has no line number information.
0x0000000000400080 in ?? ()
```

Now, view the contents of the registers. Note that you can provide a list of registers after `info registers` which gives less information and may be more useful: 

```gdb
0x0000000000400080 in ?? ()
(gdb) info registers x1 x2
x1             0x7	7
x2             0xe	14
```

Two things to note here. First, note the address `0x0000000000400080`. The previous instruction was at `0x000000000040007c` and the current instruction is at `0x0000000000400080`. Subtracting the two gives 4, which confirms that ARM instructions are 4-bytes long. Second, note that the addition of `x1` plus itself and assignment to `x2` is carried out. There you have it, hello CPU, we instructed it to add two numbers at the machine level. Exit `gdb` with `quit`:

```gdb
(gdb) quit
```

In the following, we will print a string to the screen and properly close the program.

### Part 2 - Make Like a Tree, and Quit!

There are two things we have to implement with out program: actually quitting, and printing 'Hello world!'. We will accomplish this with system calls (the command `svc`), which causes a software interrupt. Our program offers an interrupt and hands over control to the supervisor. The supervisor process investigates specific registers to determine what to do (input arguments). The interface for syscall is as follows:

* An integer specifying what the supervisor should do is placed in `x8`. A reference is located here.<sup>2</sup>
* Any arguments, if needed, are placed in order starting from `x0`. 
* Call `svc 0`

To quit the program the specific signal we need is `sys_exit`, which is 93. Append the following to hello.s:

```arm
mov x8, #93
mov x0, #0
svc #0
```

`mov x0, #0` is obligatory because, by convention, the return value of the process is placed in register 0. So, this is equivalent to the C code:

```c
int main() {
	...
	return 0;
}
```

which you would normally find at the end of `main()`. Re-`make` everything, and if it works you should get:

```shell
$ ./hello.out
$
```

Note that there is no illegal instruction/core dump. Without `sys_exit` the processor continued to execute command after command in memory which it may not have had permission for (best situation) or started executing garbage or data statements as instructions (worst situation). You can also verify the program exited normally with `gdb`:<sup>c</sup>

```shell
$ gdb ./hello.out
...
(gdb) br _start
...
(gdb) run
...
(gdb) continue
Continuing.
[Inferior 1 (process 9987) exited normally]
```

### Part 3 - Hello, world!

Syscall is also how we will print a string. In the future we will use C-style `printf()`s, but for this lab we will use syscall to perform `sys_write`.<sup>3</sup> Append the following code:

```arm
# This is a comment
# Operation 84 is sys_write
mov x8, #64
# sys_write takes 1 argument, which file descriptor to print to. 1 is screen.
mov x0, #1
# Pointer to string
ldr x1, =msg
# Length of string
ldr x2, =len
# Syscall
svc #0
```

`#64` is the syscall mode to print to a file descriptor (such as the screen). `ldr` takes the second argment, a label, and places the address of the label in the first argument, a register.<sup>4</sup> The arguments, in order, should be as follows:

1. The file descriptor to print to. `#1` is the screen.
1. A pointer to the message (more on that soon).
1. The length of the string.

How do we pass a string to syscall? Well, we have to declare it in memory as a static string, and then pass a pointer to the start of the string via syscall. At the very end of your code *even after svc #0*, insert:

```arm
# Declare the following as data, not instructions
.data
# For debugging, a variable called msg
.global msg
msg:
    .ascii "hello world\n"
# Code to reference length of string pointed to by msg
len = . - msg
```

which is slightly different from previous statements. This is a data statement, not an instruction statement. When interpretting this statement, the assembler/linker will place the string in some place in memory and associate the pointer to the string with the identifier `msg`. `len = . - msg` calculates the length of the string `msg` and places the number in memory, with `len` pointing to the value.

### Check off

For full credit show the instructor that your code works *within `gdb`*. 

### Additional work

If you finish early, consider the Make target `make hello_gcc.s`, which uses `gcc`, the compiler to convert a C language implementation of Hello, World! to assembly. Note the differences.

### References

<sup>1</sup>http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0489c/Cihidabi.html

<sup>2</sup>https://github.com/torvalds/linux/blob/v4.17/include/uapi/asm-generic/unistd.h

<sup>3</sup>http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0058d/BACBEDJI.html

<sup>4</sup>http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0041c/Babbfdih.html

### Footnotes

<sup>a</sup>Note that the book covers MIPS, and we will be using ARM for labs.

<sup>b</sup>It makes no distinction between data and instructions, so you can accidentally order the assembler to place instructions into the data section and vise versa. This is a common error.

<sup>c</sup>If you're curious you might want to confirm this really exits the program by placing additional commands after `svc #0` to see what happens. Verify with `gdb`.

<sup>d</sup>Technically this is _start+4 so you would need to subtract 4 from the memory address to view the last instruction.
