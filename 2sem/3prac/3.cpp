#include <iostream>
#include <vector>
#include <map>
#include <set>
#include <algorithm>

using namespace std;

// Структура для представления мероприятия
struct Event {
    string name;          // Название мероприятия
    string type;          // Тип мероприятия
    string speaker;       // Имя спикера
    string preferredTime; // Предпочтительное время
};

// Структура для представления аудитории
struct Room {
    int id;              // Номер аудитории
    string type;         // Тип (большая или маленькая)
};

// Функция для создания расписания
void createSchedule(const vector<Event>& events, const vector<Room>& rooms, const vector<string>& timeSlots) {
    // Результирующее расписание: (timeSlot, roomId) -> eventName
    map<pair<string, int>, string> schedule;
    // Множество занятых аудиторий для каждого временного слота
    map<string, set<int>> busyRooms;

    // Итерация по всем мероприятиям
    for (const auto& event : events) {
        bool scheduled = false;

        // Попытка найти подходящую аудиторию и временной слот
        for (const auto& slot : timeSlots) {
            if (scheduled) break;

            // Проверяем, совпадает ли слот с предпочтительным временем спикера
            if (slot != event.preferredTime) continue;

            for (const auto& room : rooms) {
                // Проверяем, подходит ли аудитория для типа мероприятия
                if ((event.type == "лекция" && room.type == "большая") ||
                    (event.type != "лекция" && room.type == "маленькая")) {
                    // Проверяем, свободна ли аудитория в данный временной слот
                    if (busyRooms[slot].count(room.id) == 0) {
                        // Занятие успешно запланировано
                        schedule[{slot, room.id}] = event.name;
                        busyRooms[slot].insert(room.id);
                        scheduled = true;
                        break;
                    }
                }
            }
        }

        // Если мероприятие не удалось запланировать в предпочтительное время, пробуем другие слоты
        if (!scheduled) {
            for (const auto& slot : timeSlots) {
                if (scheduled) break;

                for (const auto& room : rooms) {
                    // Проверяем, подходит ли аудитория для типа мероприятия
                    if ((event.type == "лекция" && room.type == "большая") ||
                        (event.type != "лекция" && room.type == "маленькая")) {
                        // Проверяем, свободна ли аудитория в данный временной слот
                        if (busyRooms[slot].count(room.id) == 0) {
                            // Занятие успешно запланировано
                            schedule[{slot, room.id}] = event.name;
                            busyRooms[slot].insert(room.id);
                            scheduled = true;
                            break;
                        }
                    }
                }
            }
        }

        // Если мероприятие не удалось запланировать
        if (!scheduled) {
            cout << "Не удалось запланировать мероприятие: " << event.name << endl;
        }
    }

    // Вывод результата
    cout << "Расписание:" << endl;
    for (const auto& [slotRoom, eventName] : schedule) {
        string slot = slotRoom.first;
        int roomId = slotRoom.second;
        cout << "Слот: " << slot << ", Аудитория: " << roomId << ", Мероприятие: " << eventName << endl;
    }
}

int main() {
    // Пример данных
    vector<Event> events = {
        {"Лекция по физике", "лекция", "Иван", "утро"},
        {"Мастер-класс по программированию", "мастер-класс", "Мария", "день"},
        {"Интерактивное занятие по робототехнике", "интерактивное занятие", "Петр", "вечер"}
    };

    vector<Room> rooms = {
        {101, "большая"},
        {102, "маленькая"},
        {103, "маленькая"}
    };

    vector<string> timeSlots = {"утро", "день", "вечер"};

    // Создание расписания
    createSchedule(events, rooms, timeSlots);

    return 0;
}