#include <iostream>
#include <thread>       // Для работы с потоками
#include <vector> 
#include <random>       // Для генерации случайных чисел
#include <mutex>        // Для использования мьютексов
#include <semaphore>    // Для использования семафоров
#include <barrier>      // Для использования барьеров
#include <atomic>       // Для использования атомарных операций
#include <chrono>       // Для измерения времени выполнения
#include <functional> 
#include <algorithm> 

using namespace std;

const int NUM_THREADS = 3; // Количество потоков
const int NUM_ITERATIONS = 100000; // Количество итераций

// Мьютекс для синхронизации вывода
mutex outputMutex;

// Функция, которая будет выполняться в каждом потоке
void threadFunction(int id, function<void()> syncPrimitive, vector<char>& results) {
    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<> dis(32, 126); // ASCII

    char lastChar = '\0'; // Переменная для хранения последнего сгенерированного символа

    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        syncPrimitive(); // Вызываем примитив синхронизации
        lastChar = static_cast<char>(dis(gen)); // Генерируем случайный символ
        syncPrimitive(); // Вызываем примитив синхронизации снова
        this_thread::sleep_for(chrono::microseconds(10)); // Добавим небольшую задержку
    }

    // Сохраняем последний сгенерированный символ в вектор результатов
    results[id] = lastChar;
}

// Примитив синхронизации: Mutex
void mutexSync() {
    static mutex mtx;
    lock_guard<mutex> lock(mtx); // Блокируем мьютекс
}

// Запуск потоков с использованием Mutex
void runWithMutex() {
    vector<thread> threads; // Создает вектор потоков, который будет содержать все созданные потоки
    vector<char> results(NUM_THREADS, '\0'); // Вектор для хранения результатов

    for (int i = 0; i < NUM_THREADS; ++i) {
        threads.emplace_back(threadFunction, i, mutexSync, ref(results)); // Создаем поток с функцией и примитивом синхронизации
    }

    for (auto& t : threads) {
        t.join(); // Дожидаемся завершения всех потоков
    }

    // Выводим результаты
    for (int i = 0; i < NUM_THREADS; ++i) {
        cout << "Thread " << i << " result: " << results[i] << endl;
    }
}

// Примитив синхронизации: Semaphore
void semaphoreSync() {
    static counting_semaphore<3> sem(3);
    sem.acquire(); // Захватываем семафор
    sem.release(); // Освобождаем семафор
}

// Запуск потоков с использованием Semaphore
void runWithSemaphore() {
    vector<thread> threads;
    vector<char> results(NUM_THREADS, '\0'); // Вектор для хранения результатов

    for (int i = 0; i < NUM_THREADS; ++i) {
        threads.emplace_back(threadFunction, i, semaphoreSync, ref(results));
    }

    for (auto& t : threads) {
        t.join();
    }

    // Выводим результаты
    for (int i = 0; i < NUM_THREADS; ++i) {
        cout << "Thread " << i << " result: " << results[i] << endl;
    }
}

// Примитив синхронизации SemaphoreSlim
class SemaphoreSlim {
public:
    // Конструктор, принимающий начальное количество разрешений
    SemaphoreSlim(int initialCount) : count(initialCount) {}

    // Метод для захвата
    void acquire() {
        unique_lock<mutex> lock(mtx); // Блокируем мьютекс для безопасного доступа к count
        while (count == 0) { 
            cv.wait(lock); // Ожидаем уведомления
        }
        --count;
    }

    // Метод для освобождения семафора
    void release() {
        lock_guard<mutex> lock(mtx); // Блокируем мьютекс для безопасного доступа к count
        ++count;
        cv.notify_one(); // Уведомляем один из ожидающих потоков
    }

private:
    mutex mtx; // Мьютекс для синхронизации доступа к count
    condition_variable cv; // Условная переменная для уведомления
    int count; // Количество доступных разрешений
};

void semaphoreSlimSync() {
    static SemaphoreSlim sem(3);
    sem.acquire(); // Захватываем семафор
    sem.release(); // Освобождаем семафор
}

// Запуск потоков с использованием SemaphoreSlim
void runWithSemaphoreSlim() {
    vector<thread> threads;
    vector<char> results(NUM_THREADS, '\0'); // Вектор для хранения результатов

    for (int i = 0; i < NUM_THREADS; ++i) {
        threads.emplace_back(threadFunction, i, semaphoreSlimSync, ref(results));
    }

    for (auto& t : threads) {
        t.join();
    }

    // Выводим результаты
    for (int i = 0; i < NUM_THREADS; ++i) {
        cout << "Thread " << i << " result: " << results[i] << endl;
    }
}

