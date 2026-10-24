#include "Tram.h"

// Хранит трамваи и их остановки (ключ — имя трамвая, значение — список остановок)
map<string, vector<string>> trams;

// Хранит остановки и трамваи, которые через них проходят (ключ — название остановки, значение — список трамваев)
map<string, vector<string>> stops;

// Функция для создания трамвая
void createTram(const string& tramName, const vector<string>& stopsList) {
    trams[tramName] = stopsList; // Добавляем трамвай в список трамваев
    for (const auto& stop : stopsList) {
        stops[stop].push_back(tramName); // Для каждой остановки добавляем трамвай
    }
}

// Функция для получения трамваев, проходящих через конкретную остановку
void tramsInStop(const string& stop) {
    if (stops.find(stop) != stops.end()) { // Проверяем, существует ли остановка
        for (const auto& tram : stops[stop]) { // Выводим все трамваи, проходящие через остановку
            cout << tram << " ";
        }
        cout << endl;
    } else {
        cout << "Stops is absent" << endl;
    }
}

// Функция для получения остановок, которые проезжает конкретный трамвай
void stopsInTram(const string& tramName) {
    if (trams.find(tramName) != trams.end()) { // Проверяем, существует ли трамвай
        for (const auto& stop : trams[tramName]) { // Для каждой остановки трамвая
            cout << "Stop " << stop << ": ";
            for (const auto& tram : stops[stop]) { // Выводим все трамваи, проходящие через эту остановку (кроме текущего)
                if (tram != tramName) {
                    cout << tram << " ";
                }
            }
            cout << endl;
        }
    } else {
        cout << "Trams is absent" << endl;
    }
}

// Функция для отображения всех трамваев и их остановок
void displayAllTrams() {
    if (trams.empty()) { // Если список трамваев пуст
        cout << "Trams is absent" << endl;
    } else {
        for (const auto& tram : trams) { // Для каждого трамвая
            cout << "TRAM " << tram.first << ": ";
            for (const auto& stop : tram.second) { // Выводим все его остановки
                cout << stop << " ";
            }
            cout << endl;
        }
    }
}