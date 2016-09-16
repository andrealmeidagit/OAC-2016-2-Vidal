.data
dados: .asciiz "hello world"
.text
li $v0, 4
la $a0, dados
syscall
li $v0, 10
syscall