// Примитив синхронизации: Barrier
void barrierSync() {
    static barrier bar(NUM_THREADS);
    bar.arrive_and_wait(); // Прибываем и ждем остальных потоков
}

// Запуск потоков с использованием Barrier
void runWithBarrier() {
    vector<thread> threads; // создается вектор для хранения объектов потоков
    vector<char> results(NUM_THREADS, '\0'); // Вектор для хранения результатов

    // Запуск потоков
    for (int i = 0; i < NUM_THREADS; ++i) {
        threads.emplace_back(threadFunction, i, barrierSync, ref(results));
        // Каждый поток выполняет функцию threadFunction, передавая ей номер потока, функцию barrierSync и ссылку на вектор results
    }

    for (auto& t : threads) {
        t.join(); // Ожидание завершения поток
    }

    // Выводим результаты
    for (int i = 0; i < NUM_THREADS; ++i) {
        cout << "Thread " << i << " result: " << results[i] << endl;
    }
}

// Примитив синхронизации: SpinLock
void spinLockSync() {
    static atomic_flag lock = ATOMIC_FLAG_INIT;
    while (lock.test_and_set(memory_order_acquire)) {
    }
    lock.clear(memory_order_release);
}

// Запуск потоков с использованием SpinLock
void runWithSpinLock() {
    vector<thread> threads;
    vector<char> results(NUM_THREADS, '\0'); // Вектор для хранения результатов

    for (int i = 0; i < NUM_THREADS; ++i) {
        threads.emplace_back(threadFunction, i, spinLockSync, ref(results));
    }

    for (auto& t : threads) {
        t.join();
    }

    // Выводим результаты
    for (int i = 0; i < NUM_THREADS; ++i) {
        cout << "Thread " << i << " result: " << results[i] << endl;
    }
}

// Примитив синхронизации: SpinWait
void spinWaitSync() {
    static atomic<bool> lock(false);
    while (lock.exchange(true, memory_order_acquire)) {
        this_thread::yield();
    }
    lock.store(false, memory_order_release);
}

// Запуск потоков с использованием SpinWait
void runWithSpinWait() {
    vector<thread> threads;
    vector<char> results(NUM_THREADS, '\0'); // Вектор для хранения результатов

    for (int i = 0; i < NUM_THREADS; ++i) {
        threads.emplace_back(threadFunction, i, spinWaitSync, ref(results));
    }

    for (auto& t : threads) {
        t.join();
    }

    // Выводим результаты
    for (int i = 0; i < NUM_THREADS; ++i) {
        cout << "Thread " << i << " result: " << results[i] << endl;
    }
}

// Примитив синхронизации: Monitor (используем mutex и condition_variable)
void monitorSync() {
    static mutex mtx;
    static condition_variable cv;
    unique_lock<mutex> lock(mtx);
    cv.notify_one();
}

// Запуск потоков с использованием Monitor
void runWithMonitor() {
    vector<thread> threads;
    vector<char> results(NUM_THREADS, '\0'); // Вектор для хранения результатов

    for (int i = 0; i < NUM_THREADS; ++i) {
        threads.emplace_back(threadFunction, i, monitorSync, ref(results));
    }

    for (auto& t : threads) {
        t.join();
    }

    // Выводим результаты
    for (int i = 0; i < NUM_THREADS; ++i) {
        cout << "Thread " << i << " result: " << results[i] << endl;
    }
}

// Функция для измерения времени выполнения
void measureTime(function<void()> func, const string& name) {
    auto start = chrono::high_resolution_clock::now(); // Засекаем начало времени
    func(); // Выполняем функцию
    auto end = chrono::high_resolution_clock::now(); // Засекаем конец времени
    chrono::duration<double> duration = end - start; // Вычисляем продолжительность
    cout << name << " took " << duration.count() << " seconds" << endl; // Выводим результат
}

int main() {
    measureTime(runWithMutex, "Mutex");
    measureTime(runWithSemaphore, "Semaphore");
    measureTime(runWithSemaphoreSlim, "SemaphoreSlim");
    measureTime(runWithBarrier, "Barrier");
    measureTime(runWithSpinLock, "SpinLock");
    measureTime(runWithSpinWait, "SpinWait");
    measureTime(runWithMonitor, "Monitor");

    return 0;
}