#include <stdint.h>
#include <stdio.h>

#define NUM_ALLOCS 100000
#define SIZE 1024

volatile uint8_t sink;

int main() {
    for (int i = 0; i < NUM_ALLOCS; ++i) {
        uint8_t buffer[SIZE];
        for (int j = 0; j < SIZE; j++) {
            buffer[j] = (uint8_t)j;
        }
        sink = buffer[SIZE - 1]; // prevent optimization
    }
    return 0;
}
