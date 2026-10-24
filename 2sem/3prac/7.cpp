#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

// Структура для хранения информации о грузе
struct Cargo {
    string name;
    double weight;  // Вес груза
    double volume;  // Объем груза
    double density; // Плотность (объем / вес)
};

// Функция для сравнения грузов по плотности (для сортировки)
bool compareByDensity(const Cargo &a, const Cargo &b) {
    return a.density > b.density;
}

int main() {
    // Ограничения грузовика
    double maxWeight = 1000.0;  // Максимальная грузоподъемность (кг)
    double maxVolume = 10.0;    // Максимальный объем кузова (м³)

    // Список грузов
    vector<Cargo> cargoList = {
        {"Cargo A", 200.0, 2.0},
        {"Cargo B", 300.0, 3.0},
        {"Cargo C", 400.0, 4.0},
        {"Cargo D", 100.0, 1.0},
        {"Cargo E", 500.0, 5.0},
        {"Cargo F", 150.0, 2.5}
    };

    // Вычисляем плотность для каждого груза
    for (auto &cargo : cargoList) {
        cargo.density = cargo.volume / cargo.weight;
    }

    // Сортируем грузы по плотности (в порядке убывания)
    sort(cargoList.begin(), cargoList.end(), compareByDensity);

    // Переменные для отслеживания текущей загрузки
    double currentWeight = 0.0;
    double currentVolume = 0.0;
    vector<Cargo> loadedCargo;

    // Жадный алгоритм: выбираем грузы с наибольшей плотностью
    for (const auto &cargo : cargoList) {
        if (currentWeight + cargo.weight <= maxWeight && currentVolume + cargo.volume <= maxVolume) {
            loadedCargo.push_back(cargo);
            currentWeight += cargo.weight;
            currentVolume += cargo.volume;
        }
    }

    // Вывод результата
    cout << "Загруженные грузы:" << endl;
    for (const auto &cargo : loadedCargo) {
        cout << "Груз: " << cargo.name 
                  << ", Вес: " << cargo.weight 
                  << " кг, Объем: " << cargo.volume 
                  << " м³" << endl;
    }
    cout << "Итоговый вес: " << currentWeight << " кг" << endl;
    cout << "Итоговый объем: " << currentVolume << " м³" << endl;

    return 0;
}