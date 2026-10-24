#include <iostream>
#include <unordered_map>
#include <unordered_set>
#include <string>
using namespace std;

class FriendshipSystem {
private:
    // Словарь, где ключ - имя пользователя, а значение - множество его друзей
    unordered_map<string, unordered_set<string>> friends;

public:
    // Функция для добавления дружбы между двумя пользователями
    void addFriendship(string i, string j) {
        // Добавляем имя друга пользователю i
        friends[i].insert(j);
        // Добавляем имя друга пользователю j
        friends[j].insert(i);
    }

    // Функция для подсчета количества друзей пользователя
    string countFriends(string i) {
        // Возвращаем количество друзей пользователя i в виде строки
        return to_string(friends[i].size());
    }

    // Функция для проверки, являются ли два пользователя друзьями
    bool areFriends(string i, string j) {
        // Проверяем, есть ли имя пользователя j в множестве друзей пользователя i
        // Если да, то возвращаем true, иначе false
        return friends[i].count(j) > 0;
    }
};

int main() {
    FriendshipSystem system;
    string command;
    string i, j;

    // while (cin >> command) {
    //     if (command == "FRIENDS") {
    //         cin >> i >> j;
    //         system.addFriendship(i, j);
    //         cout << "Вы подружили: " << i << " и " << j << endl;
    //     } else if (command == "COUNT") {
    //         cin >> i;
    //         cout << "Количество друзей " << i << ": " << system.countFriends(i) << endl;
    //     } else if (command == "QUESTION") {
    //         cin >> i >> j;
    //         cout << (system.areFriends(i, j) ? "YES, они дружат" : "NO, они не дружат") << endl;
    //     }
    // }

    while (cin >> command) {
        if (command == "FRIENDS") {
            cin >> i >> j;
            system.addFriendship(i, j);
        } else if (command == "COUNT") {
            cin >> i;
            cout << system.countFriends(i) << endl;
        } else if (command == "QUESTION") {
            cin >> i >> j;
            cout << (system.areFriends(i, j) ? "YES" : "NO") << endl;
        }
    }

    return 0;
}