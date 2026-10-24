#include <iostream>
#include <vector>
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <unordered_set>

using namespace std;

// Функция a^x*mod(p)
long long modPow(long long a, long long x, long long p) {
    long long res = 1;
    a = a % p; // Убедимся, что a меньше p
    while (x > 0) {
        if (x & 1) res = (res * a) % p; // Если x нечётное, умножаем результат на a
        x = x >> 1; // Делим x на 2
        a = (a * a) % p; // Возводим a в квадрат по модулю p
    }
    return res;
}

// Функция для проверки простоты числа тестом Миллера
bool Miller(long long n, int k) {
    if (n <= 1 || n == 4) return false; // Числа меньше 2 и 4 не являются простыми
    if (n <= 3) return true; // Числа 2 и 3 простые
    long long d = n - 1;
    while (d % 2 == 0) d /= 2; // Разделяем n-1 на d * 2^s

    for (int i = 0; i < k; i++) { // Повторяем тест k раз
        long long a = 2 + rand() % (n - 4); // Выбираем случайное число a
        long long x = modPow(a, d, n); // Вычисляем a^d mod n
        if (x == 1 || x == n - 1) continue; // Если x равно 1 или n-1, продолжаем

        while (d != n - 1) { // Пока d не станет равным n-1
            x = (x * x) % n; // Возводим x в квадрат по модулю n
            d *= 2; // Умножаем d на 2
            if (x == 1) return false; // Если x равно 1, число составное
            if (x == n - 1) break; // Если x равно n-1, выходим из цикла
        }
        if (x != n - 1) return false; // Если x не равно n-1, число составное
    }
    return true; // Если все тесты пройдены, число вероятно простое
}

// Функция для проверки простоты числа тестом Поклингтона
bool Pock(long long n) {
    if (n <= 1) return false; // Числа меньше 2 не являются простыми
    if (n <= 3) return true; // Числа 2 и 3 простые
    if (n % 2 == 0 || n % 3 == 0) return false; // Чётные числа и кратные 3 не простые
    long long x = (n - 1) / 2; // Вычисляем (n-1)/2
    if (modPow(2, x, n) == n - 1) return true; // Проверяем условие теста Поклингтона
    return false; // Если условие не выполнено, число составное
}

// Функция для проверки простоты числа тестом ГОСТ Р 34.10-94
bool Gost(long long n) {
    if (n <= 1) return false; // Числа меньше 2 не являются простыми
    if (n <= 3) return true; // Числа 2 и 3 простые
    if (n % 2 == 0 || n % 3 == 0) return false; // Чётные числа и кратные 3 не простые
    long long x = (n - 1) / 2; // Вычисляем (n-1)/2
    if (modPow(2, x, n) == 1) return true; // Проверяем условие теста ГОСТ
    return false; // Если условие не выполнено, число составное
}

// Генерация простого числа заданной длины на основе теста Миллера-Рабина
long long generatePrimeMillerRabin(int length, int k) {
    while (true) {
        // Генерация случайного числа заданной длины
        long long num = rand() % (int)pow(10, length) + (int)pow(10, length - 1);
        if (Miller(num, k)) { // Проверка числа на простоту
            return num; // Если число простое, возвращаем его
        }
    }
}

// Генерация простого числа заданной длины на основе теста Поклингтона
long long generatePrimePocklington(int length) {
    while (true) {
        // Генерация случайного числа заданной длины
        long long num = rand() % (int)pow(10, length) + (int)pow(10, length - 1);
        if (Pock(num)) { // Проверка числа на простоту
            return num; // Если число простое, возвращаем его
        }
    }
}

// Генерация простого числа заданной длины на основе теста ГОСТ Р 34.10-94
long long generatePrimeGost(int length) {
    while (true) {
        // Генерация случайного числа заданной длины
        long long num = rand() % (int)pow(10, length) + (int)pow(10, length - 1);
        if (Gost(num)) { // Проверка числа на простоту
            return num; // Если число простое, возвращаем его
        }
    }
}

int main() {
    srand(time(0)); // Инициализация генератора случайных чисел текущим временем

    int length = 5; // Длина числа в цифрах
    int iterations = 5; // Количество итераций вероятностного теста
    int k = 5; // Количество итераций теста Миллера-Рабина
    int countRejected = 0; // Количество отвергнутых чисел

    unordered_set<long long> generatedPrimes; // Для хранения уже сгенерированных чисел

    // Генерация и проверка 10 простых чисел
    cout << "№\tЧисло\t\tТест\tРезультат\tОтвергнуто" << endl;
    for (int i = 1; i <= 10; i++) {
        // Генерация уникальных простых чисел
        long long primeMillerRabin, primePocklington, primeGost;
        do {
            primeMillerRabin = generatePrimeMillerRabin(length, k); // Генерация числа тестом Миллера-Рабина
        } while (generatedPrimes.count(primeMillerRabin)); // Проверка на уникальность
        generatedPrimes.insert(primeMillerRabin); // Добавление числа в множество

        do {
            primePocklington = generatePrimePocklington(length); // Генерация числа тестом Поклингтона
        } while (generatedPrimes.count(primePocklington)); // Проверка на уникальность
        generatedPrimes.insert(primePocklington); // Добавление числа в множество

        do {
            primeGost = generatePrimeGost(length); // Генерация числа тестом ГОСТ
        } while (generatedPrimes.count(primeGost)); // Проверка на уникальность
        generatedPrimes.insert(primeGost); // Добавление числа в множество

        // Проверка на простоту вероятностным тестом
        bool isPrimeMillerRabinTest = Miller(primeMillerRabin, iterations);
        bool isPrimePocklingtonTest = Pock(primePocklington);
        bool isPrimeGostTest = Gost(primeGost);

        // Подсчет количества отвергнутых чисел
        if (!isPrimeMillerRabinTest) countRejected++;
        if (!isPrimePocklingtonTest) countRejected++;
        if (!isPrimeGostTest) countRejected++;

        // Вывод результатов с названиями тестов
        cout << i << "\t" << primeMillerRabin << "\tМиллер-Рабин\t" << (isPrimeMillerRabinTest ? "+" : "-") << "\t\t" << countRejected << endl;
        cout << i << "\t" << primePocklington << "\tПоклингтон\t" << (isPrimePocklingtonTest ? "+" : "-") << "\t\t" << countRejected << endl;
        cout << i << "\t" << primeGost << "\tГОСТ\t\t" << (isPrimeGostTest ? "+" : "-") << "\t\t" << countRejected << endl;
    }

    return 0;
}