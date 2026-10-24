#include "Tram.h"
#include <sstream>

int main() {
    string line;
    while (getline(cin, line)) {
        istringstream iss(line); // Поток для разбора строки
        string command;
        iss >> command; // Извлечение команды из строки

        if (command == "CREATE_TRAM") { // Обработка команды CREATE_TRAM
            string tramName;
            int stopCount;
            iss >> tramName >> stopCount; // Извлечение имени трамвая и количества остановок

            // Проверка на минимальное количество остановок
            if (stopCount < 2) {
                cout << "Неверное количество остановок" << endl;
                continue;
            }

            vector<string> stops(stopCount);
            bool validInput = true;
            for (int i = 0; i < stopCount; ++i) {
                if (!(iss >> stops[i])) {
                    validInput = false;
                    break;
                }
            }

            if (!validInput) {
                continue; // Пропускаем команду при ошибке ввода
            }
            
            // Проверка на подряд идущие одинаковые остановки
            bool hasConsecutiveDuplicates = false;
            for (int i = 0; i < stopCount - 1; ++i) {
                if (stops[i] == stops[i + 1]) {
                    hasConsecutiveDuplicates = true;
                    break;
                }
            }

            if (hasConsecutiveDuplicates) {
                cout << "Неправильный ввод остановок" << endl;
            }

            else {
                createTram(tramName, stops); // Вызов функции для создания трамвая
            }

        } else if (command == "TRAMS_IN_STOP") { // Обработка команды TRAMS_IN_STOP
            string stop;
            iss >> stop; // Извлечение названия остановки
            tramsInStop(stop); // Вызов функции для получения трамваев
        } else if (command == "STOPS_IN_TRAM") { // Обработка команды STOPS_IN_TRAM
            string tramName;
            iss >> tramName; // Извлечение имени трамвая
            stopsInTram(tramName); // Вызов функции для получения остановок
        } else if (command == "TRAMS") { // Обработка команды TRAMS
            displayAllTrams(); // Вызов функции для отображения всех трамваев
        }
    }
    return 0;
}