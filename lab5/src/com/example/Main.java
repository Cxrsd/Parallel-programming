/*
 * Main.java
 * Демонстрирует работу обычного и собственного семафора
 */
package com.example;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

public class Main {

    // Общее количество потоков для демонстрации
    public static final int THREADS = 4;
    // Количество разрешений в семафоре
    public static final int COUNT = 2;

    // Экземпляры семафоров: обычный и пользовательский
    public static Semaphore regularSemaphore = new Semaphore(COUNT);
    public static MySemaphore mySemaphore = new MySemaphore(COUNT);

    // Счётчики активных потоков
    private static final AtomicInteger activeThreads = new AtomicInteger(0);
    private static final AtomicInteger maxActiveThreads = new AtomicInteger(0);

    public static void main(String[] args) {
        System.out.println("-------------------\nRegular semaphore:\n-------------------");
        runTask(regularSemaphore);

        System.out.println("--------------\nMy semaphore:\n--------------");
        runTask(mySemaphore);
    }

    /**
     * Запускает TASKS потоков, ограничивая одновременную работу семафором
     * @param semaphore - семафор, контролирующий доступ
     */
    private static void runTask(Semaphore semaphore) {
        List<Callable<String>> tasks = new ArrayList<>();

        // Формируем список заданий
        for (int i = 0; i < THREADS; i++) {
            tasks.add(() -> {
                String threadName = Thread.currentThread().getName();

                // Запрос разрешения у семафора
                semaphore.acquire();
                try {
                    // Увеличиваем текущий счётчик активных потоков
                    int currentActive = activeThreads.incrementAndGet();
                    // Обновляем максимум, если нужно
                    maxActiveThreads.getAndUpdate(prev -> Math.max(prev, currentActive));

                    System.out.println("Поток " + threadName + " работает. Активных потоков: " + currentActive);
                    // Симуляция работы
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                } finally {
                    // Возвращаем разрешение семафору и уменьшаем счётчик
                    activeThreads.decrementAndGet();
                    semaphore.release();
                }

                return "Thread " + threadName + " done";
            });
        }

        // Запускаем фиксированный пул потоков
        try (ExecutorService es = Executors.newFixedThreadPool(THREADS)) {
            // Блокируемся до завершения всех задач
            es.invokeAll(tasks);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        // Выводим максимум одновременных потоков
        System.out.println("Максимальное количество активных потоков: " + maxActiveThreads.get());
        // Сбрасываем счётчики для следующего запуска
        maxActiveThreads.set(0);
        activeThreads.set(0);
    }
}
