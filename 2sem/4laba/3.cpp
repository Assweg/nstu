#include <iostream>
#include <random>
#include <vector>
#include <cmath>
#include <algorithm>

using namespace std;

// Функция для генерации случайных чисел в заданном диапазоне
vector<int> generateRandomNumbers(int size, int min, int max) {
    // Инициализация генератора случайных чисел
    random_device rd;  // Источник энтропии
    mt19937 gen(rd()); // Генератор Mersenne Twister
    uniform_int_distribution<> dis(min, max); // Равномерное распределение в диапазоне [min, max]

    // Создание вектора для хранения случайных чисел
    vector<int> numbers(size);
    for (int i = 0; i < size; ++i) {
        numbers[i] = dis(gen); // Генерация случайного числа и добавление в вектор
    }
    return numbers;
}

// Функция для расчета критерия хи-квадрат
double chiSquareTest(const vector<int>& data, int min, int max, int bins) {
    int n = data.size(); // Размер выборки
    double expected = n / static_cast<double>(bins); // Ожидаемое количество элементов в каждом интервале
    double chiSquare = 0.0; // Инициализация значения хи-квадрат

    // Вектор для хранения наблюдаемых частот в каждом интервале
    vector<int> observed(bins, 0);

    // Подсчет количества элементов в каждом интервале
    for (int num : data) {
        int bin = (num - min) * bins / (max - min + 1); // Определение интервала для числа
        observed[bin]++; // Увеличение счетчика для соответствующего интервала
    }

    // Расчет значения хи-квадрат
    for (int i = 0; i < bins; ++i) {
        chiSquare += pow(observed[i] - expected, 2) / expected; // Формула хи-квадрат
    }

    return chiSquare;
}

int main() {
    // Размеры выборок для тестирования
    int sizes[] = {50, 100, 1000};
    int min = 1, max = 100; // Диапазон случайных чисел
    int bins = 10; // Количество интервалов для критерия хи-квадрат

    // Перебор разных размеров выборок
    for (int size : sizes) {
        // Генерация случайных чисел
        vector<int> data = generateRandomNumbers(size, min, max);

        // Расчет значения критерия хи-квадрат
        double chiSquare = chiSquareTest(data, min, max, bins);

        // Вывод результатов
        cout << "Размер выборки: " << size << endl;
        cout << "Значение критерия хи-квадрат: " << chiSquare << endl;

        // Проверка гипотезы о нормальном распределении
        double criticalValue = 16.919; // Критическое значение для 9 степеней свободы и уровня значимости 0.05
        if (chiSquare < criticalValue) {
            cout << "Гипотеза о нормальном распределении не отвергается." << endl;
        } else {
            cout << "Гипотеза о нормальном распределении отвергается." << endl;
        }

        // Расчет реального и ожидаемого математического ожидания
        double expectedMean = (min + max) / 2.0; // Ожидаемое математическое ожидание для равномерного распределения
        double actualMean = accumulate(data.begin(), data.end(), 0.0) / size; // Реальное математическое ожидание

        cout << "Ожидаемое математическое ожидание: " << expectedMean << endl;
        cout << "Реальное математическое ожидание: " << actualMean << endl;
        cout << endl;
    }

    return 0;
}