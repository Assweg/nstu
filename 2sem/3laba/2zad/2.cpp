#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>

using namespace std;

// Возведение a в степень b по модулю n
long long power(long long a, long long b, long long n) {
    long long x = 1, y = a;
    while (b > 0) {
        if (b % 2 == 1) {
            x = (x * y) % n;
        }
        y = (y * y) % n;
        b /= 2;
    }
    return x % n;
}

// Тест Миллера
bool Miller(long long n, int k) {
    if (n <= 1 || n == 4) return false;
    if (n <= 3) return true;

    long long d = n - 1;
    while (d % 2 == 0)
        d /= 2;

    for (int i = 0; i < k; i++) {
        long long a = 2 + rand() % (n - 4);
        long long x = power(a, d, n);

        if (x == 1 || x == n - 1)
            continue;

        while (d != n - 1) {
            x = (x * x) % n;
            d *= 2;

            if (x == 1) return false;
            if (x == n - 1) break;
        }

        if (x != n - 1)
            return false;
    }

    return true;
}

// Тест Поклингтона
bool Pock(long long n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0) return false;

    long long a = 2 + rand() % (n - 3);
    long long x = power(a, n - 1, n);

    if (x != 1)
        return false;

    return true;
}

// Тест Госта
bool Gost(long long p, int iteration) {
    if (p < 2) return false;
    if (p != 2 && p % 2 == 0) return false;

    for (int i = 0; i < iteration; i++) {
        long long a = rand() % (p - 1) + 1;
        long long urav1 = (p + power(a, (p - 1) / 2, p)) % p;
        long long mod = power(a, (p - 1) / 2, p);

        if (urav1 == 0 || mod != urav1)
            return false;
    }
    return true;
}

// Проверка на простоту
vector<bool> isPrime(long long n, int k) {
    vector<bool> results(3, true);
    if (n <= 1 || n == 4) {
        return { false, false, false };
    }
    if (n <= 3) {
        return { true, true, true };
    }
    for (int i = 0; i < k; i++) {
        results[0] = results[0] && Miller(n, k);
        results[1] = results[1] && Pock(n);
        results[2] = results[2] && Gost(n, k);
    }
    return results;
}

// Построение таблицы простых чисел
vector<bool> Eratosthen(int n) {
    vector<bool> prime(n + 1, true);
    prime[0] = prime[1] = false;
    for (int p = 2; p * p <= n; p++) {
        if (prime[p] == true) {
            for (int i = p * p; i <= n; i += p)
                prime[i] = false;
        }
    }
    return prime;
}

// Генерация простых чисел заданной длины
vector<int> generatePrimes(int length) {
    vector<int> primes;
    vector<bool> prime = Eratosthen(1000); // Увеличиваем верхнюю границу
    for (int i = 2; i < 1000 && primes.size() < length; i++) {
        if (prime[i]) {
            primes.push_back(i);
        }
    }
    return primes;
}

int main() {
    srand(static_cast<unsigned int>(time(0))); // Инициализируем генератор случайных чисел
    int k = 10; // Количество итераций тестов
    int length = 10; // Длина генерируемых простых чисел

    // Генерация простых чисел
    vector<int> primes = generatePrimes(length);

    // Вывод таблицы
    cout << "№\tP\tМиллер\tПоклингтон\tГост" << endl;
    for (int i = 0; i < primes.size(); i++) {
        vector<bool> results = isPrime(primes[i], k);
        cout << i + 1 << "\t" << primes[i] << "\t"
            << (results[0] ? "+" : "-") << "\t"
            << (results[1] ? "+" : "-") << "\t\t"
            << (results[2] ? "+" : "-") << endl;
    }

    return 0;
}