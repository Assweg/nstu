#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>
#include <limits>

using namespace std;

// Структура для представления остановки
struct Stop {
    int id;                  // Уникальный id остановки
    int passengerCount;      // Количество пассажиров на остановке
    int arrivalTime;         // Время прибытия первого пассажира
};

// Структура для представления автобуса
struct Bus {
    int id;                  // Уникальный id автобуса
    int capacity;            // Вместимость автобуса
    int currentPassengers;   // Текущее количество пассажиров
    vector<int> route;       // Маршрут автобуса (список остановок)
};

// Функция для планирования маршрутов автобусов
void planBusRoutes(const vector<Stop>& stops, int busCapacity, int maxWaitTime) {
    vector<Bus> buses;       // Список автобусов
    vector<bool> visited(stops.size(), false); // Пометка посещенных остановок

    // Сортируем остановки по времени прибытия пассажиров
    vector<Stop> sortedStops = stops;
    sort(sortedStops.begin(), sortedStops.end(), [](const Stop& a, const Stop& b) {
        return a.arrivalTime < b.arrivalTime;
    });

    // Распределяем пассажиров по автобусам
    for (size_t i = 0; i < sortedStops.size(); ++i) {
        if (visited[i]) continue;

        // Создаем новый автобус
        Bus bus;
        bus.id = buses.size() + 1;
        bus.capacity = busCapacity;
        bus.currentPassengers = 0;

        // Добавляем остановки в маршрут автобуса
        for (size_t j = i; j < sortedStops.size(); ++j) {
            const Stop& stop = sortedStops[j];

            // Проверяем, можно ли добавить остановку в маршрут
            if (bus.currentPassengers + stop.passengerCount <= bus.capacity &&
                stop.arrivalTime - sortedStops[i].arrivalTime <= maxWaitTime) {
                bus.route.push_back(stop.id);
                bus.currentPassengers += stop.passengerCount;
                visited[j] = true;
            } else {
                break; // Переходим к следующему автобусу
            }
        }

        // Добавляем автобус в список
        buses.push_back(bus);
    }

    // Вывод результата
    cout << "Спланированные маршруты автобусов:" << endl;
    for (const auto& bus : buses) {
        cout << "Автобус " << bus.id << ": ";
        for (int stopId : bus.route) {
            cout << "Остановка " << stopId << " ";
        }
        cout << "(Пассажиров: " << bus.currentPassengers << ")" << endl;
    }
}

int main() {
    // Пример данных (остановка, пассажиры, время прибытия)
    vector<Stop> stops = {
        {1, 10, 0},    
        {5, 7, 20},    
        {3, 8, 10},   
        {4, 12, 15},  
        {2, 5, 5}
    };

    int busCapacity = 20;     // Вместимость автобуса
    int maxWaitTime = 10;     // Максимальное время ожидания

    // Планирование маршрутов
    planBusRoutes(stops, busCapacity, maxWaitTime);

    return 0;
}
