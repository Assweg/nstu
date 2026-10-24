#include <iostream>
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <string>
#include <tuple>
#include <vector>

using namespace std;

// Функция для вычисления (НОД)
unsigned long long gcd(unsigned long long a, unsigned long long b) {
    while (b != 0) {
        unsigned long long t = b;
        b = a % b;
        a = t;
    }
    return a;
}

// Функция для нахождения обратного элемента по модулю для приватного ключа d
unsigned long long modInverse(unsigned long long a, unsigned long long m) {
    for (unsigned long long x = 1; x < m; x++) {
        if ((a * x) % m == 1) {
            return x; // Возвращаем обратный элемент
        }
    }
    return 0; // Если обратного элемента нет, возвращаем 0
}

// Функция для проверки, является ли число простым
bool isPrime(unsigned long long n) {
    if (n < 2) return false; // Числа меньше 2 не являются простыми
    for (unsigned long long i = 2; i <= sqrt(n); i++) {
        if (n % i == 0) return false; // Если число делится на i, оно не простое
    }
    return true; // Если делителей нет, число простое
}

// Функция для генерации случайного простого числа
unsigned long long generatePrime() {
    unsigned long long prime;
    do {
        prime = rand() % 100 + 10; // Генерация числа в диапазоне [10, 110]
    } while (!isPrime(prime)); // Повторяем, пока не найдём простое число
    return prime;
}

// Функция для генерации ключей (e, d, n)
tuple<unsigned long long, unsigned long long, unsigned long long> generateKeys() {
    unsigned long long p = generatePrime(); // Генерация первого простого числа
    unsigned long long q = generatePrime(); // Генерация второго простого числа
    unsigned long long n = p * q; // Вычисление модуля n
    unsigned long long phi = (p - 1) * (q - 1); // Вычисление функции Эйлера φ(n)
    unsigned long long e = 3; // Начальное значение для e

    // Ищем e, взаимно простое с φ(n)
    while (gcd(e, phi) != 1) {
        e++;
    }

    // Находим d, обратное к e по модулю φ(n)
    unsigned long long d = modInverse(e, phi);

    // Возвращаем открытый ключ (e, n) и закрытый ключ d
    return make_tuple(e, d, n);
}

// Функция для шифрования одного числа
unsigned long long encrypt(unsigned long long plaintext, unsigned long long e, unsigned long long n) {
    unsigned long long cipher = 1;
    for (unsigned long long i = 0; i < e; i++) {
        cipher = (cipher * plaintext) % n; // Возведение в степень по модулю
    }
    return cipher;
}

// Функция для расшифрования одного числа
unsigned long long decrypt(unsigned long long cipher, unsigned long long d, unsigned long long n) {
    unsigned long long plaintext = 1;
    for (unsigned long long i = 0; i < d; i++) {
        plaintext = (plaintext * cipher) % n; // Возведение в степень по модулю
    }
    return plaintext;
}

// Функция для шифрования сообщения
vector<unsigned long long> encryptMessage(const string& message, unsigned long long e, unsigned long long n) {
    vector<unsigned long long> encryptedMessage;
    for (char c : message) {
        // Шифруем каждый символ сообщения
        encryptedMessage.push_back(encrypt(static_cast<unsigned long long>(c), e, n));
    }
    return encryptedMessage;
}

// Функция для расшифрования сообщения
string decryptMessage(const vector<unsigned long long>& encryptedMessage, unsigned long long d, unsigned long long n) {
    string decryptedMessage;
    for (unsigned long long cipher : encryptedMessage) {
        // Расшифровываем каждый элемент зашифрованного сообщения
        decryptedMessage += static_cast<char>(decrypt(cipher, d, n));
    }
    return decryptedMessage;
}

int main() {
    srand(static_cast<unsigned>(time(0))); // Инициализация генератора случайных чисел

    // Генерация ключей
    auto [e, d, n] = generateKeys();

    // Вывод открытого и закрытого ключей
    cout << "Public key (e, n): (" << e << ", " << n << ")\n";
    cout << "Private key (d): " << d << "\n";

    // Ввод сообщения для шифрования
    string message;
    cout << "Enter a message to encrypt: ";
    getline(cin, message);

    // Шифрование сообщения
    auto encryptedMessage = encryptMessage(message, e, n);

    // Вывод зашифрованного сообщения
    cout << "Encrypted message: ";
    for (const auto& cipher : encryptedMessage) {
        cout << cipher << " ";
    }
    cout << "\n";

    // Расшифрование сообщения
    string decryptedMessage = decryptMessage(encryptedMessage, d, n);
    cout << "Decrypted message: " << decryptedMessage << "\n";

    return 0;
}