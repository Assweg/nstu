#include <iostream>
#include <vector>
#include <unistd.h>
#include <cstdlib>
#include <ctime>
using namespace std;

const int ROWS = 20; // Количество строк
const int COLS = 50; // Количество столбцов

// ANSI-цвета
const string RESET = "\033[0m";
const string RED = "\033[31m";
const string GREEN = "\033[32m";
const string BLUE = "\033[34m";

// Функция для вывода текущего состояния доски
void printBoard(const vector<vector<bool>>& board, int generation, int aliveCells) {
    cout << BLUE << "Generation: " << generation << ", Alive cells: " << aliveCells << RESET << endl;
    for (const auto& row : board) {
        for (bool cell : row) {
            cout << (cell ? GREEN + "#" + RESET : " "); // Живая клетка - зелёная '#', мёртвая - пробел
        }
        cout << '\n';
    }
}

// Функция для подсчёта количества соседей у клетки
int countNeighbors(const vector<vector<bool>>& board, int x, int y) {
    int count = 0;
    for (int i = -1; i <= 1; ++i) {
        for (int j = -1; j <= 1; ++j) {
            if (i == 0 && j == 0) continue; // Пропускаем саму клетку
            int nx = x + i, ny = y + j;
            if (nx >= 0 && nx < ROWS && ny >= 0 && ny < COLS && board[nx][ny]) {
                count++;
            }
        }
    }
    return count;
}

// Функция для обновления состояния доски
void updateBoard(vector<vector<bool>>& board) {
    vector<vector<bool>> newBoard(ROWS, vector<bool>(COLS, false));
    for (int i = 0; i < ROWS; ++i) {
        for (int j = 0; j < COLS; ++j) {
            int neighbors = countNeighbors(board, i, j);
            newBoard[i][j] = (board[i][j] ? (neighbors == 2 || neighbors == 3) : (neighbors == 3));
        }
    }
    board.swap(newBoard); // Обновляем доску
}

// Функция для настройки начального состояния "глайдера" (паровоза)
void setupGlider(vector<vector<bool>>& board) {
    board[5][5] = board[5][6] = board[5][7] = board[4][7] = board[3][6] = true;
}

// Функция для настройки случайного начального состояния
void setupRandom(vector<vector<bool>>& board, int density = 20) {
    srand(time(0)); // Инициализация генератора случайных чисел
    for (size_t i = 0; i < board.size(); ++i) {
        for (size_t j = 0; j < board[i].size(); ++j) {
            board[i][j] = (rand() % 100) < density; // Вероятность живой клетки = density%
        }
    }
}

int main() {
    vector<vector<bool>> board(ROWS, vector<bool>(COLS, false)); // Создание доски
    char choice;

    // Выбор начального состояния
    cout << "Enter 'g' for glider or 'r' for random: ";
    cin >> choice;

    if (choice == 'g') {
        setupGlider(board); // Установка глайдера
    } else {
        setupRandom(board, 20); // Установка случайного состояния
    }

    int generation = 0; // Счётчик поколений

    // Основной цикл анимации
    while (true) {
        system("clear"); // Очистка консоли (для Linux/MacOS)
        // Для Windows используйте system("cls");

        // Подсчёт живых клеток
        int aliveCells = 0;
        for (const auto& row : board) {
            for (bool cell : row) {
                if (cell) aliveCells++;
            }
        }

        // Вывод текущего состояния доски
        printBoard(board, generation, aliveCells);

        // Обновление состояния доски
        updateBoard(board);

        // Увеличение счётчика поколений
        generation++;

        // Пауза между поколениями
        usleep(200000); // 200 миллисекунд
    }

    return 0;
}