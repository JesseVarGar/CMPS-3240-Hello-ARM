# CMPS-3240-Hello-ARM

The lab consists of two parts. Using `gcc` to create assembly code from C language for you to study, and entering ARM code line-by-line and using `as` and `ld` to assemble and link original code. We will 

## Part 1 - `gcc` to generate assembly code

The first part of the lab we will use GCC to assemble mnemonics for us to study. Entering:

```shell
$ make hello.s
```

into the CLI will generate assembly mnemonics from some C language code. You should get the following output:

```shell
$ make hello.s
gcc -S hello.c -o hello.s
```

We are using `gcc` to generate assembly code for us, rather than generate a binary or link binary files. The `-S` flag accomplishes this. `gcc` will generate assembly based on the current architecture you're using, and since you're on the department's ARM server this will be ARM code.<sup>a</sup> In the following we will go line-by-line in `hello.s` and explain what each line does.

```arm
.file	"hello.c"
```

This line is not actually ARM assembly at all. It is a directive. Directives help the compiler and or debugger but do not make it into the binary code. This particular directive helps the debugger know that this is a part of the `hello.c` file. This is a non-critical directive.

```arm
.text
.section	.rodata
```

These are the first critical lines. `.text` is a directive that lets the compiler know that the code that follows this directive should be placed in the `text` section of the memory. The memory contains both data and instructions, and further segmented into chunks for different uses with different permissions.  `.section .rodata` declares that the following lines are read-only parts of memory. The items in this section are variables stored in memory and are organized by the identifier, data type and the literal value. You can think of the variables declared in this section as global and `const`. Now consider:

```arm
.LC0:
	.string	"Hello world!"
```
 
These lines are in the `.rodata` section. `.LC0:` is a tag, it indicates that the rest of the contents of the line, or what immidiately follows the line, should be associated with the identifier in the tag. `LC0` is an arbitrary identifier given by the compiler, it does not bear any special significance. Note that when we declared the string literal "Hello world!" we did not associate it with an identifier. We plugged it into the function call directly, with:

``` c
 printf( "Hello world!" );
```
 
The compiler created a read-only variable for us automatically called `.LC0`. `.string` indicates that the data type is a string. If thought-of in terms of C code, it would look like this:
 
```c
const char* LC0 = "Hello world!";
printf( LC0 );
```

Moving on, now consider: 
 
```arm
.text
.globl	main
.type	main, @function
main:
```

`.text` indicates a block of text, unlike the previous section it is not labelled `rodata`. `.globl main` and `.type main, @function` are compiler directives for the debugger and linker that indicate the start of the main function. `.globl` in particular is used to help the linker identify the different function definitions. `main:` is the real identifier here that indicates the following lines are the start of our `main()` function. Ignore the rest of the directives from here on out, they're beyond the scope of the lab.

### Footnotes

<sup>a</sup>Specifically we are using ARMv8-a.
