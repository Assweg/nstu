#include <iostream>
#include <vector>
#include <thread>
#include <regex>
#include <chrono>

using namespace std;

// Структура для хранения данных о товарах
struct Product {
    string code;       // Код товара
    int quantity;      // Количество товара
    double price;      // Стоимость товара
};

// Функция для обработки данных в одном потоке
double processDataSingleThread(const vector<Product>& products, const regex& pattern) {
    double totalCost = 0.0;  // Инициализация общей стоимости
    for (const auto& product : products) {  // Проход по всем товарам
        if (regex_match(product.code, pattern)) {  // Проверка соответствия кода товара шаблону
            totalCost += product.quantity * product.price;  // Добавление стоимости товара к общей стоимости
        }
    }
    return totalCost;  // Возврат общей стоимости
}

// Функция для обработки данных в многопоточном режиме
void processDataMultiThread(const vector<Product>& products, const regex& pattern, double& totalCost, int start, int end) {
    double localTotalCost = 0.0;  // Инициализация локальной общей стоимости для текущего потока
    for (int i = start; i < end; ++i) {  // Проход по части массива товаров, заданной индексами start и end
        if (regex_match(products[i].code, pattern)) {  // Проверка соответствия кода товара шаблону
            localTotalCost += products[i].quantity * products[i].price;  // Добавление стоимости товара к локальной общей стоимости
        }
    }
    totalCost += localTotalCost;  // Добавление локальной общей стоимости к общей стоимости
}

int main() {
    // Задаем данные
    int arraySize = 1000000;  // Размер массива товаров
    int numThreads = 3;  // Количество потоков
    string patternStr = R"(^[A-Z]{3}\d{3}$)";  // Шаблон регулярного выражения: три буквы и три цифры
    regex pattern(patternStr);  // Создание объекта регулярного выражения

    // Создаем массив данных
    vector<Product> products(arraySize);  // Создание массива товаров
    for (int i = 0; i < arraySize; ++i) {  // Заполнение массива товаров случайными данными
        products[i].code = "ABC" + to_string(i % 1000);  // Код товара: "ABC" + трехзначное число
        products[i].quantity = (i % 10) + 1;  // Количество товара: от 1 до 10
        products[i].price = (i % 100) + 1.0;  // Стоимость товара: от 1.0 до 100.0
    }

    // Обработка данных в одном потоке
    auto startSingleThread = chrono::high_resolution_clock::now();  // Засекаем время начала обработки
    double totalCostSingleThread = processDataSingleThread(products, pattern);  // Обработка данных в одном потоке
    auto endSingleThread = chrono::high_resolution_clock::now();  // Засекаем время окончания обработки
    auto durationSingleThread = chrono::duration_cast<chrono::milliseconds>(endSingleThread - startSingleThread).count();  // Вычисляем время выполнения

    // Обработка данных в многопоточном режиме
    auto startMultiThread = chrono::high_resolution_clock::now();  // Засекаем время начала обработки
    vector<thread> threads;  // Создаем вектор потоков
    vector<double> threadResults(numThreads, 0.0);  // Создаем вектор для хранения результатов каждого потока
    int chunkSize = arraySize / numThreads;  // Размер части массива, обрабатываемой одним потоком

    for (int i = 0; i < numThreads; ++i) {  // Создаем потоки
        int start = i * chunkSize;  // Начальный индекс части массива для текущего потока
        int end = (i == numThreads - 1) ? arraySize : (i + 1) * chunkSize;  // Конечный индекс части массива для текущего потока
        threads.emplace_back(processDataMultiThread, ref(products), ref(pattern), ref(threadResults[i]), start, end);  // Запуск потока
    }

    for (auto& thread : threads) {  // Ожидаем завершения всех потоков
        thread.join();
    }

    double totalCostMultiThread = 0.0;  // Инициализация общей стоимости для многопоточного режима
    for (double result : threadResults) {  // Суммируем результаты всех потоков
        totalCostMultiThread += result;
    }

    auto endMultiThread = chrono::high_resolution_clock::now();  // Засекаем время окончания обработки
    auto durationMultiThread = chrono::duration_cast<chrono::milliseconds>(endMultiThread - startMultiThread).count();  // Вычисляем время выполнения

    // Вывод результатов
    cout << "Single-threaded processing time: " << durationSingleThread << " ms" << endl;  // Время выполнения в одном потоке
    cout << "Multi-threaded processing time: " << durationMultiThread << " ms" << endl;  // Время выполнения в многопоточном режиме
    cout << "Total cost (single-threaded): " << totalCostSingleThread << endl;  // Общая стоимость в одном потоке
    cout << "Total cost (multi-threaded): " << totalCostMultiThread << endl;  // Общая стоимость в многопоточном режиме

    return 0;
}