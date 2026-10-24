#include <iostream>
#include <string>
#include <cctype> // Для isdigit

using namespace std;

// Объявляем рекурсивную функцию для вычисления выражения
int evaluateExpression(const string &s, int &index);

// Функция для начала вычисления
int calculate(const string &s) {
    int index = 0; // Индекс текущего символа в строке
    return evaluateExpression(s, index);
}

// Основная рекурсивная функция для вычисления выражения
int evaluateExpression(const string &s, int &index) {
    int sum = 0; // для хранения результата
    int sign = 1; // 1 для положительного, -1 для отрицательного

    while (index < s.length()) {
        // Получаем текущий символ из строки по индексу
        char current = s[index];

        // Если текущий символ - пробел, просто увеличиваем индекс
        if (isspace(current)) {
            index++;
        }
        // Если текущий символ - цифра, начинаем формировать число
        else if (isdigit(current)) {
            int num = 0; // для хранения текущего числа

            // Цикл для составления полного числа, если оно содержит несколько цифр
            while (index < s.length() && isdigit(s[index])) {
                // Умножаем текущее число на 10 (сдвигаем на одну позицию влево) и добавляем новую цифру
                num = num * 10 + (s[index] - '0');
                index++;
            }
            // После составления числа добавляем его к общей сумме с учетом знака
            sum += sign * num;
        }
        else if (current == '+') {
            sign = 1;
            index++;
        }
        
        else if (current == '-') {
            sign = -1;
            index++;
        }
        // Если текущий символ - открывающая скобка
        else if (current == '(') {
            index++;

            // Рекурсивно вычисляем выражение в скобках и добавляем его к сумме с учетом текущего знака
            sum += sign * evaluateExpression(s, index);
        }
        else if (current == ')') {
            index++;
            break;
        }
    }
// Возвращаем итоговую сумму всех вычислений
    return sum;
}
    int main() {
    string s = "2 - (3 + 4)"; // Пример входа
    int result = calculate(s); // Вычисляем результат
    cout << "Результат: " << result << endl;
    return 0;
}
