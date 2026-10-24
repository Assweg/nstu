#include "HashTable.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <stdexcept>

using namespace std;

// Функция для парсинга аргументов командной строки
void parseArgs(int argc, char* argv[], string& filename, string& query) {
    if (argc != 5) {
        throw runtime_error("Неверное количество аргументов.");
    }

    for (int i = 1; i < argc; ++i) {
        string arg = argv[i];
        if (arg == "--file") {
            filename = argv[++i];
        } else if (arg == "--query") {
            query = argv[++i];
        } else {
            throw runtime_error("Неизвестный аргумент: " + arg);
        }
    }
}

// Функция для выполнения запроса
void executeQuery(HashTable& set, const string& query) {
    istringstream iss(query);
    string command, key;
    iss >> command >> key;

    if (command == "SETADD") {
        set.Hinsert(key, ""); // Добавляем элемент в множество
        cout << "Элемент '" << key << "' добавлен в множество." << endl;
    } else if (command == "SETDEL") {
        if (set.Hdel(key)) {
            cout << "Элемент '" << key << "' удален из множества." << endl;
        } else {
            cout << "Элемент '" << key << "' не найден в множестве." << endl;
        }
    } else if (command == "SET_AT") {
        string value;
        if (set.Hget(key, value)) {
            cout << "Элемент '" << key << "' присутствует в множестве." << endl;
        } else {
            cout << "Элемент '" << key << "' отсутствует в множестве." << endl;
        }
    } else {
        throw runtime_error("Неизвестная команда: " + command);
    }
}

int main(int argc, char* argv[]) {
    try {
        string filename, query;
        parseArgs(argc, argv, filename, query);

        HashTable set;
        set.HreadFromFile(filename); // Загружаем множество из файла

        executeQuery(set, query); // Выполняем запрос

        set.HwriteToFile(filename); // Сохраняем множество в файл
    } catch (const exception& e) {
        cerr << "Ошибка: " << e.what() << endl;
        return 1;
    }

    return 0;
}