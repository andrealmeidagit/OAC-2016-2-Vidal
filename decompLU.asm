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
mat_A:	 .space	 72
mat_L:	 .space	 72
mat_U:	 .space	 72
#textos de interacao com o usuario
output1: .asciiz "Qual o numero de linhas? <ENTER>\n"
output2: .asciiz "Qual o numero de colunas? <ENTER>\n"
output3: .asciiz "Introduza o "
output4: .asciiz "o elemento da matriz:\n"
OmatA:	 .asciiz "\nA matriz A eh:\n\n"
OmatL:	 .asciiz "\nA matriz L eh:\n\n"
OmatU:	 .asciiz "\nA matriz U eh:\n\n"
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


.eqv	alpha		$f2
.eqv	beta		$f4
.eqv	gamma		$f6
.eqv	b2		$f8
.eqv	b3		$f10
.eqv	c2		$f18
.eqv	c3		$f14
.eqv	d3		$f16

### MENU DE SAVES
# $s0 = mat_A address
# $s1 = mat_L address
# $s2 = mat_U address
# $s3 = numero de linhas
# $s4 = numero de colunas
#
### float saves (double - usar somente registradores pares!!)
# $f0 = IO ~ syscall
# $f2 = alpha
# $f4 = beta
# $f6 = gamma
# $f8 = b2
# $f10 = b3
# $f12 = argumento
#	$f18 = c2
# $f14 = c3
# $f16 = d3
# $f20+ = temporarios

	##########
	# Macros #
	##########

.macro exit	#termina a execucao do programa
	li $v0,10
	syscall
.end_macro

.macro print_double (%x)	#exemplo do menu de ajuda do mars adaptado
	li $v0, 3
	mov.d $f12, %x
	syscall
.end_macro

.macro print_string (%stg)	#exemplo do menu de ajuda do mars adaptado
	li $v0, 4
	addu $a0, $zero, %stg
	syscall
.end_macro

.macro print_matrix (%matrixAddress)
	.data 
	tab:	.asciiz	"	"
	endl:	.asciiz	"\n"
	.text
	addu $t0, $zero, %matrixAddress
	addu $t1, $zero, $zero
	addiu $t2, $zero, 3
	la $t3, tab
	la $t4, endl
	lineloop:
		#carrega linha
		ldc1 $f26, 0($t0)
		ldc1 $f28, 8($t0)
		ldc1 $f30, 16($t0)
		#atrualiza indices
		addiu $t0, $t0, 24	#proxima linha - offset 3 elementos de 8 bytes
		addiu $t1, $t1, 1
		#imprime
		print_double ($f26)
		print_string ($t3)	#print "tab"
		print_double ($f28)
		print_string ($t3)	#print "tab"
		print_double ($f30)
		print_string ($t4)	#print "endl"
	blt $t1, $t2, lineloop
.end_macro

.text
	#########
	# START #
	#########	




#############################################################################
#	STEP 1: IO 
#############################################################################

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

#get_matrix
addiu $t0, $zero, 0
addiu $t1, $zero, 9	#alterar aqui para fazer NxN
la Rmat_A, mat_A
addu $t3, $zero, Rmat_A	#usa temporario $t3 para preservar o valor de $s0
get_matrix:		#loop para obter a matriz 3x3
	addiu $t0, $t0, 1
	#pede elemento
	li $v0, 4
	la $a0, output3
	syscall
	li $v0, 1
	addu $a0, $zero, $t0
	syscall
	li $v0, 4
	la $a0, output4
	syscall
	#recebe elemento
	li $v0, 7	#salva numero ponto flutuante precisao dupla em $f0
	syscall
	#salva elemento
	sdc1 $f0, ($t3)	#empilha elemento em ponto flutuante precisao dupla
	addiu $t3, $t3, 8	#offset de 8 bytes - double precision
blt $t0, $t1, get_matrix	#fim loop get_matrix

j step2	#monta as matrizes L e U

output:
la $t4, OmatA
la $t5, OmatL
la $t6, OmatU
#imprime as matrizes na tela
print_string ($t4)
print_matrix (Rmat_A)
print_string ($t5)
print_matrix (Rmat_L)
print_string ($t6)
print_matrix (Rmat_U)

exit	#termina a execucao do programa


#############################################################################
#	STEP 2: ALPHA AND BETA
#############################################################################
step2:
#alpha = a10/a00

