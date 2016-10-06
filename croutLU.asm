#UNIVERSIDADE DE BRASILIA - UNB
#DEPARTAMENTO DE CIENCIA DA COMPUTACAO - CIC
#ORGANIZACAO E ARQUITETURA DE COMPUTADORES - TURMA D
#
#LABORATORIO 1 - PROGRAMA DE DECOMPOSICAO DE MATRIZES LU EM ASSEMBLY MIPS
#
#AUTORES:
#ANDRE ABREU RODRIGUES DE ALMEIDA - 12/0007100
#IURI


.data
#matrizes
mat_A:	 .space	 512	#limite de espaco: matriz 8x8
mat_L:	 .space	 512
mat_U:	 .space	 512
#textos de interacao com o usuario
output1: .asciiz "Qual o numero de linhas? (max 9) <ENTER>\n"
output2: .asciiz "Qual o numero de colunas? (max 9) <ENTER>\n"
output3: .asciiz "Introduza o elemento a"
output4: .asciiz " da matriz A:\n"
OmatA:	 .asciiz "\nA matriz A eh:\n\n"
OmatL:	 .asciiz "\nA matriz L eh:\n\n"
OmatU:	 .asciiz "\nA matriz U eh:\n\n"
erro1:	 .asciiz "Por favor digite um numero valido\n"
#constantes
zero:	 .double 0
um:	 .double 1


	#################
	# Equivalencias #
	#################

.eqv	Rmat_A		$s0
.eqv	Rmat_L		$s1
.eqv	Rmat_U		$s2
.eqv	nLinhas		$s3
.eqv	nColunas	$s4

	##########
	# Macros #
	##########
	
.macro push		#aloca memoria e empilha tudo
	#registradores
	addi $sp, $sp, 128
	sw $0, 124($sp)
	sw $1, 120($sp)
	sw $2, 116($sp)
	sw $3, 112($sp)
	sw $4, 108($sp)
	sw $5, 104($sp)
	sw $6, 100($sp)
	sw $7, 96($sp)
	sw $8, 92($sp)
	sw $9, 88($sp)
	sw $10, 84($sp)
	sw $11, 80($sp)
	sw $12, 76($sp)
	sw $13, 72($sp)
	sw $14, 68($sp)
	sw $15, 64($sp)
	sw $16, 60($sp)
	sw $17, 56($sp)
	sw $18, 52($sp)
	sw $19, 48($sp)
	sw $20, 44($sp)
	sw $21, 40($sp)
	sw $22, 36($sp)
	sw $23, 32($sp)
	sw $24, 28($sp)
	sw $25, 24($sp)
	sw $26, 20($sp)
	sw $27, 16($sp)
	sw $28, 12($sp)
	sw $29, 8($sp)
	sw $30, 4($sp)
	sw $31, 0($sp)
	
	#HI e LO
	mfhi $t0
	mflo $t1
	subi $sp, $sp, 8
	sw $t0, 4($sp)
	sw $t1, 0($sp)
	
	#Coprocessador 1
	subi $sp, $sp, 128
	sdc1 $f0, 124($sp)
	#sdc1 $f1, -124($sp)
	sdc1 $f2, 116($sp)
	#sdc1 $f3, -116($sp)
	sdc1 $f4, 108($sp)
	#sdc1 $f5, -108($sp)
	sdc1 $f6, 100($sp)
	#sdc1 $f7, -100($sp)
	sdc1 $f8, 92($sp)
	#sdc1 $f9, -92($sp)
	sdc1 $f10, 84($sp)
	#sdc1 $f11, -84($sp)
	sdc1 $f12, 76($sp)
	#sdc1 $f13, -76($sp)
	sdc1 $f14, 68($sp)
	#sdc1 $f15, -68($sp)
	sdc1 $f16, 60($sp)
	#sdc1 $f17, -60($sp)
	sdc1 $f18, 52($sp)
	#sdc1 $f19, -52($sp)
	sdc1 $f20, 44($sp)
	#sdc1 $f21, -44($sp)
	sdc1 $f22, 36($sp)
	#sdc1 $f23, -36($sp)
	sdc1 $f24, 28($sp)
	#sdc1 $f25, -28($sp)
	sdc1 $f26, 20($sp)
	#sdc1 $f27, -20($sp)
	sdc1 $f28, 12($sp)
	#sdc1 $f29, -12($sp)
	sdc1 $f30, 4($sp)
	#sdc1 $f31, -4($sp)
