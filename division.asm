; Autor: Roberto Mena - MM22025
; Programa: Division de 2 numeros enteros (32 bits)
; Para compilarlo:
;   division.asm (nombre del archivo)
;   nasm -f elf32 division.asm -o division.o
;   ld  -m elf_i386 division.o -o division
;   ./division

section .data
    prompt     db "Ingresa dos numeros Enteros(separado por un espacio. ej: 10 2): ",0xA   ; mensaje al usuario + newline
    prompt_len equ $ - prompt                  ; longitud del mensaje
    outmsg     db "Resultado: "                 ; etiqueta antes del resultado
    outmsg_len equ $ - outmsg                  ; longitud de la etiqueta
    newline    db 0xA                          ; salto de línea

section .bss
    input   resb 64     ; buffer para leer hasta 64 bytes de stdin
    numbuf  resb 12     ; buffer para convertir resultado a ASCII

section .text
    global _start       ; punto de entrada para el linker


_start:
    ; 1) Imprimir prompt
    mov     eax, 4           ; syscall: sys_write
    mov     ebx, 1           ; fd = 1 (stdout)
    mov     ecx, prompt      ; dirección del mensaje
    mov     edx, prompt_len  ; longitud del mensaje
    int     0x80             ; invocar al kernel

    ; 2) Leer línea desde stdin
    mov     eax, 3           ; syscall: sys_read
    mov     ebx, 0           ; fd = 0 (stdin)
    mov     ecx, input       ; buffer de destino
    mov     edx, 64          ; máximo 64 bytes
    int     0x80             ; invocar al kernel

    ; 3) Parsear primer entero
    mov     ecx, input       ; ECX apunta al inicio del buffer
    call    parse_int        ; devuelve valor en EAX, ECX avanza
    mov     esi, eax         ; guardar dividendo en ESI

    ; 4) Parsear segundo entero
    call    parse_int        ; parsea siguiente entero
    mov     ebx, eax         ; guardar divisor en EBX

    ; 5) División con signo
    mov     eax, esi         ; cargar dividendo en EAX
    cdq                      ; extender signo EAX a EDX:EAX
    idiv    ebx              ; dividir EDX:EAX entre EBX a cociente en EAX
    mov     esi, eax         ; guardar cociente en ESI (antes de machacarlo)

    ; 6) Imprimir etiqueta "Quotient: "
    mov     eax, 4           ; syscall: sys_write
    mov     ebx, 1           ; fd = 1 (stdout)
    mov     ecx, outmsg      ; dirección de la etiqueta
    mov     edx, outmsg_len  ; longitud de la etiqueta
    int     0x80             ; syscall a EAX = bytes escritos

    ; 7) Convertir cociente (en ESI) a ASCII
    mov     edi, numbuf+11   ; EDI apunta justo después del último byte útil
    mov     byte [edi], 0    ; poner terminador nulo
    dec     edi              ; retroceder a la posición del último dígito
    mov     ecx, esi         ; ECX = valor a convertir

    cmp     ecx, 0           ; ¿negativo?
    jge     .C_POS
    neg     ecx              ; hacerlo positivo
    mov     bl, '-'          ; BL = marcador de signo
    jmp     .C_LOOP_START

.C_POS:
    xor     bl, bl           ; BL = 0 a sin signo

.C_LOOP_START:
.C_LOOP:
    xor     edx, edx         ; limpiar registro de resto
    mov     eax, ecx         ; preparar dividendo
    mov     ebp, 10          ; divisor = 10
    div     ebp              ; EAX = ECX/10, EDX = ECX%10
    add     dl, '0'          ; resto a carácter ASCII
    mov     [edi], dl        ; almacenar dígito
    dec     edi              ; retroceder buffer
    mov     ecx, eax         ; actualizar ECX = cociente parcial
    test    ecx, ecx
    jnz     .C_LOOP          ; repetir si quedan dígitos

    cmp     bl, '-'          ; si había signo negativo:
    jne     .C_DONE
    mov     [edi], bl        ; escribir '-'
    dec     edi

.C_DONE:
    inc     edi              ; EDI apunta al primer carácter válido

    ; 8) Imprimir cadena resultante
    mov     eax, 4           ; syscall: sys_write
    mov     ebx, 1           ; fd = 1 (stdout)
    mov     ecx, edi         ; puntero inicio de la cadena

    ; calcular longitud = (numbuf+11) - edi
    mov     edx, numbuf+11
    sub     edx, edi

    int     0x80             ; escribir resultado

    ; 9) Salto de línea
    mov     eax, 4           ; sys_write
    mov     ebx, 1           ; stdout
    mov     ecx, newline     ; "\n"
    mov     edx, 1
    int     0x80

    ; 10) Salir clean
    mov     eax, 1           ; syscall: sys_exit
    xor     ebx, ebx         ; código 0
    int     0x80

; parse_int:
;   Entrada:
;     ECX a puntero a cadena ASCII: [espacios]* ['-']? dígitos+
;   Salida:
;     EAX = valor entero con signo
;     ECX = puntero justo tras el último dígito procesado
;   Registros usados: EAX, EBX, ECX, EDX, EBP

parse_int:
    push    ebx              ; salvar EBX (lo usamos de flag)

    ; 1) Saltar espacios, tabulaciones y newlines
.skip_ws:
    mov     al, [ecx]
    cmp     al, ' '
    je      .inc_ws
    cmp     al, 9            ; '\t'
    je      .inc_ws
    cmp     al, 10           ; '\n'
    je      .inc_ws
    jmp     .check_sign
.inc_ws:
    inc     ecx
    jmp     .skip_ws

    ; 2) Detectar signo '-'
.check_sign:
    mov     al, [ecx]
    cmp     al, '-'
    jne     .init_val
    mov     bl, 1            ; BL=1 a número negativo
    inc     ecx              ; saltar '-'
    jmp     .init_accum
.init_val:
    xor     bl, bl           ; BL=0 a positivo

    ; 3) Inicializar acumulador
.init_accum:
    xor     eax, eax         ; EAX = 0

    ; 4) Bucle de conversión de dígitos
.parse_loop:
    mov     dl, [ecx]        ; cargar carácter
    cmp     dl, '0'
    jb      .end_parse       ; fuera de rango a fin
    cmp     dl, '9'
    ja      .end_parse
    imul    eax, eax, 10     ; eax *= 10
    sub     dl, '0'          ; convertir ASCII a valor numérico
    add     eax, edx         ; añadir dígito
    inc     ecx              ; siguiente carácter
    jmp     .parse_loop

    ; 5) Finalizar parseo
.end_parse:
    cmp     bl, 1
    jne     .ret_parse
    neg     eax              ; aplicar signo si BL=1

.ret_parse:
    pop     ebx              ; restaurar EBX
    ret                      ; EAX = valor, ECX = ptr tras dígitos
