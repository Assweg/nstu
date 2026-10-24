#include <iostream>

using namespace std;

// Вычисляем остаток от возведения первой степени во вторую степень по модулю 4
// Потому что последние цифры чисел при возведении в степень повторяются каждые 4 степени
int ost_degree(int FirstDegree, int SecondDegree) {
    int result = 1; 
    for (int i = 0; i < SecondDegree; i++) {
        result = (result * FirstDegree) % 4; // Умножаем и берем остаток от деления на 4
    }

    // Если результат равен 0, возвращаем 4 (т.к остаток от деления на 4 может быть 0, 1, 2, 3)
    if (result == 0) {
        return 4;
    }
    return result;
}

// Функция для нахождения последней цифры числа, возведенного в степень
int ost_vozved(int Number, int stepen) {
    int ost = 1;

    // Выполняем возведение в степень с использованием модуля 10
    for (int i = 0; i < stepen; i++) {
        ost = (ost * Number) % 10;
    }
    return ost;
}

int main() {
    cout << "Число: ";
    int number;
    cin >> number;

    cout << "Первая степень: ";
    int firstDegree;
    cin >> firstDegree;

    cout << "Вторая степень: ";
    int secondDegree;
    cin >> secondDegree;

    int ost = ost_degree(firstDegree, secondDegree);

    int lastDigit = ost_vozved(number, ost);

    cout << "Последняя цифра трехэтажного номера = " << lastDigit << endl;

    return 0;
}