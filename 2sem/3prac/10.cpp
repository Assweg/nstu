#include <iostream>
#include <vector>
#include <algorithm>
#include <queue>

using namespace std;

// Структура для хранения информации о пассажире
struct Passenger {
    int id;          // Уникальный id пассажира
    int row;         // Номер ряда
    int seat;        // Номер места
};

// Функция для сравнения пассажиров по ряду
bool compareByRow(const Passenger &a, const Passenger &b) {
    return a.row > b.row; // Сначала сажаем пассажиров с задних рядов
}

int main() {
    // Список пассажиров (id пассажира, ряд, место)
    vector<Passenger> passengers = {
        {1, 10, 1},  
        {2, 5, 2},  
        {3, 15, 3},  
        {4, 1, 4}, 
        {5, 20, 5},  
        {6, 8, 6},   
        {7, 12, 7},
        {8, 3, 8},   
        {9, 18, 9}, 
        {10, 7, 10},  
        {11, 7, 11},
        {12, 7, 12}  
    };

    // Сортируем пассажиров по рядам (сначала задние ряды)
    sort(passengers.begin(), passengers.end(), compareByRow);

    cout << "Порядок посадки пассажиров:" << endl;
    for (const auto &passenger : passengers) {
        cout << "Пассажир " << passenger.id 
                  << " (Ряд " << passenger.row 
                  << ", Место " << passenger.seat << ")" << endl;
    }

    return 0;
}