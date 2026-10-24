#include <iostream>
#include <map>
#include <vector>
#include <sstream>

using namespace std;

// Структура для хранения информации о товаре
struct Item {
    string name;      // Название товара
    int quantity;     // Количество товара
};

// Класс для управления складом
class Warehouse {
private:
    // Структура склада: зона -> стеллаж -> полка -> ячейка
    map<string, vector<vector<vector<Item>>>> warehouse;
    int totalCapacity;    // Общая вместимость склада
    int usedCapacity;     // Используемая вместимость
    int maxItemQuantity;  // Максимальное количество товаров в одной ячейке

    void displayHelp() const {
        cout << "Доступные команды:" << endl;
        cout << "ADD <название товара> <количество> <адрес ячейки> - Добавить товар в указанную ячейку." << endl;
        cout << "REMOVE <название товара> <количество> <адрес ячейки> - Удалить товар из указанной ячейки." << endl;
        cout << "INFO - Показать информацию о складе." << endl;
        cout << "HELP - Показать эту справку." << endl;
        cout << "EXIT - Выйти из программы." << endl;
    }

public:
    // Конструктор склада
    Warehouse(int zones, int racks, int shelves, int cells, int totalCapacity, int maxItemQuantity) {
        this->totalCapacity = totalCapacity;
        this->maxItemQuantity = maxItemQuantity;
        usedCapacity = 0;

        // Инициализация склада: создание зон, стеллажей, полок и ячеек
        for (char zone = 'A'; zone < 'A' + zones; ++zone) {
            vector<vector<vector<Item>>> rackVec;
            for (int rack = 0; rack < racks; ++rack) {
                vector<vector<Item>> shelfVec;
                for (int shelf = 0; shelf < shelves; ++shelf) {
                    vector<Item> cellVec;
                    for (int cell = 0; cell < cells; ++cell) {
                        cellVec.push_back({"", 0});  // Инициализация пустой ячейки
                    }
                    shelfVec.push_back(cellVec);
                }
                rackVec.push_back(shelfVec);
            }
            warehouse[string(1, zone)] = rackVec;
        }
    }

    // Метод для добавления товара в ячейку
    void addItem(string name, int quantity, string address) {
        char zone = address[0];
        int rack, shelf, cell;

        // Проверка корректности адреса
        if (address.length() != 4 || !isdigit(address[1]) || !isdigit(address[2]) || !isdigit(address[3])) {
            cout << "Некорректный адрес ячейки. Адрес должен быть в формате A111." << endl;
            return;
        }

        // Преобразование строки в индексы стеллажа, полки и ячейки
        try {
            rack = stoi(address.substr(1, 2)) - 1;
            shelf = stoi(address.substr(2, 1)) - 1;
            cell = stoi(address.substr(3, 1)) - 1;
        } catch (const invalid_argument& e) {
            cout << "Некорректный адрес ячейки. Адрес должен быть в формате A111." << endl;
            return;
        }

        // Проверка, что индексы находятся в пределах допустимых значений
        if (rack < 0 || rack >= warehouse[string(1, zone)].size() ||
            shelf < 0 || shelf >= warehouse[string(1, zone)][rack].size() ||
            cell < 0 || cell >= warehouse[string(1, zone)][rack][shelf].size()) {
            cout << "Некорректный адрес ячейки. Адрес выходит за пределы допустимых значений." << endl;
            return;
        }

        // Проверка, что ячейка пуста или содержит тот же товар
        Item& item = warehouse[string(1, zone)][rack][shelf][cell];
        if (!item.name.empty() && item.name != name) {
            cout << "Ячейка уже содержит другой товар. Удалите его или используйте другую ячейку." << endl;
            return;
        }

        // Проверка, что на складе и в ячейке достаточно места
        if (usedCapacity + quantity > totalCapacity ||
            item.quantity + quantity > maxItemQuantity) {
            cout << "Недостаточно места для добавления товара." << endl;
            return;
        }

        // Добавление товара в ячейку
        item.name = name;
        item.quantity += quantity;
        usedCapacity += quantity;
    }