.end_macro
	
.macro pop		#resgata tudo da pilha e libera memoria
	#Coprocessador 1
	ldc1 $f0, 124($sp)
	#ldc1 $f1, -124($sp)
	ldc1 $f2, 116($sp)
	#ldc1 $f3, -116($sp)
	ldc1 $f4, 108($sp)
	#ldc1 $f5, -108($sp)
	ldc1 $f6, 100($sp)
	#ldc1 $f7, -100($sp)
	ldc1 $f8, 92($sp)
	#ldc1 $f9, -92($sp)
	ldc1 $f10, 84($sp)
	#ldc1 $f11, -84($sp)
	ldc1 $f12, 76($sp)
	#ldc1 $f13, -76($sp)
	ldc1 $f14, 68($sp)
	#ldc1 $f15, -68($sp)
	ldc1 $f16, 60($sp)
	#ldc1 $f17, -60($sp)
	ldc1 $f18, 52($sp)
	#ldc1 $f19, -52($sp)
	ldc1 $f20, 44($sp)
	#ldc1 $f21, -44($sp)
	ldc1 $f22, 36($sp)
	#ldc1 $f23, -36($sp)
	ldc1 $f24, 28($sp)
	#ldc1 $f25, -28($sp)
	ldc1 $f26, 20($sp)
	#ldc1 $f27, -20($sp)
	ldc1 $f28, 12($sp)
	#ldc1 $f29, -12($sp)
	ldc1 $f30, 4($sp)
	#ldc1 $f31, -4($sp)
	addi $sp, $sp, 128
	
	#Hi e LO
	lw $t0, 4($sp)
	lw $t1, 0($sp)
	mthi $t0
	mtlo $t1
	addi $sp, $sp, 8
	
	#registradores CPU
	lw $0, 124($sp)
	lw $1, 120($sp)
	lw $2, 116($sp)
	lw $3, 112($sp)
	lw $4, 108($sp)
	lw $5, 104($sp)
	lw $6, 100($sp)
	lw $7, 96($sp)
	lw $8, 92($sp)
	lw $9, 88($sp)
	lw $10, 84($sp)
	lw $11, 80($sp)
	lw $12, 76($sp)
	lw $13, 72($sp)
	lw $14, 68($sp)
	lw $15, 64($sp)
	lw $16, 60($sp)
	lw $17, 56($sp)
	lw $18, 52($sp)
	lw $19, 48($sp)
	lw $20, 44($sp)
	lw $21, 40($sp)
	lw $22, 36($sp)
	lw $23, 32($sp)
	lw $24, 28($sp)
	lw $25, 24($sp)
	lw $26, 20($sp)
	lw $27, 16($sp)
	lw $28, 12($sp)
	lw $29, 8($sp)
	lw $30, 4($sp)
	lw $31, 0($sp)
	addi $sp, $sp, 128
.end_macro	


.macro exit	#termina a execucao do programa
	li $v0,10
	syscall
.end_macro

.macro print_int (%x)		#exemplo do menu de ajuda do mars
	li $v0, 1
	add $a0, $zero, %x
	syscall
.end_macro

.macro print_double (%doub)	#exemplo do menu de ajuda do mars adaptado
	li $v0, 3
	mov.d $f12, %doub
	syscall
.end_macro

.macro print_string (%stg)	#exemplo do menu de ajuda do mars adaptado
	li $v0, 4
	addu $a0, $zero, %stg
	syscall
.end_macro

.macro print_matrix (%matrixAddress, %lines, %columns)	#matriz 3x3 somente
	.data 
	tab:	.asciiz	"	"
	endl:	.asciiz	"\n"
	.align 3
	.text
	#push
	addi $sp, $sp, 36
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sdc1 $f22, 24($sp)
	
	addu $t0, $zero, %matrixAddress
	addu $t1, $zero, $zero
	la $t3, tab
	la $t4, endl
	lineloop:
		addiu $t1, $t1, 1	#condicao de parada
		addu $t2, $zero, $zero	#reinicia contagem de colunas
		columnloop:
			ldc1 $f20, 0($t0)	#carrega o elemento a ser impresso
			addiu $t0, $t0, 8	#offset para o proximo elemento
			addiu $t2, $t2, 1	#condicao de parada
			#imprime
			print_double ($f20)	#imprime o numero
			print_string ($t3)	#print "tab" - espacamento
		blt $t2, %columns, columnloop
		print_string ($t4)	#print "endl" - pula linha
	blt $t1, %lines, lineloop
	
	#pop
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	ldc1 $f22, 24($sp)
	addi $sp, $sp, 36
