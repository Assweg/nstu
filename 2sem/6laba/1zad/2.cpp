#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <climits>
using namespace std;

int main() {
    srand(time(0));
    int N;
    cout << "Enter N: ";
    cin >> N;

    // Создание и заполнение квадратной матрицы случайными числами в диапазоне [100, 200]
    vector<vector<int>> matrix(N, vector<int>(N));
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            matrix[i][j] = rand() % 101 + 100; // Генерация чисел от 100 до 200
        }
    }

    // Вывод исходной матрицы
    cout << "Original matrix:\n";
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            cout << matrix[i][j] << "\t"; // Используем табуляцию для красивого вывода
        }
        cout << endl;
    }

    // Вычисление сумм элементов строк матрицы
    vector<int> sums(N);
    for (int i = 0; i < N; ++i) {
        int sum = 0;
        for (int j = 0; j < N; ++j) {
            sum += matrix[i][j];
        }
        sums[i] = sum;
        cout << "Sum of row " << i + 1 << ": " << sum << endl; // Вывод суммы каждой строки
    }

    // Поиск второй максимальной суммы
    int max1 = INT_MIN, max2 = INT_MIN;
    for (int sum : sums) {
        if (sum > max1) {
            max2 = max1;
            max1 = sum;
        } else if (sum > max2 && sum != max1) {
            max2 = sum;
        }
    }

    // Проверка, найдена ли вторая максимальная сумма
    if (max2 == INT_MIN) {
        cout << "No second maximum sum found!\n";
        return 1;
    }

    // Определение индекса строки со второй максимальной суммой
    int index = -1;
    for (int i = 0; i < N; ++i) {
        if (sums[i] == max2) {
            index = i;
            break;
        }
    }

    // Инициализация массива строкой со второй максимальной суммой
    vector<int> secondMaxRow = matrix[index];

    // Вывод результата
    cout << "Second max sum: " << max2 << "\nArray: ";
    for (int num : secondMaxRow) {
        cout << num << " ";
    }
    cout << endl;

    return 0;
}