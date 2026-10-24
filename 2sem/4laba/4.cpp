#include <iostream>
#include <vector>
#include <random>
#include <algorithm>

using namespace std;

// Функция для генерации случайного числа в заданном диапазоне
int getRandomNumber(int min, int max) {
    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<> dis(min, max);
    return dis(gen);
}

// Алгоритм 1: Всегда сотрудничать
bool alwaysCooperate(int round_number, const vector<bool>& self_choices, const vector<bool>& enemy_choices) {
    return true;
}

// Алгоритм 2: Всегда предавать
bool alwaysDefect(int round_number, const vector<bool>& self_choices, const vector<bool>& enemy_choices) {
    return false;
}

// Алгоритм 3: Зеркальный Око за око
bool titForTat(int round_number, const vector<bool>& self_choices, const vector<bool>& enemy_choices) {
    if (round_number == 0) return true; // Первый раунд - сотрудничество
    return enemy_choices[round_number - 1]; // Повторяем последний ход противника
}

// Функция для запуска игры между двумя алгоритмами
void runGame(bool (*algorithm1)(int, const vector<bool>&, const vector<bool>&),
             bool (*algorithm2)(int, const vector<bool>&, const vector<bool>&),
             const string& name1, const string& name2) {
    int rounds = getRandomNumber(100, 200);
    vector<bool> choices1, choices2;
    int score1 = 0, score2 = 0;

    for (int round = 0; round < rounds; ++round) {
        bool choice1 = algorithm1(round, choices1, choices2);
        bool choice2 = algorithm2(round, choices2, choices1);

        choices1.push_back(choice1);
        choices2.push_back(choice2);

        if (choice1 && choice2) {
            score1 += 24;
            score2 += 24;
        } else if (choice1 && !choice2) {
            score2 += 20;
        } else if (!choice1 && choice2) {
            score1 += 20;
        } else {
            score1 += 4;
            score2 += 4;
        }
    }

    cout << "Игра между " << name1 << " и " << name2 << " завершена." << endl;
    cout << "Количество раундов: " << rounds << endl;
    cout << name1 << " набрал " << score1 << " очков." << endl;
    cout << name2 << " набрал " << score2 << " очков." << endl;
    cout << endl;
}

int main() {
    // Запуск игр между разными алгоритмами
    runGame(alwaysCooperate, alwaysDefect, "Always Cooperate", "Always Defect");
    runGame(alwaysCooperate, titForTat, "Always Cooperate", "Tit for Tat");
    runGame(alwaysDefect, titForTat, "Always Defect", "Tit for Tat");

    return 0;
}