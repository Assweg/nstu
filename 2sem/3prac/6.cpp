#include <iostream>
#include <vector>
#include <cmath>
#include <algorithm>

using namespace std;

// Структура для хранения информации о кафе
struct Cafe {
    string name;
    double latitude;
    double longitude;
};

// Функция для расчета расстояния между двумя точками
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return sqrt(pow(lat2 - lat1, 2) + pow(lon2 - lon1, 2));
}

int main() {
    // Ваше текущее местоположение
    double myLatitude = 55.7558;
    double myLongitude = 37.6173;

    // Список кафе с их координатами
    vector<Cafe> cafes = {
        {"Cafe A", 55.7600, 37.6200},
        {"Cafe B", 55.7500, 37.6100},
        {"Cafe C", 55.7700, 37.6300},
        {"Cafe D", 55.7450, 37.6150}
    };

    // Итератор для хранения ближайшего кафе
    auto nearestCafe = cafes.begin();

    // Начальное минимальное расстояние
    double minDistance = calculateDistance(myLatitude, myLongitude, nearestCafe->latitude, nearestCafe->longitude);

    // Поиск ближайшего кафе
    for (auto it = cafes.begin(); it != cafes.end(); ++it) {
        double distance = calculateDistance(myLatitude, myLongitude, it->latitude, it->longitude);
        if (distance < minDistance) {
            minDistance = distance;
            nearestCafe = it;
        }
    }

    cout << "Ближайшее кафе: " << nearestCafe->name << endl;
    cout << "Расстояние: " << minDistance << endl;

    return 0;
}