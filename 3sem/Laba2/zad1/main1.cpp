#include "Z1.h"
#include <iostream>
#include <string>

using namespace std;

int main() {
    string expression;

    while (true) {
        cout << "Введите логическое выражение: ";
        getline(cin, expression);

        if (expression == "exit") {
            cout << "Завершение программы..." << endl;
            break;
        }

        try {
            bool result = ExpressionEvaluator::evaluate(expression);
            cout << "Результат: " << (result ? "1" : "0") << endl;
        } catch (const runtime_error& e) {
            cerr << "Ошибка: " << e.what() << endl;
        }
    }

    return 0;
}