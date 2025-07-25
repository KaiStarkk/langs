gcc -O2 -o stack_alloc.exe stack_alloc.c
gcc -O2 -o heap_alloc.exe heap_alloc.c
hyperfine 'stack_alloc.exe' 'heap_alloc.exe'
