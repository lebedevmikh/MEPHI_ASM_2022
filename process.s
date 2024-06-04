
    .arch armv8-a

    .text
    .align 2

    .global process_asm
    .type process_asm, %function
process_asm:
    // x0 = uint8_t *image
    // x1 = uint8_t *copy
    // w2 = uint32_t width
    // w3 = uint32_t height
    // w4 = uint32_t matrix
    mov x11, x4

    mov x4, #3
    mul x4, x2, x4 // line = w * 3

    add x0, x0, x4
    add x0, x0, #3  // index = &image[line + 3]
    add x1, x1, x4
    add x1, x1, #3 

    sub w3, w3, #1 // height -= 1
    sub w2, w2, #1 // width -= 1

    mov x5, x0 // i = &image[0]
    mov x6, #1 // y = 1
    rows:
        cmp x6, x3
        bge exit_process_arm

        mov x7, #1 // x = 1
        pixels:
            cmp x7, x2
            bge end_pixels

            // R
            ldrb w8, [x0]
            ldr w12, [x11, 4*4]
            mul w8, w8, w12

            sub x10, x0, x4 // index - line
            ldrb w9, [x10, #3]
            ldr w12, [x11, 2*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x10]
            ldr w12, [x11, 1*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x10, #-3]
            ldr w12, [x11, 0*4]
            mul w9, w9, w12
            add w8, w8, w9

            ldrb w9, [x0, #3]
            ldr w12, [x11, 5*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x0, #-3]
            ldr w12, [x11, 3*4]
            mul w9, w9, w12
            add w8, w8, w9

            add x10, x0, x4 // index + line
            ldrb w9, [x10, #3]
            ldr w12, [x11, 8*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x10]
            ldr w12, [x11, 7*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x10, #-3]
            ldr w12, [x11, 6*4]
            mul w9, w9, w12
            add w8, w8, w9

            ldr w12, [x11, 9*4]
            sdiv w8, w8, w12
            cmp w8, 0
            csel w8, wzr, w8, mi
            strb w8, [x1]
            add x0, x0, #1
            add x1, x1, #1

            // G
            ldrb w8, [x0]
            ldr w12, [x11, 4*4]
            mul w8, w8, w12

            sub x10, x0, x4 // index - line
            ldrb w9, [x10, #3]
            ldr w12, [x11, 2*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x10]
            ldr w12, [x11, 1*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x10, #-3]
            ldr w12, [x11, 0*4]
            mul w9, w9, w12
            add w8, w8, w9

            ldrb w9, [x0, #3]
            ldr w12, [x11, 5*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x0, #-3]
            ldr w12, [x11, 3*4]
            mul w9, w9, w12
            add w8, w8, w9

            add x10, x0, x4 // index + line
            ldrb w9, [x10, #3]
            ldr w12, [x11, 8*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x10]
            ldr w12, [x11, 7*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x10, #-3]
            ldr w12, [x11, 6*4]
            mul w9, w9, w12
            add w8, w8, w9

            ldr w12, [x11, 9*4]
            sdiv w8, w8, w12
            cmp w8, 0
            csel w8, wzr, w8, mi
            strb w8, [x1]
            add x0, x0, #1
            add x1, x1, #1

            // B
            ldrb w8, [x0]
            ldr w12, [x11, 4*4]
            mul w8, w8, w12

            sub x10, x0, x4 // index - line
            ldrb w9, [x10, #3]
            ldr w12, [x11, 2*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x10]
            ldr w12, [x11, 1*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x10, #-3]
            ldr w12, [x11, 0*4]
            mul w9, w9, w12
            add w8, w8, w9

            ldrb w9, [x0, #3]
            ldr w12, [x11, 5*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x0, #-3]
            ldr w12, [x11, 3*4]
            mul w9, w9, w12
            add w8, w8, w9

            add x10, x0, x4 // index + line
            ldrb w9, [x10, #3]
            ldr w12, [x11, 8*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x10]
            ldr w12, [x11, 7*4]
            mul w9, w9, w12
            add w8, w8, w9
            ldrb w9, [x10, #-3]
            ldr w12, [x11, 6*4]
            mul w9, w9, w12
            add w8, w8, w9

            ldr w12, [x11, 9*4]
            sdiv w8, w8, w12
            cmp w8, 0
            csel w8, wzr, w8, mi
            strb w8, [x1]
            add x0, x0, #1
            add x1, x1, #1

            add x7, x7, #1
            b pixels
        end_pixels:

        add x6, x6, #1
        b rows
    exit_process_arm:
    ret

    .size   process_asm, (. - process_asm)
