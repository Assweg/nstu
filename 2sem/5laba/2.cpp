#include <iostream>
#include <queue>
#include <vector>
#include <string>
#include <sstream>

using namespace std;

// Структура для хранения информации о посетителе
struct Patient {
    string ticket;  // Номер талона
    int duration;   // Время обслуживания
    // Перегрузка оператора < для приоритетной очереди
    bool operator<(const Patient& other) const {
        return duration > other.duration;
    }
};

int main() {
    int numWindows;
    cout << "Введите количество окон: ";
    cin >> numWindows;

    // Вектор приоритетных очередей для каждого окна
    vector<priority_queue<Patient>> windows(numWindows);
    // Общая приоритетная очередь для всех посетителей
    priority_queue<Patient> allPatients;
    int ticketNumber = 1;  // Начальный номер талона

    string command;
    while (cin >> command) {
        if (command == "ENQUEUE") {
            Patient patient;
            cin >> patient.duration;  // Ввод времени обслуживания
            // Генерация номера талона
            stringstream ss;
            ss << "T" << ticketNumber++;
            patient.ticket = ss.str();
            // Добавление посетителя в общую очередь
            allPatients.push(patient);
            cout << "Посетитель добавлен в очередь под номером талона: " << patient.ticket << endl;
        } else if (command == "DISTRIBUTE") {
            // Распределение посетителей по окнам
            // Первая группа - посетители с самым длинным временем обслуживания
            vector<Patient> slowGroup;
            // Заполнение первой группы посетителями с наибольшим временем обслуживания
            while (!allPatients.empty() && slowGroup.size() < numWindows) {
                slowGroup.push_back(allPatients.top());
                allPatients.pop();
            }

            // Распределение по окнам первой группы
            for (size_t i = 0; i < slowGroup.size(); ++i) {
                windows[i].push(slowGroup[i]);
            }

            // Распределение остальных посетителей по окнам
            while (!allPatients.empty()) {
                int fastestWindow = 0;  // Окно с наименьшим количеством посетителей
                // Поиск окна с наименьшим количеством посетителей
                for (int i = 1; i < numWindows; ++i) {
                    if (windows[i].size() < windows[fastestWindow].size()) {
                        fastestWindow = i;
                    }
                }
                // Добавление посетителя в окно с наименьшим количеством посетителей
                windows[fastestWindow].push(allPatients.top());
                allPatients.pop();
            }

            // Вывод распределения очереди посетителей на все окна
            for (int i = 0; i < numWindows; ++i) {
                cout << "Окно " << (i + 1) << ": ";
                // Вывод всех посетителей в текущем окне
                while (!windows[i].empty()) {
                    cout << windows[i].top().ticket << " (" << windows[i].top().duration << " минут) ";
                    windows[i].pop();
                }
                cout << endl;
            }
        } else if (command == "HELP") {
            cout << "Команды:" << endl;
            cout << "ENQUEUE <время обслуживания> - добавление посетителя в очередь" << endl;
            cout << "DISTRIBUTE - распределение очереди посетителей на все окна" << endl;
            cout << "HELP - вывод справки" << endl;
        } else {
            cout << "Неизвестная команда. Введите HELP для получения справки." << endl;
        }
    }

    return 0;
}