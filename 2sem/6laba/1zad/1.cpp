#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
using namespace std;

int main() {
    srand(time(0));
    int M, N;
    cout << "Enter M and N: ";
    cin >> M >> N;

    // Создание и заполнение матрицы случайными числами
    vector<vector<int>> matrix(M, vector<int>(N));
    for (int i = 0; i < M; ++i) {
        for (int j = 0; j < N; ++j) {
            matrix[i][j] = rand() % 101 - 50; // Генерация чисел от -50 до 50
        }
    }

    // Вывод исходной матрицы
    cout << "Original matrix:\n";
    for (int i = 0; i < M; ++i) {
        for (int j = 0; j < N; ++j) {
            cout << matrix[i][j] << "\t"; // Используем табуляцию для красивого вывода
        }
        cout << endl;
    }

    // Выбор элементов из четных строк с нечетными столбцами и подсчет их суммы
    vector<int> selectedElements;
    int sum = 0;
    for (int i = 0; i < M; ++i) {
        if ((i + 1) % 2 == 0) { // Проверка на четную строку
            for (int j = 0; j < N; ++j) {
                if ((j + 1) % 2 != 0 && matrix[i][j] >= 0) { // Проверка на нечетный столбец и положительное число
                    sum += matrix[i][j];
                    selectedElements.push_back(matrix[i][j]);
                }
            }
        }
    }

    cout << "Sum of selected elements: " << sum << endl;

    // Вывод массива выбранных элементов
    cout << "Selected elements array: ";
    for (int num : selectedElements) {
        cout << num << " ";
    }
    cout << endl;

    return 0;
}