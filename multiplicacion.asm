; Autor: Roberto Mena - MM22025
; Programa: Multiplicacion de 2 numeros enteros (8 bits)
; Para compilarlo:
;   multiplicacion.asm (nombre del archivo)
;   nasm -f elf32 multiplicacion.asm -o multiplicacion.o
;   ld  -m elf_i386 multiplicacion.o -o multiplicacion
;   ./multiplicacion

bits 32

section .data
    num1      db 10                 ; primer operando (8 bits)
    num2      db 1                 ; segundo operando (8 bits)
    res       dw 0                  ; aquí almacenaremos el producto (16 bits)

    msg       db "Result: 0x"       ; prefijo de salida
    msglen    equ $-msg

    hbuf      db "0000",10          ; 4 dígitos hex + newline
    hexchars  db "0123456789ABCDEF" ; tabla para conversión

section .text
    global _start

_start:
    ; 1) Multiplicar AL × BL → AX
    mov   al, [num1]
    mov   bl, [num2]
    mul   bl             ; AX ← AL * BL
    mov   [res], ax      ; guardar resultado de 16 bits


    ; 2) Imprimir el prefijo "Result: 0x"
    mov   eax, 4         ; sys_write
    mov   ebx, 1         ; stdout
    mov   ecx, msg
    mov   edx, msglen
    int   0x80


    ; 3) Convertir el word [res] a 4 dígitos hex en hbuf
    movzx eax, word [res]    ; EAX = producto (zero-extend)
    mov   esi, eax           ; trabajamos con ESI
    mov   ecx, 4             ; 4 dígitos hex por hacer
    lea   edi, [hbuf]        ; apuntador al buffer de salida

.hex_loop:
    mov   edx, esi
    and   edx, 0xF000        ; aislar nibble alto
    shr   edx, 12            ; pasar al valor 0..15
    mov   al, [hexchars + edx]
    mov   [edi], al
    inc   edi
    shl   esi, 4             ; siguiente nibble
    loop  .hex_loop


    ; 4) Imprimir buffer hex + newline
    mov   eax, 4
    mov   ebx, 1
    lea   ecx, [hbuf]
    mov   edx, 5             ; 4 dígitos + '\n'
    int   0x80


    ; 5) Exit
    mov   eax, 1             ; sys_exit
    xor   ebx, ebx
    int   0x80
