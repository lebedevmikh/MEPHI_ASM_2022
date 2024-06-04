#include <time.h>
#include <inttypes.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION
#define STBI_FAILURE_USERMSG
#include "stb_image.h"
#include "stb_image_write.h"

int work(char *input, char *output, int* matrix);
uint8_t* extend(uint8_t *image, uint32_t width, uint32_t height);
void process(uint8_t *image, uint8_t *copy, uint32_t width, uint32_t height, int* matrix);
void process_asm(uint8_t *image, uint8_t *copy, uint32_t width, uint32_t height, int* matrix);

int main(int argc, char **argv) {
    if(argc < 3) {
        printf("provide input and output files\n");
        return 0;
    }

    if(access(argv[1], R_OK) != 0) {
        printf("error opening input file %s\n", argv[1]);
        return 0;
    }

    int matrix[10] = {0};

    printf("Input matrix:\n");
    for (int i = 0; i < 9; ++i) {
        scanf("%d", &matrix[i]);
        if (matrix[i] > 0)
            matrix[9] += matrix[i];
    }

    int ret = work(argv[1], argv[2], matrix);
    return ret;
}

int work(char *input, char *output, int* matrix) {
    int w, h;
    unsigned char *data = stbi_load(input, &w, &h, NULL, 3);
    
    if (data == NULL) {
        puts(stbi_failure_reason());
        return 1;
    }

    size_t size = w * h * 3;
    uint8_t *extended = extend(data, w, h);
    uint8_t *copy = malloc((w + 2) * (h + 2) * 3);

    clock_t begin = clock();

    #ifdef ASM
        process_asm(extended, copy, w + 2, h + 2, matrix);
    #else
        process(extended, copy, w + 2, h + 2, matrix);
    #endif
    
    clock_t end = clock();
    // printf("processing time: %lf\n", time_spent);
    printf("%lf", (double)(end - begin) / CLOCKS_PER_SEC);
    fflush(stdout);
    
    if (stbi_write_png(output, w, h, 3, copy + (w+2)*3+3, (w+2)*3) == 0) {
    // if (stbi_write_png(output, w + 2, h + 2, 3, copy, 0) == 0) {
        puts("Some png writing error\n");
        return 1;
    }

    free(copy);
    free(extended);
    stbi_image_free(data);
    return 0;
}

uint8_t* extend(uint8_t *image, uint32_t w, uint32_t h) {
    uint8_t *extended = malloc((w + 2) * (h + 2) * 3);

    int line1 = w * 3;
    int line2 = (w + 2) * 3;

    register int i1 = 0;
    register int i2 = line2 + 1 * 3;

    for (register int y = 0; y < h; ++y) {
        for (register int x = 0; x < w; ++x) {
            extended[i2] = image[i1];
            extended[i2+1] = image[i1+1];
            extended[i2+2] = image[i1+2];
            i1 += 3;
            i2 += 3;
        }
        i2 += 2 * 3;
    }

    i1 = line2;
    for (register int y = 1; y <= h; ++y) {
        extended[i1] = extended[i1+3];
        extended[i1+1] = extended[i1+4];
        extended[i1+2] = extended[i1+5];
        i1 += line2;
        extended[i1-3] = extended[i1-6];
        extended[i1-2] = extended[i1-5];
        extended[i1-1] = extended[i1-4];
    }

    memcpy(extended, extended + line2, line2);
    memcpy(extended + line2 * (h + 1), extended + line2 * h, line2);

    return extended;
}

static inline int process_one(uint8_t *image, int index, int line, int* matrix) {
    int res = (
          matrix[0] * (int)image[index - line - 3]
        + matrix[1] * (int)image[index - line]
        + matrix[2] * (int)image[index - line + 3]
        + matrix[3] * (int)image[index - 3]
        + matrix[4] * (int)image[index]
        + matrix[5] * (int)image[index + 3]
        + matrix[6] * (int)image[index + line - 3]
        + matrix[7] * (int)image[index + line]
        + matrix[8] * (int)image[index + line + 3]
    ) / matrix[9];
    if (res < 0)
        res = 0;
    return res;
}

void process(uint8_t *image, uint8_t *copy, uint32_t w, uint32_t h, int* matrix) {
    int line = w * 3;

    register int i = line + 3;

    for (register int y = 1; y < h - 1; ++y) {
        for (register int x = 1; x < w - 1; ++x, i += 3) {
            copy[i] = process_one(image, i, line, matrix);
            copy[i+1] = process_one(image, i+1, line, matrix);
            copy[i+2] = process_one(image, i+2, line, matrix);
        }
    }
}
