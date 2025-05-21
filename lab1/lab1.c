#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <xmmintrin.h>

// Запрещаем inline, чтобы ф-ции остались реальным вызовом
// __attribute__((noinline))
// void sse_mul(volatile float *a,
//              volatile float *b,
//              volatile float *c) 
// {
//     __m128 va = _mm_loadu_ps((float*)a);
//     __m128 vb = _mm_loadu_ps((float*)b);
//     __m128 vc = _mm_mul_ps(va, vb);
//     _mm_storeu_ps((float*)c, vc);
// }
void sse_mul(float a[], float b[], float c[]) {
  asm volatile (
                "movups %[a], %%xmm0\n"
                "movups %[b], %%xmm1\n"
                "mulps %%xmm1, %%xmm0\n"
                "movups %%xmm0, %[c]\n"
                :
                : [a]"m"(*a), [b]"m"(*b), [c]"m"(*c)
                : "%xmm0", "%xmm1");
//   for (int i = 0; i < 4; i++) {
//     printf("%f ", c[i]);
//   }
//   printf("\n");
// // 
}

__attribute__((noinline))
void seq_mul(float a[], float b[], float c[]) 
{
    for (int i = 0; i < 4; i++)
        c[i] = a[i] * b[i];
}

static double diff_sec(const struct timespec *t0,
                       const struct timespec *t1) {
    return (t1->tv_sec  - t0->tv_sec)
         + (t1->tv_nsec - t0->tv_nsec) / 1e9;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <outer_iterations>\n", argv[0]);
        return 1;
    }
    long outer = atol(argv[1]);
    const int inner = 1000;

    // volatile — чтобы компилятор не убирал повторные записи/чтения
    float a[4] = {1,2,3,4};
    float b[4] = {5,6,7,8};
    float c[4] = {0};
    float d[4] = {0};

    struct timespec t0, t1;

    // // — Прогрев SSE —
    // for (int i = 0; i < inner; i++)
    //     sse_mul(a, b, c);

    clock_gettime(CLOCK_MONOTONIC, &t0);
    for (long i = 0; i < outer; i++) {
        // for (int j = 0; j < inner; j++)
            sse_mul(a, b, c);
    }
    clock_gettime(CLOCK_MONOTONIC, &t1);
    double time_sse = diff_sec(&t0, &t1);

    // // — Прогрев Sequential —
    // for (int i = 0; i < inner; i++)
    //     seq_mul(a, b, d);

    clock_gettime(CLOCK_MONOTONIC, &t0);
    for (long i = 0; i < outer; i++) {
        // for (int j = 0; j < inner; j++)
            seq_mul(a, b, d);
    }
    clock_gettime(CLOCK_MONOTONIC, &t1);
    double time_seq = diff_sec(&t0, &t1);

    printf("SSE:        %.6f s   -> %.2f %.2f %.2f %.2f\n",
           time_sse, c[0],c[1],c[2],c[3]);
    printf("Sequential: %.6f s   -> %.2f %.2f %.2f %.2f\n",
           time_seq, d[0],d[1],d[2],d[3]);
    return 0;
}