.end_macro

.macro cvt_elem_coord (%inp, %lin, %i, %j)
	subi $sp, $sp, 4 #push
	sw $t0, 0($sp) #salva o valor de $t0 na pilha para que esse nao seja alterado
	subi $t0, %inp, 1
	div $t0, %lin
	mflo %i #linha
	mfhi %j #coluna
	addi %i, %i, 1
	addi %j, %j, 1
	lw $t0, 0($sp)	#libera $t0 da pilha
	addi $sp, $sp, 4 #pop
.end_macro



.text
	#########
	# START #
	#########
		
la Rmat_A, mat_A
la Rmat_L, mat_L
la Rmat_U, mat_U


#############################################################################
#	IO 
#############################################################################

pedeLC:
#pede numero de linhas
li $v0, 4
la $a0, output1
syscall
#recebe numero de linhas, salva em $s3
li $v0, 5
syscall
addu nLinhas, $zero, $v0
#pede numero de colunas
li $v0, 4
la $a0, output2
syscall
#recebe numero de colunas, salva em $s4
li $v0, 5
syscall
addu nColunas, $zero, $v0
#teste de validade
bgt nLinhas, 9, numinvalido	#confere se o numero de linhas e menor ou igual a 9
ble nColunas, 9, numvalido	#confere se o numero de colunas e menor ou igual a 9
numinvalido:
la $t1, erro1
print_string ($t1)
j pedeLC
numvalido:

#get_matrix
addiu $t0, $zero, 0
mul $t1, nLinhas, nColunas
#addiu $t1, $zero, 9	#alterar aqui para fazer NxN
addu $t2, $zero, Rmat_A	#usa temporario $t2 para preservar o valor de $s0
get_matrix:		#loop para obter a matriz 3x3
	addiu $t0, $t0, 1
	cvt_elem_coord ($t0, nLinhas, $t5, $t6)
	#pede elemento
	li $v0, 4
	la $a0, output3
	syscall
	li $v0, 1
	addu $a0, $zero, $t5
	syscall
	addu $a0, $zero, $t6
	syscall
	li $v0, 4
	la $a0, output4
	syscall
	#recebe elemento
	li $v0, 7	#salva numero ponto flutuante precisao dupla em $f0
	syscall
	#salva elemento
	sdc1 $f0, ($t2)	#empilha elemento em ponto flutuante precisao dupla
	addiu $t2, $t2, 8	#offset de 8 bytes - double precision
blt $t0, $t1, get_matrix	#fim loop get_matrix


################################################################################
#mostra a matriz A
la $t4, OmatA
print_string ($t4)
print_matrix (Rmat_A, nLinhas, nColunas)
################################################################################


#############################################################################
#	Crout's method
#############################################################################

#	Algoritmo:
#
#1o passo: a diagonal principal da matriz L e setada em 1 em todos os seus elementos
#2o passo: a primeira linha da matriz U e copiada da matriz A elemento a elemento
#3o passo: os outros valores dessas matrizes sao definidos coluna a coluna de acordo
#	   com as equacoes (2.3.12) e (2.3.13) do livro
#

	##
	##	1o passo
	################################

li $t0, 0	#condicao de parada
la $t4, um
ldc1 $f22, 0($t4)	#armazena "1" em ponto flutuante em $f20
diagonal:	#varre a diagonal principal da matriz
	#algo: alpha_ii = (i-1)*nColunas + (j-1)  , i==j
	mul $t3, $t0, nColunas #$t0 = (j-1) = (i-1)
	add $t3, $t3, $t0
	sll $t3, $t3, 3	#offset de 8 bytes
	add $t3, $t3, Rmat_L
	sdc1 $f22, 0($t3)	#armazena "1" na diagonal
	addi $t0, $t0, 1	#incremento
ble $t0, nColunas, diagonal

################################################################################
#mostra a matriz L
la $t4, OmatL
print_string ($t4)
print_matrix (Rmat_L, nLinhas, nColunas)
################################################################################


exit
