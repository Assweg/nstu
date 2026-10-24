#include <iostream>
#include <vector>
#include <map>
#include <algorithm>

using namespace std;

// Структура для хранения информации о пользователе
struct User {
    string name;
    int friendsCount;          // Количество друзей
    int likesReceived;         // Количество полученных лайков
    int commentsReceived;      // Количество полученных комментариев
    double influenceScore;     // Общий показатель влиятельности
};

// Функция для сравнения пользователей по влиятельности (для сортировки)
bool compareByInfluence(const User &a, const User &b) {
    return a.influenceScore < b.influenceScore;
}

int main() {
    // Список пользователей
    vector<User> users = {
        {"Alice", 100, 500, 200, 0.0},
        {"Bob", 150, 300, 100, 0.0},
        {"Charlie", 200, 400, 300, 0.0},
        {"David", 50, 100, 50, 0.0},
        {"Eve", 300, 600, 400, 0.0}
    };

    // Вычисляем показатель влиятельности для каждого пользователя
    for (auto &user : users) {
        // Влиятельность = (друзья * 0.4) + (лайки * 0.3) + (комментарии * 0.3)
        user.influenceScore = (user.friendsCount * 0.4) + 
                              (user.likesReceived * 0.2) + 
                              (user.commentsReceived * 0.3);
    }

    // Сортируем пользователей по влиятельности (в порядке убывания)
    // sort(users.begin(), users.end(), compareByInfluence);

    auto compare = max_element(users.begin(), users.end(), compareByInfluence);

    cout << "Самый влиятельный пользователь:" << endl;
    cout << compare->name << ", Влиятельность: " << compare->influenceScore << endl;

    // // Выводим самого влиятельного пользователя
    // int topN = 1;
    // cout << "Cамый влиятельный пользователь:" << endl;
    // for (int i = 0; i < topN && i < users.size(); ++i) {
    //     cout << i + 1 << ". " << users[i].name 
    //               << " (Влиятельность: " << users[i].influenceScore << ")" << endl;
    // }

    return 0;
}