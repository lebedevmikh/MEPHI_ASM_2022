CC       := aarch64-linux-gnu-gcc
AS       := aarch64-linux-gnu-as
LD       := aarch64-linux-gnu-ld
FLAGS 	 := -g -static

.PHONY: default
default: build

.PHONY: build
build: *.s *.c
	$(CC) $(OPTIMIZATION) $(FLAGS) -o  image.out $^ -lm

.PHONY: buildasm
buildasm: *.s *.c
	$(CC) $(OPTIMIZATION) $(FLAGS) -DASM -o image.out $^ -lm


.PHONY: run
run: image.out
	@qemu-aarch64 image.out test/input2.png test/output2.png < input.txt
