/*
 * MySemaphore.java
 * Собственная реализация считающего семафора на ReentrantLock и Condition
 */
package com.example;

import java.util.concurrent.Semaphore;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

public class MySemaphore extends Semaphore {
    // Блокировка для синхронизации доступа к permits
    private final ReentrantLock lock = new ReentrantLock();
    // Условие для ожидания, когда будут доступны разрешения
    private final Condition permitsAvailable = lock.newCondition();
    // Текущее количество разрешений
    private int permits;

    /**
     * Конструктор: сохраняем начальное число разрешений
     */
    public MySemaphore(int permits) {
        super(permits);
        this.permits = permits;
    }

    /**
     * Захват разрешения: ждём, пока permits > 0
     */
    @Override
    public void acquire() throws InterruptedException {
        lock.lock();
        try {
            // Ждём, пока есть доступные разрешения
            while (permits <= 0) {
                permitsAvailable.await();
            }
            // Уменьшаем счётчик разрешений
            permits--;
        } finally {
            lock.unlock();
        }
    }

    /**
     * Освобождение разрешения: увеличиваем permits и сигнализируем одному ожидающему
     */
    @Override
    public void release() {
        lock.lock();
        try {
            permits++;
            permitsAvailable.signal();
        } finally {
            lock.unlock();
        }
    }

    /**
     * Возвращает текущее число доступных разрешений
     */
    @Override
    public int availablePermits() {
        return permits;
    }
}