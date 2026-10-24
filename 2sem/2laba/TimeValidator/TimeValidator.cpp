#include <iostream>
#include <string>

using namespace std;

bool isValidTime(const string& time) {
    if (time.length() != 4) {
        return false; // Должно быть ровно 4 цифры
    }

    // Первые 2 символа - часы, последние 2 символа - минуты
    string hours = time.substr(0, 2);
    string minutes = time.substr(2, 2);

    // Преобразуем строки в числа
    int h = stoi(hours);
    int m = stoi(minutes);

    // Проверяем диапазоны
    return (h >= 0 && h <= 23) && (m >= 0 && m <= 59);
}

int main() {
    string input;
    cout << "Введите последовательность чисел: ";
    cin >> input;

    if (isValidTime(input)) {
        cout << "YES" << endl;
    } else {
        cout << "NO" << endl;
    }

    return 0;
}