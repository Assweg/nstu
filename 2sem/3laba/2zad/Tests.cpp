#include <iostream>
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <vector>
#include <chrono>

using namespace std;
using namespace std::chrono;

// Метод перебора делителей
bool isPrimeTrialDivision(int n) {
    if (n <= 1) return false; // Числа меньше или равные 1 не являются простыми
    if (n <= 3) return true;  // 2 и 3 — простые числа
    if (n % 2 == 0 || n % 3 == 0) return false; // Исключаем числа, кратные 2 или 3
    // Проверяем делители от 5 до квадратного корня из n
    for (int i = 5; i * i <= n; i += 6) {
        if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
}

// Возведение в степень по модулю (a^d*mod(n)) для Теста Миллера и Тест по ГОСТ 
long long powerMod(long long a, long long d, long long n) {
    long long result = 1;
    a = a % n; // Убедимся, что a меньше n
    while (d > 0) {
        if (d % 2 == 1) {
            result = (result * a) % n; // Умножаем результат на a по модулю n
        }
        a = (a * a) % n; // Возводим a в квадрат по модулю n
        d = d / 2; // Делим степень на 2
    }
    return result;
}

// Тест Миллера
bool millerRabinTest(long long d, long long n) {
    long long a = 2 + rand() % (n - 4); // Выбираем случайное число a в диапазоне [2, n-2]
    long long x = powerMod(a, d, n); // Вычисляем a^d mod n
    if (x == 1 || x == n - 1) return true;
    while (d != n - 1) {
        x = (x * x) % n;
        d *= 2;
        if (x == 1) return false;
        if (x == n - 1) return true;
    }
    return false;
}

bool isPrimeMillerRabin(long long n, int k) {
    if (n <= 1 || n == 4) return false; // Исключаем числа меньше или равные 1 и число 4
    if (n <= 3) return true; // 2 и 3 — простые числа
    long long d = n - 1;
    while (d % 2 == 0) {
        d /= 2; // Находим нечетное d, такое что n-1 = d * 2^s
    }
    for (int i = 0; i < k; i++) {
        if (!millerRabinTest(d, n)) return false; // Повторяем тест k раз
    }
    return true;
}

// Тест Поклингтона
bool isPrimePocklington(long long n, const vector<long long>& factors) {
    if (n <= 1) return false; // Числа меньше или равные 1 не являются простыми
    if (n <= 3) return true;  // 2 и 3 — простые числа
    for (long long p : factors) {
        if (n % p == 0) return false; // Если n делится на любой из множителей, оно составное
    }
    return true; // Если делителей нет, число простое
}

// Тест ГОСТ Р 34.10-94
bool isPrimeGOST(long long n) {
    if (n <= 1) return false; // Числа меньше или равные 1 не являются простыми
    if (n <= 3) return true;  // 2 и 3 — простые числа
    if (n % 2 == 0) return false; // Исключаем четные числа
    long long s = 0;
    long long d = n - 1;
    while (d % 2 == 0) {
        d /= 2; // Находим нечетное d, такое что n-1 = d * 2^s
        s++;
    }
    for (int a = 2; a <= 5; a++) { // Проверяем для a = 2, 3, 4, 5
        long long x = powerMod(a, d, n); // Вычисляем a^d mod n
        if (x == 1 || x == n - 1) continue; // Если x равно 1 или n-1, переходим к следующему a
        for (long long i = 0; i < s - 1; i++) {
            x = powerMod(x, 2, n); // Возводим x в квадрат по модулю n
            if (x == 1) return false; // Если x равно 1, число составное
            if (x == n - 1) break; // Если x равно n-1, переходим к следующему a
        }
        if (x != n - 1) return false; // Если x не равно n-1, число составное
    }
    return true; // Если все проверки пройдены, число простое
}

int main() {

    srand(time(0)); // Генерация случайных чисел

    long long n;
    int k = 5; // Количество итераций для теста Миллера-Рабина

    cout << "Введите число для проверки на простоту: ";
    cin >> n;
    cout << endl;

    // Метод перебора делителей
    if (isPrimeTrialDivision(n)) {
        cout << "Метод перебора делителей: Простое" << endl;
    } else {
        cout << "Метод перебора делителей: Составное" << endl;
    }

    // Тест Миллера-Рабина
    if (isPrimeMillerRabin(n, k)) {
        cout << "Тест Миллера-Рабина: Простое" << endl;
    } else {
        cout << "Тест Миллера-Рабина: Составное" << endl;
    }

    // Тест Поклингтона
    vector<long long> factors = {2, 3, 5};
    if (isPrimePocklington(n, factors)) {
        cout << "Тест Поклингтона: Простое" << endl;
    } else {
        cout << "Тест Поклингтона: Составное" << endl;
    }

    // Тест по ГОСТ Р 34.10-94
    if (isPrimeGOST(n)) {
        cout << "Тест ГОСТ Р 34.10-94: Простое" << endl;
    } else {
        cout << "Тест ГОСТ Р 34.10-94: Составное" << endl;
    }
    cout << endl;

    return 0;
}