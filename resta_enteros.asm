; Programa: Resta de tres enteros (16 bits)
; Autor: Roberto Mena - MM22025
; resta_enteros.asm
; nasm -f elf32 resta_enteros.asm -o resta_enteros.o
; ld  -m elf_i386 resta_enteros.o -o resta_enteros

bits 32

section .data
  num1   dw 150      ; primer operando 16 bits
  num2   dw  30      ; segundo
  num3   dw  20      ; tercero
  result dw  0       ; aquí guardamos AX

  prefix db "Result: ",0
  buf    db "00000",10   ; espaciamos 5 dígitos + '\n'

section .text
  global _start

_start:
  ; 1) resta en 16 bits
  mov  ax, [num1]   ; AX = num1
  mov  bx, [num2]   ; BX = num2
  sub  ax, bx       ; AX = AX – BX
  mov  cx, [num3]   ; CX = num3
  sub  ax, cx       ; AX = AX – CX
  mov  [result], ax

  ; 2) imprimir "Result: "
  mov  eax,4
  mov  ebx,1
  mov  ecx,prefix
  mov  edx,8
  int 0x80

  ; 3) convertir [result] a ASCII decimal, 5 dígitos
  movzx eax, word [result]  ; extender a 32 bits
  lea   edi, [buf+4]        ; puntero al último dígito
  mov   ecx, 5
.conv:
  xor   edx,edx
  mov   ebx,10
  div   ebx                 ; EAX=EAX/10, EDX=resto
  add   dl,'0'
  mov   [edi], dl
  dec   edi
  dec   ecx
  test  eax,eax
  jnz   .conv
.pad:
  cmp   ecx,0
  je    .donepad
  mov   byte [edi],'0'
  dec   edi
  dec   ecx
  jmp   .pad
.donepad:

  ; 4) imprimir buf (5 dígitos + '\n')
  mov  eax,4
  mov  ebx,1
  mov  ecx,buf
  mov  edx,6
  int 0x80

  ; 5) salir
  mov  eax,1
  xor  ebx,ebx
  int 0x80
