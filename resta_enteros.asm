; Programa: Resta de tres enteros (16 bits)
; Autor: Roberto Mena - MM22025

org 100h           ; Punto de entrada para DOS (modo real)

section .text
start:
    mov ax, 50     ; Primer número
    sub ax, 20     ; Resta el segundo
    sub ax, 10     ; Resta el tercero

    ; El resultado queda en AX

    mov ah, 0x4C   ; Función para salir del programa en DOS
    int 21h