#carrega a10 - 4o elemento da matriz A
ldc1 $f22, 24(Rmat_A)	#pula 3 elementos de 8 bytes => 3*8=24
#carrega a00 - 1o elemento da matriz A
ldc1 $f20, 0(Rmat_A)	#primeiro elemento
div.d alpha, $f22, $f20	#calcula alpha

# beta = a20/a00

#carrega s20 - 7o elemento da matriz A
ldc1 $f22, 48(Rmat_A)	#pula 6 elementos de 8 bytes => 6*8=48
div.d beta, $f22, $f20	#calcula beta

#############################################################################
#	STEP 3: kill a10 and a20 - gauss elimination
#############################################################################

#valor de b2
#b2 = a01*alpha - a11
ldc1 $f24, 8(Rmat_A) #carrega a01 - offset de 1*8=8
ldc1 $f26, 32(Rmat_A)	#carrega a11 - offset de 4*8=32
mul.d b2, alpha, $f24
sub.d b2, b2, $f26	#calcula b2

#valor de b3
#b3 = a02*alpha - a12
ldc1 $f28, 16(Rmat_A) #carrega a02 - offset de 2*8=16
ldc1 $f30, 40(Rmat_A)	#carrega a12 - offset de 5*8=40
mul.d b3, alpha, $f28
sub.d b3, b3, $f30	#calcula b3

#valor de c2
#c2 = a01*beta - a21
#ldc1 $f24, 8($s0) #carrega a01 - offset de 1*8=8		#nao precisa
ldc1 $f26, 56(Rmat_A)	#carrega a21 - offset de 7*8=56
mul.d c2, alpha, $f24
sub.d c2, c2, $f26	#calcula c2

#valor de c3
#c3 = a02*alpha - a22
#ldc1 $f28, 16($s0) #carrega a02 - offset de 2*8=16		#nao precisa
ldc1 $f30, 64(Rmat_A)	#carrega a22 - offset de 8*8=64
mul.d c3, alpha, $f28
sub.d c3, c3, $f30	#calcula c3

#############################################################################
#	STEP 4: calculate gamma
#############################################################################

#gamma = c2/b2
div.d gamma, c2, b2

#############################################################################
#	STEP 5: calculate d3
#############################################################################

#d3 = gamma*b3-c3
mul.d d3, gamma, b3
sub.d d3, d3, c3

#############################################################################
#	STEP 6: build L and U matrixes
#############################################################################

#salva matriz L
la Rmat_L, mat_L
la $t0, zero
la $t1, um
ldc1 $f30, 0($t0)	#carrega a constante "0" em formato double
ldc1 $f28, 0($t1)	#carrega a constante "1" em formato double
#linha 1
sdc1 $f28, 0(Rmat_L)	#l11
sdc1 $f30, 8(Rmat_L)	#l12
sdc1 $f30, 16(Rmat_L)	#l13
#linha 2
sdc1 alpha, 24(Rmat_L)	#l21
sdc1 $f28, 32(Rmat_L)	#l22
sdc1 $f30, 40(Rmat_L)	#l23
#linha 3
sdc1 beta, 48(Rmat_L)	#l31
sdc1 gamma, 56(Rmat_L)	#l32
sdc1 $f28, 64(Rmat_L)	#l33

#	matriz L
#	1	0	0
#	alpha	1	0
#	beta	gamma	1


#salva U
la Rmat_U, mat_U
#carrega primeira linha
ldc1 $f20, 0(Rmat_A)	#a11=>u11
ldc1 $f22, 8(Rmat_A)	#a12=>u12
ldc1 $f24, 16(Rmat_A)	#a13=>u13

#linha 1
sdc1 $f20, 0(Rmat_U)	#u11
sdc1 $f22, 8(Rmat_U)	#u12
sdc1 $f24, 16(Rmat_U)	#u13
#linha 2
sdc1 $f30, 24(Rmat_U)	#u21
sdc1 b2, 32(Rmat_U)	#u22
sdc1 b3, 40(Rmat_U)	#u23
#linha 3
sdc1 $f30, 48(Rmat_U)	#u31
sdc1 $f30, 56(Rmat_U)	#u32
sdc1 d3, 64(Rmat_U)	#u33

#	matriz U
#	a11	a12	a13
#	0	b2	b3
#	0	0	d3

j output	#retorna as 3 matrizes na tela (sessao de IO)

	#######
	# END #
	#######
exit