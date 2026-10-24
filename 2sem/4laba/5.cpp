#include <iostream>
#include <vector>
#include <cstdint>

using namespace std;

// Класс для генерации псевдослучайных чисел с использованием Xorshift
class Xorshift {
private:
    uint32_t state; // Внутреннее состояние генератора

public:
    // Конструктор: инициализация начального состояния (seed)
    Xorshift(uint32_t seed = 1) : state(seed) {}

    // Метод для генерации следующего псевдослучайного числа
    uint32_t next() {
        uint32_t x = state;
        x ^= x << 13;  // Битовый сдвиг влево
        x ^= x >> 17;  // Битовый сдвиг вправо
        x ^= x << 5;   // Битовый сдвиг влево
        state = x;     // Обновление состояния
        return x;      // Возврат нового числа
    }

    // Метод для генерации числа в заданном диапазоне [min, max]
    uint32_t nextInRange(uint32_t min, uint32_t max) {
        uint32_t range = max - min + 1;
        return min + (next() % range);
    }
};

int main() {
    // Инициализация генератора с начальным значением (seed)
    Xorshift rng(123456);

    // Генерация и вывод 10 случайных чисел
    cout << "Случайные числа:\n";
    for (int i = 0; i < 10; ++i) {
        cout << rng.next() << endl;
    }

    // Генерация чисел в диапазоне [10, 50]
    cout << "\nСлучайные числа в диапазоне [10, 50]:\n";
    for (int i = 0; i < 10; ++i) {
        cout << rng.nextInRange(10, 50) << endl;
    }

    return 0;
}