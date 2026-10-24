#include <iostream>
#include <vector>
#include <algorithm>
#include <random>
#include <ctime>

using namespace std;

// Функция для генерации случайного пароля
string generatePassword(int length, bool useUppercase, bool useLowercase, bool useDigits, bool useSpecialChars) {
    // Векторы для хранения символов каждого типа
    vector<char> uppercase = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 
                                'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
    vector<char> lowercase = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 
                                'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
    vector<char> digits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
    vector<char> specialChars = {'!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '_', '+', '='};

    // Вектор для хранения всех доступных символов
    vector<char> allChars;

    // Добавляем символы в общий вектор в зависимости от выбора пользователя
    if (useUppercase) allChars.insert(allChars.end(), uppercase.begin(), uppercase.end());
    if (useLowercase) allChars.insert(allChars.end(), lowercase.begin(), lowercase.end());
    if (useDigits) allChars.insert(allChars.end(), digits.begin(), digits.end());
    if (useSpecialChars) allChars.insert(allChars.end(), specialChars.begin(), specialChars.end());

    // Проверка, что хотя бы один тип символов выбран
    if (allChars.empty()) {
        cerr << "Ошибка: Не выбран ни один тип символов для пароля." << endl;
        return "";
    }

    // Генератор случайных чисел
    mt19937 rng(time(0));
    uniform_int_distribution<int> dist(0, allChars.size() - 1);

    // Генерация пароля
    string password;
    for (int i = 0; i < length; ++i) {
        password += allChars[dist(rng)];
    }

    // Перемешиваем пароль
    shuffle(password.begin(), password.end(), rng);

    return password;
}

int main() {
    // Ввод параметров от пользователя
    int length;
    bool useUppercase, useLowercase, useDigits, useSpecialChars;

    cout << "Введите длину пароля: ";
    cin >> length;

    cout << "Использовать заглавные буквы (1 - да, 0 - нет): ";
    cin >> useUppercase;

    cout << "Использовать строчные буквы (1 - да, 0 - нет): ";
    cin >> useLowercase;

    cout << "Использовать цифры (1 - да, 0 - нет): ";
    cin >> useDigits;

    cout << "Использовать специальные символы (1 - да, 0 - нет): ";
    cin >> useSpecialChars;

    // Генерация пароля
    string password = generatePassword(length, useUppercase, useLowercase, useDigits, useSpecialChars);

    // Вывод результата
    if (!password.empty()) {
        cout << "Ваш пароль: " << password << endl;
    }

    return 0;
}