    // Метод для удаления товара из ячейки
    void removeItem(string name, int quantity, string address) {
        char zone = address[0];
        int rack, shelf, cell;

        // Проверка корректности адреса
        if (address.length() != 4 || !isdigit(address[1]) || !isdigit(address[2]) || !isdigit(address[3])) {
            cout << "Некорректный адрес ячейки. Адрес должен быть в формате A111." << endl;
            return;
        }

        // Преобразование строки в индексы стеллажа, полки и ячейки
        try {
            rack = stoi(address.substr(1, 2)) - 1;
            shelf = stoi(address.substr(2, 1)) - 1;
            cell = stoi(address.substr(3, 1)) - 1;
        } catch (const invalid_argument& e) {
            cout << "Некорректный адрес ячейки. Адрес должен быть в формате A111." << endl;
            return;
        }

        // Проверка, что индексы находятся в пределах допустимых значений
        if (rack < 0 || rack >= warehouse[string(1, zone)].size() ||
            shelf < 0 || shelf >= warehouse[string(1, zone)][rack].size() ||
            cell < 0 || cell >= warehouse[string(1, zone)][rack][shelf].size()) {
            cout << "Некорректный адрес ячейки. Адрес выходит за пределы допустимых значений." << endl;
            return;
        }

        // Проверка, что ячейка содержит указанный товар и его достаточно
        Item& item = warehouse[string(1, zone)][rack][shelf][cell];
        if (item.name != name) {
            cout << "Ячейка не содержит указанный товар." << endl;
            return;
        }
        if (item.quantity < quantity) {
            cout << "Недостаточно товара в ячейке для удаления." << endl;
            return;
        }

        // Удаление товара из ячейки
        item.quantity -= quantity;
        usedCapacity -= quantity;

        // Если ячейка пуста, сбрасываем название товара
        if (item.quantity == 0) {
            item.name = "";
        }
    }

    // Метод для отображения информации о складе
    void info() {
        cout << "Использование склада: " << (usedCapacity * 100.0) / totalCapacity << "%" << endl;

        // Отображение использования по зонам
        for (auto& zone : warehouse) {
            int zoneUsedCapacity = 0;
            for (auto& rack : zone.second) {
                for (auto& shelf : rack) {
                    for (auto& cell : shelf) {
                        zoneUsedCapacity += cell.quantity;
                    }
                }
            }
            cout << "Использование зоны " << zone.first << ": " << (zoneUsedCapacity * 100.0) / totalCapacity << "%" << endl;
        }

        // Отображение содержимого всех ячеек
        for (auto& zone : warehouse) {
            for (int rack = 0; rack < zone.second.size(); ++rack) {
                for (int shelf = 0; shelf < zone.second[rack].size(); ++shelf) {
                    for (int cell = 0; cell < zone.second[rack][shelf].size(); ++cell) {
                        if (zone.second[rack][shelf][cell].quantity > 0) {
                            cout << zone.first << rack + 1 << shelf + 1 << cell + 1 << ": "
                                 << zone.second[rack][shelf][cell].name << " - "
                                 << zone.second[rack][shelf][cell].quantity << endl;
                        }
                    }
                }
            }
        }
    }

    // Метод для обработки команд
    void processCommand(const string& command) {
        istringstream iss(command);
        string action;
        iss >> action;

        if (action == "ADD") {
            string name;
            int quantity;
            string address;
            iss >> name >> quantity >> address;
            addItem(name, quantity, address);
        } else if (action == "REMOVE") {
            string name;
            int quantity;
            string address;
            iss >> name >> quantity >> address;
            removeItem(name, quantity, address);
        } else if (action == "INFO") {
            info();
        } else if (action == "HELP") {
            displayHelp();
        } else if (action == "EXIT") {
            exit(0);
        } else {
            cout << "Неизвестная команда. Введите HELP для получения списка команд." << endl;
        }
    }
};

int main() {
    // Создание склада с 3 зонами, 20 стеллажами, 5 полками и 2 ячейками на полке
    // Общая вместимость склада - 6000 единиц товара, максимальное количество товара в ячейке - 100
    Warehouse warehouse(3, 20, 5, 2, 6000, 100);

    string command;
    cout << "Введите команду (введите HELP для справки):" << endl;
    while (getline(cin, command)) {
        warehouse.processCommand(command);
        cout << "Введите команду (введите HELP для справки):" << endl;
    }

    return 0;
}