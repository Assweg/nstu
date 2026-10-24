#include <iostream>
#include <cmath>
using namespace std;

// Рекурсивная функция для нахождения НОД
int gcd(int a, int b) {
    if (b == 0)
        return a;
    return gcd(b, a % b);
}

// Функция для нахождения коэффициентов x и y для линейного представления НОД(a, b)
void extendedEuclid(int a, int b, int &x, int &y) {
    if (b == 0) {
        x = 1;
        y = 0;
        return;
    }
    int x1, y1;
    extendedEuclid(b, a % b, x1, y1);
    x = y1;
    y = x1 - (a / b) * y1;
}

// Функция для вычисления обратного элемента по модулю
int modInverse(int c, int m) {
    int x, y;
    extendedEuclid(c, m, x, y);

    // Если НОД(c, m) != 1, обратного элемента не существует
    if (gcd(c, m) != 1) {
        return -1; // Возвращаем -1 как индикатор ошибки
    }

    // Приводим x к положительному значению в пределах [0, m-1]
    return (x % m + m) % m;
}

int main() {
    int c, m;
    cout << "Введите число c и модуль m для вычисления c^(-1) mod m: " << endl;
    cout << "Число c: ";
    cin >> c;
    cout << "Модуль m: ";
    cin >> m;

    if (c <= 0 || m <= 0) {
        cout << "Неверно введённые данные" << endl;
        return 0;
    }

    int inverse = modInverse(c, m);

    if (inverse == -1) {
        cout << "Обратный элемент не существует, так как НОД(" << c << ", " << m << ") != 1." << endl;
    } else {
        cout << "Обратный элемент c^(-1) mod m = " << inverse << endl;
    }

    return 0;
}