#ifndef TRAM_H
#define TRAM_H

#include <iostream>
#include <vector>
#include <map>
#include <string>

using namespace std;

// Перечисление для хранения команд
enum class Command {
    CREATE_TRAM,      // Создать трамвай
    TRAMS_IN_STOP,    // Получить трамваи, проходящие через остановку
    STOPS_IN_TRAM,    // Получить остановки для конкретного трамвая
    TRAMS             // Отобразить все трамваи
};

void createTram(const std::string& tramName, const std::vector<std::string>& stops);    // Создать трамвай
void tramsInStop(const std::string& stop);  // Получить трамваи, проходящие через остановку
void stopsInTram(const std::string& tramName);  // Получить остановки для конкретного трамвая
void displayAllTrams(); // Отобразить все трамваи

#endif