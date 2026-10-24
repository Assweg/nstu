#ifndef EXPRESSION_EVALUATOR_H
#define EXPRESSION_EVALUATOR_H

#include "Stack.h"
#include <string>
#include <stdexcept>
#include <cctype>

using namespace std;

class ExpressionEvaluator {
public:
    // Метод для вычисления логического выражения
    static bool evaluate(const string& expression);

private:
    // Метод для определения приоритета операций
    static int precedence(char op);
    
    // Метод для применения логической операции
    static bool applyOperation(char op, bool a, bool b);
};

// Метод для вычисления логического выражения
bool ExpressionEvaluator::evaluate(const string& expression) {
    Stack<bool> operandStack(expression.length());      // Стек для операндов
    Stack<char> operatorStack(expression.length());     // Стек для операторов

    for (size_t i = 0; i < expression.length(); ++i) {
        char ch = expression[i];

        if (ch == ' ') continue; // Пропускаем пробелы

        if (ch == '0' || ch == '1') {
            // Если символ - операнд (0 или 1), добавляем его в стек операндов
            operandStack.Spush(ch == '1');
        } else if (ch == '(') {
            // Если символ - открывающая скобка, добавляем её в стек операторов
            operatorStack.Spush(ch);
        } else if (ch == ')') {
            // Если символ - закрывающая скобка, выполняем операции до открывающей скобки
            while (!operatorStack.SisEmpty() && operatorStack.Speek() != '(') {
                char op = operatorStack.Speek();
                operatorStack.Spop();

                if (op == '!') {
                    // Если оператор - отрицание, применяем его к верхнему операнду
                    bool a = operandStack.Speek(); // Получаем верхний элемент стека операндов (без удаления)
                    operandStack.Spop(); // Удаляем верхний элемент стека операндов
                    operandStack.Spush(!a); // Применяем операцию отрицания (!a) и помещаем результат обратно в стек
                } else {
                    // Иначе, применяем бинарную операцию к двум верхним операндам
                    bool b = operandStack.Speek();
                    operandStack.Spop();
                    bool a = operandStack.Speek();
                    operandStack.Spop();

                    operandStack.Spush(applyOperation(op, a, b));
                }
            }
            if (!operatorStack.SisEmpty() && operatorStack.Speek() == '(') {
                operatorStack.Spop(); // Удаляем открывающую скобку
            } else {
                throw runtime_error("Несогласованные скобки.");
            }
        } else if (ch == '!' || ch == '&' || ch == '|' || ch == '^') {
            // Если символ - оператор, выполняем операции с более высоким приоритетом
            while (!operatorStack.SisEmpty() && precedence(operatorStack.Speek()) >= precedence(ch)) {
                char op = operatorStack.Speek();
                operatorStack.Spop();

                if (op == '!') {
                    // Если оператор - отрицание, применяем его к верхнему операнду
                    bool a = operandStack.Speek();
                    operandStack.Spop();
                    operandStack.Spush(!a);
                } else {
                    // Иначе, применяем бинарную операцию к двум верхним операндам
                    bool b = operandStack.Speek();
                    operandStack.Spop();
                    bool a = operandStack.Speek();
                    operandStack.Spop();

                    operandStack.Spush(applyOperation(op, a, b));
                }
            }
            operatorStack.Spush(ch); // Добавляем текущий оператор в стек
        } else {
            throw runtime_error("Недопустимый символ в выражении.");
        }
    }

    // Выполняем оставшиеся операции в стеке операторов
    while (!operatorStack.SisEmpty()) {
        char op = operatorStack.Speek();
        operatorStack.Spop();

        if (op == '!') {
            // Если оператор - отрицание, применяем его к верхнему операнду
            bool a = operandStack.Speek();
            operandStack.Spop();
            operandStack.Spush(!a);
        } else {
            // Иначе, применяем бинарную операцию к двум верхним операндам
            bool b = operandStack.Speek();
            operandStack.Spop();
            bool a = operandStack.Speek();
            operandStack.Spop();

            operandStack.Spush(applyOperation(op, a, b));
        }
    }

    if (operandStack.SisEmpty()) {
        throw runtime_error("Ошибка в выражении.");
    }

    return operandStack.Speek(); // Возвращаем результат вычисления
}

// Метод для определения приоритета операций
int ExpressionEvaluator::precedence(char op) {
    if (op == '!') return 3; // Отрицание имеет наивысший приоритет
    if (op == '&') return 2; // Логическое И имеет средний приоритет
    if (op == '|' || op == '^') return 1; // Логическое ИЛИ и XOR имеют низкий приоритет
    return 0; // Для других символов приоритет 0
}

// Метод для применения логической операции
bool ExpressionEvaluator::applyOperation(char op, bool a, bool b) {
    switch (op) {
        case '&': return a && b; // Логическое И
        case '|': return a || b; // Логическое ИЛИ
        case '^': return a != b; // XOR (исключающее ИЛИ)
        default: throw runtime_error("Неизвестная операция.");
    }
}

#endif