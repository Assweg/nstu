#include <iostream>
#include <cmath>

using namespace std;

// Функция для проверки, являются ли два числа взаимно простыми
bool areCoprime(int a, int b) {
    int counter = 1; // Счетчик общего количества делителей
    for (int i = 2; i <= min(a, b); i++) {
        if ((a % i == 0) && (b % i == 0)) { // Условие для проверки делимости обоих чисел на i
            counter += 1;
        }
    }

    if (counter == 1) { // Если есть только один общий делитель
        return true;
    } else {
        return false;
    }
}

// Функция находит НОД чисел a и b, используя алгоритм Евклида 
// Вычисляет коэффициенты Безу x и y для линейного представления НОД(a, b)
int gcd(int a, int b, int& x, int& y) {
    int orig_A = a;
    int orig_B = b;
    x = 1;
    y = 0;
    int x1 = 0;
    int y1 = 1;

    while (b > 0) {
        int q = a / b;
        int r = a - q * b;
        int x2 = x - q * x1;
        int y2 = y - q * y1;
        a = b;
        b = r;
        x = x1;
        y = y1;
        x1 = x2;
        y1 = y2;
    }

    return a;
}

// Функция для нахождения обратного элемента c по модулю m
int findInverse(int c, int m) {
    int x, y;
    int g = gcd(c, m, x, y);

    if (g != 1) { // Если НОД не равен 1, обратного элемента не существует
        cout << "Обратного элемента не существует, так как c и m не взаимно просты." << endl;
        return -1;
    } else {
        // Приводим x к положительному виду, если он отрицательный
        x = (x % m + m) % m;
        return x;
    }
}

int main() {
    cout << "Введите положительные числа c и m:" << endl;

    cout << "Число c: ";
    int c;
    cin >> c;

    cout << "Число m: ";
    int m;
    cin >> m;

    if (c <= 0 || m <= 0) { // Проверка на положительные числа
        cout << "Неправильный ввод числа" << endl;
        return 0;
    }

    // if (c >= m) { // Проверка, что c < m
    //     cout << "c должно быть меньше m" << endl;
    //     return 0;
    // }

    // Проверка, являются ли c и m взаимно простыми
    if (!areCoprime(c, m)) {
        cout << "c и m не являются взаимно простыми. Обратного элемента не существует." << endl;
        return 0;
    }

    // Находим обратный элемент
    int d = findInverse(c, m);

    if (d != -1) { // Если обратный элемент существует
        cout << "Обратный элемент d для c по модулю m: " << d << endl;
        cout << "Проверка: " << c << " * " << d << " mod " << m << " = " << (c * d) % m << endl;
    }

    return 0;
}