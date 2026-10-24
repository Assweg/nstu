#include <iostream>
#include <vector>

using namespace std;

// Функция для получения первой цифры числа
int firstDigit(int number) {
    while (number >= 10) {
        number /= 10;
    }
    return number;
}

// Функция для получения последней цифры числа
int lastDigit(int number) {
    return number % 10;
}

// Рекурсивная функция для построения максимальной последовательности
void findMaxSequence(const vector<int>& nums, vector<int>& currentSequence, vector<bool>& used, vector<int>& maxSequence) {
    // Если текущая последовательность больше максимальной, обновляем максимальную
    if (currentSequence.size() > maxSequence.size()) {
        maxSequence = currentSequence;
    }

    // Перебираем все числа
    for (int i = 0; i < nums.size(); i++) {
        if (!used[i]) {
            // Если это первое число в последовательности или совпадают цифры
            if (currentSequence.empty() || lastDigit(currentSequence.back()) == firstDigit(nums[i])) {
                currentSequence.push_back(nums[i]); // Добавляем число в текущую последовательность
                used[i] = true; // Помечаем число как используемое

                // Рекурсивно вызываем для дальнейших чисел
                findMaxSequence(nums, currentSequence, used, maxSequence);

                // Возвращаемся назад
                currentSequence.pop_back(); // Убираем последнее число
                used[i] = false; // Сбрасываем пометку
            }
        }
    }
}

int main() {
    vector<int> nums = {12, 45, 34, 56, 65, 67}; // Пример входного массива
    vector<bool> used(nums.size(), false);
    vector<int> currentSequence;
    vector<int> maxSequence;

    findMaxSequence(nums, currentSequence, used, maxSequence); // Запускаем рекурсию

    // Выводим максимальную последовательность
    cout << "Максимальная последовательность: ";
    for (int num : maxSequence) {
        cout << num << " ";
    }
    cout << endl;
    return 0;
}