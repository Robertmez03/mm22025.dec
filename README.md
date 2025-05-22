# Operaciones Aritméticas en NASM (32 bits, Linux)

Este repositorio contiene tres programas escritos en NASM (Intel syntax, modo 32 bits) que ilustran operaciones básicas de resta, multiplicación y división usando llamadas al sistema de Linux.

## Requisitos:
- Linux con soporte IA-32 o modo multilib x86
- NASM (`nasm`)
- Enlazador `ld` compatible con ELF i386
- Terminal (bash, sh, etc.)

## Compilación y enlace:

Desde la raíz del proyecto, para cada archivo `.asm`:
- `nasm -f elf32 <archivo>.asm -o <archivo>.o`
- `ld -m elf_i386 <archivo>.o -o <ejecutable>`

## Programas:

### 1) resta_enteros.asm
- **bits** 32
- **Datos**: `num1`, `num2`, `num3` (16 bits)
- Calcula `num1 – num2 – num3` en `AX`
- Convierte el resultado a ASCII decimal (5 dígitos) + salto de línea
- Imprime con el prefijo “Result: ”

**Compilar & Ejecutar:**
```bash
nasm -f elf32 resta_enteros.asm -o resta_enteros.o
ld -m elf_i386 resta_enteros.o -o resta_enteros
./resta_enteros

**Salida esperada:**
Result: 00100
(150 – 30 – 20 = 100)

### 2) multiplicacion.asm
**bits** 32
**Datos**: `num1`, `num2` (8 bits)
- Producto en AX (16 bits)
- Convierte el resultado a 4 dígitos hex + salto de línea
- Imprime con el prefijo “Result: 0x”

**Compilar & Ejecutar:**
```bash
nasm -f elf32 multiplicacion.asm -o multiplicacion.o
ld -m elf_i386 multiplicacion.o -o multiplicacion
./multiplicacion

**Salida esperada:**
Result: 0x000A
(10 × 1 = 10, 0x000A)

### 3) division.asm
**bits** 32
**Interactivo**: pide “Ingresa dos numeros Enteros(separado por un espacio. ej: 10 2):”
- Parseo de dos enteros con signo (rutina parse_int)
- División con signo (idiv), muestra el cociente
- Imprime “Resultado: ” + cociente en ASCII + salto de línea

**Compilar & Ejecutar:**
```bash
nasm -f elf32 division.asm -o division.o
ld -m elf_i386 division.o -o division
./division

**Ejemplo de uso:**
Ingresa dos numeros Enteros(separado por un espacio. ej: 10 2):
25 -4
Resultado: -6

## Notas:
- Todos usan llamadas al sistema Linux vía int 0x80 (sys_read, sys_write, sys_exit).
- Asegúrate de tener soporte para binarios x86 de 32 bits.
- Los buffers de conversión están dimensionados para ceros a la izquierda y signo.
