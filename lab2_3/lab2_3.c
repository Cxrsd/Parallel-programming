#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <math.h>
#include <omp.h>
#include <time.h>

int counter = 0;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
#define ITERATIONS 100000000  // изменить при необходимости

// «Тяжёлая» функция для Pthreads:(мьютекс закомментирован/чистая производительность)
void *heavy_task(void *arg) {
    int id = *(int*)arg;
    free(arg);

    printf("\tThread #%d started\n", id);

    pthread_mutex_lock(&mutex);
    counter++;
    pthread_mutex_unlock(&mutex);

    volatile double acc = 0.0;
    for (int i = 0; i < ITERATIONS; i++) {
        acc += sqrt((double)i);
    }

    printf("\tThread #%d finished\n", id);
    return NULL;
}

// Запуск Pthreads
void pthreads(int threads_num) {
    pthread_t threads[threads_num];
    for (int i = 0; i < threads_num; i++) {
        int *tid = malloc(sizeof(int));
        *tid = i;
        printf("MAIN: starting thread %d\n", i);
        pthread_create(&threads[i], NULL, heavy_task, tid);
    }
    for (int i = 0; i < threads_num; i++) {
        pthread_join(threads[i], NULL);
    }
    pthread_mutex_destroy(&mutex);
}

// «Тяжёлая» функция для OpenMP: старт/финиш
void openmp_heavy_task() {
    int id = omp_get_thread_num();
    printf("\tid: %d started\n", id);

    volatile double acc = 0.0;
    for (int i = 0; i < ITERATIONS; i++) {
        acc += sqrt((double)i);
    }

    printf("\tid: %d finished\n", id);
}

// Последовательная версия: старт/финиш каждой задачи
void sequential(int num_tasks) {
    for (int t = 0; t < num_tasks; t++) {
        printf("\tSequential task #%d started\n", t);
        volatile double acc = 0.0;
        for (int i = 0; i < ITERATIONS; i++) {
            acc += sqrt((double)i);
        }
        printf("\tSequential task #%d finished\n", t);
    }
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <num_tasks>\n", argv[0]);
        return 1;
    }
    int n = atoi(argv[1]);

    struct timespec t0, t1;

    // 1. Последовательное выполнение
    printf("=== Последовательное выполнение ===\n");
    clock_gettime(CLOCK_MONOTONIC, &t0);
    sequential(n);
    clock_gettime(CLOCK_MONOTONIC, &t1);
    printf("Wall-time sequential: %.3f s\n\n",
           (t1.tv_sec - t0.tv_sec) + (t1.tv_nsec - t0.tv_nsec) * 1e-9);

    // 2. Pthreads выполнение
    printf("=== Pthreads выполнение ===\n");
    clock_gettime(CLOCK_MONOTONIC, &t0);
    pthreads(n);
    clock_gettime(CLOCK_MONOTONIC, &t1);
    printf("Wall-time Pthreads:   %.3f s\n\n",
           (t1.tv_sec - t0.tv_sec) + (t1.tv_nsec - t0.tv_nsec) * 1e-9);

    // 3. OpenMP выполнение
    printf("=== OpenMP выполнение ===\n");
    double o0 = omp_get_wtime();
    omp_set_dynamic(0);
    omp_set_num_threads(n);
    //небольшая оптимизация
    #pragma omp parallel for schedule(static,1)
    for (int i = 0;i<n;i++){
        openmp_heavy_task();
    }
    double o1 = omp_get_wtime();
    printf("Wall-time OpenMP:     %.3f s\n", o1 - o0);

    return 0;
}
