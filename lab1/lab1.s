	.file	"lab1.c"
	.text
	.p2align 4
	.globl	sse_mul
	.type	sse_mul, @function
sse_mul:
.LFB543:
	.cfi_startproc
	endbr64
	movups	(%rdi), %xmm0
	movups	(%rsi), %xmm1
	mulps	%xmm1, %xmm0
	movups	%xmm0, (%rdx)
	ret
	.cfi_endproc
.LFE543:
	.size	sse_mul, .-sse_mul
	.p2align 4
	.globl	seq_mul
	.type	seq_mul, @function
seq_mul:
.LFB544:
	.cfi_startproc
	endbr64
	movss	(%rdi), %xmm0
	movss	(%rsi), %xmm1
	mulss	%xmm1, %xmm0
	movss	%xmm0, (%rdx)
	movss	4(%rdi), %xmm0
	movss	4(%rsi), %xmm1
	mulss	%xmm1, %xmm0
	movss	%xmm0, 4(%rdx)
	movss	8(%rdi), %xmm0
	movss	8(%rsi), %xmm1
	mulss	%xmm1, %xmm0
	movss	%xmm0, 8(%rdx)
	movss	12(%rdi), %xmm0
	movss	12(%rsi), %xmm1
	mulss	%xmm1, %xmm0
	movss	%xmm0, 12(%rdx)
	ret
	.cfi_endproc
.LFE544:
	.size	seq_mul, .-seq_mul
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Usage: %s <outer_iterations>\n"
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC2:
	.string	"SSE:        %.6f s   -> %.2f %.2f %.2f %.2f\n"
	.align 8
.LC3:
	.string	"Sequential: %.6f s   -> %.2f %.2f %.2f %.2f\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB546:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$136, %rsp
	.cfi_def_cfa_offset 192
	movq	%fs:40, %rdx
	movq	%rdx, 120(%rsp)
	xorl	%edx, %edx
	cmpl	$1, %edi
	jle	.L25
	movq	8(%rsi), %rdi
	movl	$10, %edx
	xorl	%esi, %esi
	leaq	80(%rsp), %r12
	leaq	64(%rsp), %rbp
	leaq	48(%rsp), %rbx
	call	strtol@PLT
	movdqa	.LC4(%rip), %xmm0
	movq	%rax, %r13
	movl	$1000, %eax
	movaps	%xmm0, 48(%rsp)
	movdqa	.LC5(%rip), %xmm0
	movaps	%xmm0, 64(%rsp)
	pxor	%xmm0, %xmm0
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm0, 96(%rsp)
	.p2align 4,,10
	.p2align 3
.L7:
	movq	%r12, %rdx
	movq	%rbp, %rsi
	movq	%rbx, %rdi
	call	sse_mul
	subl	$1, %eax
	jne	.L7
	leaq	16(%rsp), %r15
	movl	$1, %edi
	movq	%r15, %rsi
	call	clock_gettime@PLT
	xorl	%ecx, %ecx
	testq	%r13, %r13
	jle	.L9
.L8:
	movl	$1000, %eax
	.p2align 4,,10
	.p2align 3
.L10:
	movq	%r12, %rdx
	movq	%rbp, %rsi
	movq	%rbx, %rdi
	call	sse_mul
	subl	$1, %eax
	jne	.L10
	addq	$1, %rcx
	cmpq	%rcx, %r13
	jne	.L8
.L9:
	leaq	32(%rsp), %r14
	movl	$1, %edi
	leaq	96(%rsp), %r12
	movq	%r14, %rsi
	call	clock_gettime@PLT
	movq	40(%rsp), %rax
	pxor	%xmm0, %xmm0
	subq	24(%rsp), %rax
	cvtsi2sdq	%rax, %xmm0
	pxor	%xmm1, %xmm1
	movq	32(%rsp), %rax
	subq	16(%rsp), %rax
	cvtsi2sdq	%rax, %xmm1
	divsd	.LC1(%rip), %xmm0
	movl	$1000, %eax
	addsd	%xmm1, %xmm0
	movsd	%xmm0, 8(%rsp)
	.p2align 4,,10
	.p2align 3
.L11:
	movq	%r12, %rdx
	movq	%rbp, %rsi
	movq	%rbx, %rdi
	call	seq_mul
	subl	$1, %eax
	jne	.L11
	movq	%r15, %rsi
	movl	$1, %edi
	call	clock_gettime@PLT
	xorl	%ecx, %ecx
	testq	%r13, %r13
	jle	.L13
.L12:
	movl	$1000, %eax
	.p2align 4,,10
	.p2align 3
.L14:
	movq	%r12, %rdx
	movq	%rbp, %rsi
	movq	%rbx, %rdi
	call	seq_mul
	subl	$1, %eax
	jne	.L14
	addq	$1, %rcx
	cmpq	%rcx, %r13
	jne	.L12
.L13:
	movq	%r14, %rsi
	movl	$1, %edi
	call	clock_gettime@PLT
	movq	40(%rsp), %rax
	pxor	%xmm0, %xmm0
	subq	24(%rsp), %rax
	cvtsi2sdq	%rax, %xmm0
	pxor	%xmm1, %xmm1
	movq	32(%rsp), %rax
	subq	16(%rsp), %rax
	cvtsi2sdq	%rax, %xmm1
	divsd	.LC1(%rip), %xmm0
	movss	92(%rsp), %xmm4
	movss	88(%rsp), %xmm3
	movss	84(%rsp), %xmm2
	movl	$2, %edi
	movl	$5, %eax
	leaq	.LC2(%rip), %rsi
	cvtss2sd	%xmm4, %xmm4
	cvtss2sd	%xmm3, %xmm3
	cvtss2sd	%xmm2, %xmm2
	addsd	%xmm1, %xmm0
	movss	80(%rsp), %xmm1
	cvtss2sd	%xmm1, %xmm1
	movq	%xmm0, %rbx
	movsd	8(%rsp), %xmm0
	call	__printf_chk@PLT
	movss	108(%rsp), %xmm4
	movss	104(%rsp), %xmm3
	movq	%rbx, %xmm0
	movss	100(%rsp), %xmm2
	movss	96(%rsp), %xmm1
	movl	$2, %edi
	leaq	.LC3(%rip), %rsi
	movl	$5, %eax
	cvtss2sd	%xmm4, %xmm4
	cvtss2sd	%xmm3, %xmm3
	cvtss2sd	%xmm2, %xmm2
	cvtss2sd	%xmm1, %xmm1
	call	__printf_chk@PLT
	xorl	%eax, %eax
.L4:
	movq	120(%rsp), %rdx
	subq	%fs:40, %rdx
	jne	.L26
	addq	$136, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L25:
	.cfi_restore_state
	movq	(%rsi), %rcx
	movq	stderr(%rip), %rdi
	movl	$2, %esi
	xorl	%eax, %eax
	leaq	.LC0(%rip), %rdx
	call	__fprintf_chk@PLT
	movl	$1, %eax
	jmp	.L4
.L26:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE546:
	.size	main, .-main
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC1:
	.long	0
	.long	1104006501
	.section	.rodata.cst16,"aM",@progbits,16
	.align 16
.LC4:
	.quad	4611686019492741120
	.quad	4647714816524288000
	.align 16
.LC5:
	.quad	4665729215040061440
	.quad	4683743613553737728
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
