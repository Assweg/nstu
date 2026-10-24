#include <iostream>
#include <vector>
#include <unordered_map>
#include <algorithm>

using namespace std;

// Группировка чисел по остаткам
void groupAndPair(const vector<int>& arr, int m) {    
    unordered_map<int, vector<int>> remainderGroups;

    for (int num : arr) {
        int remainder = num % m;
        remainderGroups[remainder].push_back(num);
    }

    // Создание пар
    vector<pair<int, int>> pairs;
    vector<int> leftovers;

    for (auto& [remainder, group] : remainderGroups) {
        // Cортируем группу для удобства вывода
        sort(group.begin(), group.end());

        // Создаем пары
        for (size_t i = 0; i + 1 < group.size(); i += 2) {
            pairs.emplace_back(group[i], group[i + 1]);
        }

        // Добавляем оставшиеся элементы
        if (group.size() % 2 != 0) {
            leftovers.push_back(group.back());
        }
    }

    cout << "Пары:\n";
    for (const auto& pair : pairs) {
        cout << "(" << pair.first << ", " << pair.second << ")\n";
    }

    cout << "\nОставшиеся без пары:\n";
    if (leftovers.empty()) {
        cout << "(пусто)\n";
    } else {
        for (int num : leftovers) {
            cout << num << " ";
        }
    }
    cout << endl;
}

int main() {
    vector<int> arr = {10, 11, 9, 2, 31, 21, 34, 40, 51};
    int m = 10;

    groupAndPair(arr, m);

    return 0;
}
