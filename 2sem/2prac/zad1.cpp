#include <iostream>
#include <vector>
#include <algorithm>
#include <cmath>

using namespace std;

// Функция для проверки, является ли число p простым
bool isPrime(int number) {
    if (number <= 1) return false; // Числа меньше 2 не являются простыми
    if (number == 2 || number == 3) return true; // 2 и 3 — простые
    if (number % 2 == 0 || number % 3 == 0) return false; // Чётные числа и кратные 3 не простые

    // Проверяются делители вида 6k+-1
    for (int i = 5; i * i <= number; i += 6) {
        if (number % i == 0 || number % (i + 2) == 0) return false;
    }
    return true;
}

// Функция для вычисления НОД
int gcd(int a, int b) {
    while (b != 0) {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

// Функция для проверки условия теоремы Ферма (для второго метода)
bool fermatCondition(int base, int prime) {
    if (prime <= 1 || !isPrime(prime)) return false; // p должно быть простым
    if (gcd(base, prime) != 1) return false; // base и p должны быть взаимно просты
    return true;
}

// Функция для перевода числа в двоичный вид
vector<int> toBinary(uint64_t number) {
    vector<int> binary;
    while (number > 0) {
        binary.push_back(number % 2); // Добавляем остаток от деления на 2
        number /= 2; // Делим число на 2
    }
    reverse(binary.begin(), binary.end()); // Переворачиваем вектор для корректного порядка
    return binary;
}

// Функция для вычисления остатков возведения в степень (для второго метода)
vector<uint64_t> calculateRemainders(uint64_t base, uint64_t exponent, uint64_t modulus) {
    int t = log2(exponent); // Количество битов в степени
    vector<uint64_t> remainders;
    remainders.push_back(base % modulus); // Начальное значение

    for (int i = 1; i <= t; ++i) {
        base = (base * base) % modulus; // Возводим в квадрат и берём по модулю
        remainders.push_back(base); // Добавляем результат в вектор
    }

    reverse(remainders.begin(), remainders.end()); // Переворачиваем вектор для правильного порядка
    return remainders;
}

// Первый метод – перебор
uint64_t firstMethod(uint64_t base, uint64_t exponent, uint64_t modulus) {
    if (base % modulus == 0) return 0; // Если base делится на modulus, результат 0
    uint64_t result = 1;

    for (size_t i = 1; i <= exponent; i++) {
        result = (result * base) % modulus; // Последовательно умножаем и берём по модулю
    }

    return result;
}

// Второй метод - алгоритм "возведения в квадрат и умножения"
uint64_t secondMethod(uint64_t base, uint64_t exponent, uint64_t modulus) {
    if (!isPrime(modulus)) {
        cout << "Ошибка: p должно быть простым числом." << endl;
        return 0;
    }

    if (!fermatCondition(base, modulus)) {
        cout << "Ошибка: условие теоремы Ферма не выполнено." << endl;
        return 0;
    }

    vector<int> binary = toBinary(exponent); // Двоичное разложение степени
    vector<uint64_t> remainders = calculateRemainders(base, exponent, modulus); // Остатки
    cout << endl;

    cout << "Двочиное представление степени: ";
    for (int bit : binary) cout << bit;
    cout << endl;
    cout << "Если бит равен 0 то пропускаем";
    uint64_t result = 1;
    for (size_t i = 0; i < binary.size(); ++i) {
        cout << "Шаг " << i + 1 << ":" << endl;
        cout << "Бит: " << binary[i] << endl;
        cout << "Остаток: " << remainders[i] << endl;

        if (binary[i] == 1) {
            uint64_t prev = result;
            result = (result * remainders[i]) % modulus; // Умножаем на соответствующий остаток
            cout << prev << " * " << remainders[i] << " mod " << modulus << " = " << result << endl;
        }
        else {
            cout << "Пропускаем" << endl;
        }
        cout << "Результат: " << result << endl << endl;
    }
    return result;
}

int main() {
    uint64_t base, exponent, modulus;

    cout << "Введите число а больше 1: ";
    cin >> base;
    cout << "Введите степень x: ";
    cin >> exponent;
    cout << "Введите простое число p: ";
    cin >> modulus;

    if (base <= 0 || exponent <= 0 || modulus <= 1) {
        cout << "Ошибка: введены некорректные данные." << endl;
        return 0;
    }

    // Проверяем, является ли p простым числом
    if (!isPrime(modulus)) {
        cout << "Ошибка: p должно быть простым числом." << endl;
        return 0;
    }

    // Проверяем условие теоремы Ферма
    if (!fermatCondition(base, modulus)) {
        cout << "Ошибка: условие теоремы Ферма не выполнено." << endl;
        return 0;
    }

    // Вычисляем первым методом
    uint64_t firstMethodResult = firstMethod(base, exponent, modulus);
    cout << "Результат первого метода: " << firstMethodResult << endl;

    // Вычисляем вторым методом
    uint64_t secondMethodResult = secondMethod(base, exponent, modulus);
    if (secondMethodResult != 0) {
        cout << "Результат второго метода: " << secondMethodResult << endl;
    }

    return 0;
}