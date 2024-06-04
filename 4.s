    .arch armv8-a
    .data
useg:
    .string "Use: ./prog4 file\n"
format_int:
    .string "%d"
filestruct:
    .skip   8
file_format:
    .string   "%lf\n"
k:
    .skip   8
format_f:
    .string "%lf"
p_ln:
    .string "ln(1+x): %lf = "
res:
    .string "%lf\n"
mode:
    .string "w"
    .text
    .align  2
    .global main
    .type   main, %function
    .equ    filename, 50
    .equ    x, 32
main:
    sub     sp, sp, #500
    stp     x29, x30, [sp]
    stp     x27, x28, [sp, #16]
    mov     x29, sp
    cmp     w0, #2
    beq     open_file
    adr     x0, useg
    bl      printf
    b       end
open_file:
    ldr     x0, [x1, #8]
    str     x0, [x29, filename]
    adr     x1, mode
    bl      fopen
    cbnz    x0, read_file
    ldr     x0, [x29, filename]
    bl      perror
    b       end
read_file:
    adr     x9, filestruct
    str     x0, [x9]
    adr     x0, format_f
    add     x1, x29, x
    bl      scanf
    ldr	    d15, [x29, x]
    cmp     w0, #1
    beq     read_k
    b       close_file
read_k:
    adr     x0, format_int
    adr     x1, k
    bl      scanf
    adr     x1, k
    ldr     x21, [x1]
    cmp     w0, #1
    beq     calculate_ln
    b       close_file
calculate_ln:
    fmov    d0, #1.0
    fadd    d0, d0, d15
    bl      log
    adr     x0, p_ln
    bl      printf
    mov     x20, #1
    fcvt    s11, d15
    fmov    s9, s11
    fsub    s10, s9, s9
    fmov    s13, #1.0
    fmov    s14, #1.0
    fmov    s8, s11
    mov     x22, #1
    b       start_while
start_while:
    fdiv    s11, s9, s14
    cmp     x22, #1
    beq     2f
    fsub    s10, s10, s11
    mov     x22, #1
    b       3f
2:
    fadd    s10, s10, s11
    mov     x22, #0
3:
    fcvt    d0, s10
    subs    x7, x21, x20
    ble     show_format_fult
    adr     x0, filestruct
    ldr	    x0, [x0]
    adr     x1, file_format
    bl      fprintf
    add     x20, x20, #1
    fmul    s9, s8, s9
    fadd    s14, s14, s13
    b       start_while
show_format_fult:
    adr     x0, res
    bl      printf
close_file:
    adr     x0, filestruct
    ldr     x0, [x0]
    bl      fclose
end:
    mov     w0, #0
    ldp     x29, x30, [sp]
    ldp     x27, x28, [sp, #16]
    add     sp, sp, #500
    ret
    .size	main, .-main
