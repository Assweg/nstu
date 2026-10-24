#include <iostream>
#include <iomanip>
#include <cmath>

using namespace std;

// // Функция для первой ветви
// double y1(double x) {
//     double a = 0.5;
//     double b = 8.0;
//     double c = 32.0;
//     return a * x * x + b * x + c;
// }

double y1(double x) {
    double h = -8.0; // Точка пересечения с x
    double k = 2.0; 
    double r = 2.0;  // Радиус
    return k - sqrt(r * r - pow(x - h, 2));
}

// Функция для второй ветви
double y2(double x) {
    return 2.0;
}

// Функция для третьей ветви
double y3(double x) {
    return -0.5 * x;
}

// Функция для четвёртой ветви
double y4(double x) {
    return x - 3.0;
}

int main() {
    // Параметры
    double xStart = -10; // Начальное значение X
    double xEnd = 4;     // Конечное значение X
    double dx = 1;       // Шаг

    // Заголовок таблицы
    cout << setw(10) << "X" << setw(10) << "Y" << setw(10) << " Ветка" << endl;
    cout << setw(10) << "---------" << setw(10) << "---------" << setw(10) << "---------" << endl;

    // Цикл для вычисления и вывода значений функции
    for (double x = xStart; x <= xEnd; x += dx) {
        double y;
        int branch = 0;

        if (x >= -10 && x <= -6) {
            y = y1(x);
            branch = 1;
        } 
        else if (x >= -6 && x <= -4) {
            y = y2(x);
            branch = 2;
        } 
        else if (x >= -4 && x <= 2) {
            y = y3(x);
            branch = 3;
        }
        else if (x >= 2 && x <= 4) {
            y = y4(x);
            branch = 4;
        }

        cout << fixed << setprecision(2); // Точность вывода до 2 знаков после запятой
        cout << setw(10) << x << setw(10) << y << setw(10) << branch << endl;
    }

    return 0;
}