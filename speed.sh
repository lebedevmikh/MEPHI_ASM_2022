#!/bin/bash

declare -a opti=()

rm ./test/output*.png

for opti in "-O0" "-O1" "-O2" "-O3" "-Ofast"; do
    printf "%-8s" "${opti}: "
    for file in ./test/input*; do
        name=${file##*/}
        make build OPTIMIZATION="${opti}" > /dev/null
        echo -n `qemu-aarch64 image3.out ${file} test/output${name}`
        printf " "
    done
    echo
done

printf "asm:    "
for file in ./test/input*; do
    name=${file##*/}
    make buildasm > /dev/null
    echo -n `qemu-aarch64 image3.out ${file} test/output${name}`
    printf " "
done
echo
echo
