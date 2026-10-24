#include <iostream>
#include <vector>
#include <algorithm>
#include <climits>

using namespace std;

// Функция для вычисления общего расстояния маршрута
int calculateTotalDistance(const vector<int>& route, const vector<vector<int>>& distances) {
    int totalDistance = 0;
    for (size_t i = 0; i < route.size() - 1; ++i) {
        totalDistance += distances[route[i]][route[i + 1]];
    }
    // Возвращаемся на склад
    totalDistance += distances[route.back()][route[0]];
    return totalDistance;
}

// Функция для поиска оптимального маршрута
vector<int> findOptimalRoute(const vector<vector<int>>& distances) {
    // Количество адресов (без склада)
    int n = distances.size() - 1;

    // Создаем вектор с индексами адресов (начинаем с 1, так как 0 — это склад)
    vector<int> addresses(n);
    for (int i = 0; i < n; ++i) {
        addresses[i] = i + 1;
    }

    // Оптимальный маршрут и минимальное расстояние
    vector<int> optimalRoute;
    int minDistance = INT_MAX;

    // Перебор всех возможных маршрутов
    do {
        // Добавляем склад в начало и конец маршрута
        vector<int> currentRoute = {0}; // 0 — это склад
        currentRoute.insert(currentRoute.end(), addresses.begin(), addresses.end());

        // Вычисляем расстояние для текущего маршрута
        int currentDistance = calculateTotalDistance(currentRoute, distances);

        // Если текущий маршрут лучше, обновляем оптимальный
        if (currentDistance < minDistance) {
            minDistance = currentDistance;
            optimalRoute = currentRoute;
        }
    } while (next_permutation(addresses.begin(), addresses.end())); // Перебор всех возможных перестановок

    return optimalRoute;
}

int main() {
    // Матрица расстояний (0 — склад, 1, 2, 3 — адреса доставки)
    vector<vector<int>> distances = {
        {0, 10, 15, 20}, // Расстояния от склада
        {10, 0, 35, 25}, // Расстояния от адреса 1
        {15, 35, 0, 30}, // Расстояния от адреса 2
        {20, 25, 30, 0}  // Расстояния от адреса 3
    };

    // Находим оптимальный маршрут
    vector<int> optimalRoute = findOptimalRoute(distances);

    cout << "Оптимальный маршрут: ";
    for (int address : optimalRoute) {
        cout << address << " ";
    }
    cout << "0";
    cout << endl;

    cout << "Минимальное расстояние: " << calculateTotalDistance(optimalRoute, distances) << endl;

    return 0;
}