#include <iostream>
#include <cmath>

using namespace std;

// Функция для вычисления периметра прямоугольника
float calculateRectanglePerimeter(float length, float width) {
    return 2 * (length + width);
}

// Функция для вычисления площади прямоугольника
float calculateRectangleArea(float length, float width) {
    return length * width;
}

// Функция для вычисления длины диагонали прямоугольника
float calculateRectangleDiagonal(float length, float width) {
    return sqrt(pow(length, 2) + pow(width, 2));
}

int main() {
    setlocale(LC_ALL, "Russian");
    float length, width;
    cout << "Введите длину прямоугольника: ";
    cin >> length;
    cout << "Введите ширину прямоугольника: ";
    cin >> width;

    // Проверка на отрицательные числа
    if (length < 0 || width < 0) {
        cout << "Введите положительные числа!" << endl;
        return 1;
    }

    cout << "Периметр прямоугольника: " << calculateRectanglePerimeter(length, width) << endl;
    cout << "Площадь прямоугольника: " << calculateRectangleArea(length, width) << endl;
    cout << "Длина диагонали прямоугольника: " << calculateRectangleDiagonal(length, width) << endl;

    return 0;
}
