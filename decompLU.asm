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




.text
	#########
	# START #
	#########	

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
#
# $f16+ = temp



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
addu $s3, $zero, $v0
#pede numero de colunas
li $v0, 4
la $a0, output2
syscall
#recebe numero de colunas, salva em $s4
li $v0, 5
syscall
addu $s4, $zero, $v0

#get_matrix
addiu $t0, $zero, 0
addiu $t1, $zero, 9	#alterar aqui para fazer NxN
la $s0, mat_A
addu $t3, $zero, $s0	#usa temporario $t3 para preservar o valor de $s0
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

#############################################################################
#	STEP 2: ALPHA AND BETA
#############################################################################

#alpha = a10/a00

#carrega a10 - 4o elemento da matriz A
ldc1 $f16, 24($s0)	#pula 3 elementos de 8 bytes => 3*8=24
#carrega a00 - 1o elemento da matriz A
ldc1 $f18, 0($s0)	#primeiro elemento
div.d $f2, $f16, $f18	#calcula alpha

# beta = a20/a00

#carrega s20 - 7o elemento da matriz A
ldc1 $f20, 48($s0)	#pula 6 elementos de 8 bytes => 6*8=48
div.d $f4, $f20, $f18	#calcula beta

#############################################################################
#	STEP 3: kill a10 and a20 - gauss elimination
#############################################################################

#valor de b2
#b2 = a01*alpha - a11




	#######
	# END #
	#######
exit:
li $v0, 10
syscall
