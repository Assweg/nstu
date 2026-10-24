#include <iostream>
#include <vector>
#include <algorithm>
#include <random>

using namespace std;

int main() {
    // Генерация случайных чисел
    random_device rd;         // Создаем генератор случайных чисел
    mt19937 gen(rd());        // Инициализируем генератор псевдослучайных чисел начальным значением
    uniform_int_distribution<> dis(10, 100); // Распределение в диапазоне от 10 до 100

    // Пункт 1: Создание массива
    const int n = 15; // Размер массива
    vector<int> arr(n);
    for (int& num : arr) {
        num = dis(gen);
    }

    // Вывод массива
    cout << "Массив: ";
    for (int num : arr) {
        cout << num << " ";
    }
    cout << endl;

    // Пункт 2: Нахождение двух наименьших элементов и вычисление суммы остатков
    vector<int> sortedArr = arr;
    sort(sortedArr.begin(), sortedArr.end());
    int min1 = sortedArr[0];
    int min2 = sortedArr[1];

    int sumRemainders = 0;
    for (int num : arr) {
        sumRemainders += num % min1;
    }

    cout << "Два наименьших элемента: " << min1 << " и " << min2 << endl;
    cout << "Сумма остатков от деления на минимальный элемент: " << sumRemainders << endl;

    // Пункт 3: Нахождение самой длинной возрастающей последовательности
    vector<int> longestSequence; // Для хранения самой длинной возрастающей последовательности
    vector<int> currentSequence; // Для хранения текущей возрастающей последовательности

    // Проходим по всем элементам массива
    for (size_t i = 0; i < arr.size(); ++i) {
        if (currentSequence.empty() || arr[i] > currentSequence.back()) {
            currentSequence.push_back(arr[i]);
        } else {
            // Если текущая последовательность прервалась, сравниваем её длину с longestSequence
            if (currentSequence.size() > longestSequence.size()) {
                // Если currentSequence длиннее, обновляем longestSequence
                longestSequence = currentSequence;
            }
            // Очищаем currentSequence и начинаем новую последовательность с текущего элемента
            currentSequence.clear();
            currentSequence.push_back(arr[i]);
        }
    }

    // После завершения цикла проверяем последнюю currentSequence,
    // так как она может быть самой длинной
    if (currentSequence.size() > longestSequence.size()) {
        longestSequence = currentSequence;
    }

    cout << "Самая длинная возрастающая последовательность: ";
    for (int num : longestSequence) {
        cout << num << " ";
    }
    cout << endl;
    
    // Пункт 4: Вывод массива длиной N × 8
    const int N = 5; // Значение второй N
    vector<int> bigArray(N * 8);
    bigArray[0] = 2000; 
    for (size_t i = 1; i < bigArray.size(); ++i) {
        bigArray[i] = bigArray[i - 1] + 10;
    }

    // Вывод 1: Обычный порядок
    cout << "Вывод 1:" << endl;
    for (size_t i = 0; i < bigArray.size(); ++i) {
        if (i % 8 == 0 && i != 0) {
            cout << endl;
        }
        cout << bigArray[i] << " ";
    }
    cout << endl;

    // Вывод 2: Обратный порядок
    cout << "Вывод 2:" << endl;
    for (int i = bigArray.size() - 1; i >= 0; --i) {
        if ((bigArray.size() - i - 1) % 8 == 0 && i != bigArray.size() - 1) {
            cout << endl;
        }
        cout << bigArray[i] << " ";
    }
    cout << endl;

    return 0;
}