.section .text
.global _start
_start:
	mov x0, x15
	mov x1, 2
	add x2, x1, x1

.data
string:
	.ascii "Hello world!"
