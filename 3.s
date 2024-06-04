
    .arch armv8-a

    .data
    .align 2

    .set CAESAR, 1

filename:
    .ascii "Enter filename: "
    .set filename_len, .-filename

file_error:
    .ascii "Error opening file\n"
    .set file_error_len, .-file_error

    .set buffer_cap, 1024*4

    .bss
buffer:
    .skip buffer_cap + 1
output_buffer:
    .skip buffer_cap * 2

    .text
    .align 2

    .type format_int, %function
format_int:
    mov x10, #10
    mov x5, x22
    mov x6, x2

    2:
    sdiv x4, x5, x10
    msub x3, x4, x10, x5
    mov x5, x4
    add x3, x3, '0'
    strb w3, [x2], #1
    cbnz x5, 2b
    
    sub x5, x2, #1
    4:
        cmp x5, x6 // while x5 >= x6
        ble 4f
        ldrb w3, [x5]
        ldrb w4, [x6]
        strb w3, [x6], 1
        strb w4, [x5], -1
        b 4b
    4:
    ret

    .global _start
    .type _start, %function
_start:
    mov x0, 1
    adr x1, filename
    mov x2, filename_len
    mov x8, #64
    svc #0 // output

    mov x0, 0 // stdin
    adr x1, buffer
    mov x2, buffer_cap
    mov x8, #63 // read
    svc #0
    cbz x0, exit

    adr x1, buffer
    1:
        cmp x0, 0
        beq 2f

        ldrb w7, [x1], 1
        cmp w7, '\n'
        beq 2f

        sub x0, x0, 1
        b 1b
    2:
    strb wzr, [x1, -1]
    sub x0, x0, 1

    mov x20, x0
    mov x21, x1

    mov x0, -100
    adr x1, buffer
    mov x2, 0
    mov x8, #56
    svc #0
    mov x28, x0

    cbnz x0, 1f
        // error
        adr x1, file_error
        mov x2, file_error_len
        mov x0, #1
        mov x8, #64
        svc #0
        b exit
    1:

interesting:
    mov x21, 1 // 0 if previous character was space
    mov x22, 0 // length

    loop:
        mov x0, x28 // stdin
        adr x1, buffer
        mov x2, buffer_cap
        mov x8, #63 // read
        svc #0

        cbz x0, eof
        // x0 = remaining length
        adr x1, buffer
        adr x2, output_buffer

        process:
            ldrb w7, [x1], 1
            cmp w7, ' '
            beq print_length
            cmp w7, '\t'
            beq tab
            cmp w7, '\n'
            beq print_length
            cmp w7, '\r'
            beq cr

            // word characters {
                cbnz x21, 1f
                    mov x21, 1
                    mov x22, 0
                1:
                add x22, x22, 1
                b output
            // }

            tab:
                mov w7, ' '
                b print_length
            cr:
                mov w7, '\n'
            print_length:
                cbz x21, 10f
                mov w6, ' '
                strb w6, [x2], 1
                bl format_int
            10:

            cmp w7, '\n'
            beq 1f
                // ' '
                cbz x21, skip_char // if previous character was space
            1:
            mov x21, 0

            output:
            strb w7, [x2], 1
            skip_char:
            sub x0, x0, 1
            cmp x0, xzr
            bgt process // if not all input was processed

        mov x0, 1 // stdout
        adr x1, output_buffer
        sub x2, x2, x1 // output length
        mov x8, #64
        svc #0 // output

        b loop
    eof:
    cbz x21, 10f
        adr x2, output_buffer
        mov w6, ' '
        strb w6, [x2], 1
        bl format_int
        mov x0, 1 // stdout
        adr x1, output_buffer
        sub x2, x2, x1 // output length
        mov x8, #64
        svc #0 // output
    10:

    mov x0, x28 // close file
    mov x8, #57
    svc #0
exit:
    mov x0, #0 // exit
    mov x8, #93
    svc #0

    .size   _start, (. - _start)
