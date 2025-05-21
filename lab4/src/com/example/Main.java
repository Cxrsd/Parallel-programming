package com.example;

import java.util.*;
import java.util.concurrent.*;

public class Main {

    public static final int THREADS = 50;
    public static final int ITERATIONS = 100_000;
    public static final double NSEC = 1000_000_000.0;
    public static final int MAP_SIZE = 3;

    public static Map<String, Integer> hashMap = new HashMap<>();
    public static Map<String, Integer> hashTable = new Hashtable<>();
    public static Map<String, Integer> syncMap = Collections.synchronizedMap(new HashMap<>());
    public static Map<String, Integer> cHashMap = new ConcurrentHashMap<>();

    public static void main(String[] args) {
        System.out.println("=== Стандартный read-modify-write (get+put) ===");
        runAndCheck("HashMap", hashMap, Main::plainReadModifyWrite);
        runAndCheck("Hashtable", hashTable, Main::plainReadModifyWrite);
        runAndCheck("SynchronizedMap", syncMap, Main::plainReadModifyWrite);
        runAndCheck("ConcurrentHashMap", cHashMap, Main::plainReadModifyWrite);

        System.out.println("\n=== Синхронизированный read-modify-write для Hashtable и SynchronizedMap ===");
        runAndCheck("HashMap", hashMap, Main::synchronizedReadModifyWrite);
        runAndCheck("Hashtable (synchronized block)", hashTable, Main::synchronizedReadModifyWrite);
        runAndCheck("SynchronizedMap (synchronized block)", syncMap, Main::synchronizedReadModifyWrite);
        runAndCheck("ConcurrentHashMap", cHashMap, Main::synchronizedReadModifyWrite);

        System.out.println("\n=== Атомарный инкремент для Map ===");
        runAndCheck("HashMap", hashMap, Main::atomicIncrement);
        runAndCheck("Hashtable", hashTable, Main::atomicIncrement);
        runAndCheck("SynchronizedMap", syncMap, Main::atomicIncrement);
        runAndCheck("ConcurrentHashMap", cHashMap, Main::atomicIncrement);
    }

    // Универсальный прогон: передаем функцию инкремента
    private static void runAndCheck(String name, Map<String, Integer> map, IncrementMethod method) {
        double timeSec = ((double) compute(map, method)) / NSEC;
        int expected = THREADS * ITERATIONS;
        int actual = 0;
        for (int i = 0; i < MAP_SIZE; i++) {
            actual += map.getOrDefault("key-" + i, 0);
        }
        System.out.println(name + ":\n\tExpected sum: " + expected + "\n\tActual sum:   " + actual +
                "\n\tTime: " + String.format("%.3f", timeSec) + " s\n" +
                (expected == actual ? "\t[OK]" : "\t[DATA RACE!]\n")
        );
    }

    // Универсальная compute, метод инкремента передается как strategy
    private static long compute(Map<String, Integer> map, IncrementMethod method) {
        map.clear();
        for (int i = 0; i < MAP_SIZE; i++) {
            map.put("key-" + i, 0);
        }
        long start = System.nanoTime();

        ExecutorService executorService = Executors.newFixedThreadPool(THREADS);
        List<Callable<Void>> tasks = new ArrayList<>();
        for (int t = 0; t < THREADS; t++) {
            tasks.add(() -> {
                Random rnd = ThreadLocalRandom.current();
                for (int i = 0; i < ITERATIONS; i++) {
                    String key = "key-" + rnd.nextInt(MAP_SIZE);
                    method.increment(map, key);
                }
                return null;
            });
        }
        try {
            executorService.invokeAll(tasks);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        executorService.shutdown();

        long stop = System.nanoTime();
        return stop - start;
    }

    // Обычный read-modify-write для всех карт
    private static void plainReadModifyWrite(Map<String, Integer> map, String key) {
        int oldVal = map.getOrDefault(key, 0);
        map.put(key, oldVal + 1);
    }

    // Синхронизированный read-modify-write для потокобезопасных, но не атомарных карт
    private static void synchronizedReadModifyWrite(Map<String, Integer> map, String key) {
        synchronized (map) {
            int oldVal = map.getOrDefault(key, 0);
            map.put(key, oldVal + 1);
        }
    }

    // Атомарный инкремент через merge для ConcurrentHashMap
    private static void atomicIncrement(Map<String, Integer> map, String key) {
        map.merge(key, 1, Integer::sum);
    }

    // Функциональный интерфейс для метода инкремента
    @FunctionalInterface
    interface IncrementMethod {
        void increment(Map<String, Integer> map, String key);
    }
}
