#include "Array.h"
#include <iostream>
#include <string>

using namespace std;

bool matchPattern(const string& sequence, const string& pattern, int seqIndex, int patIndex) {
    // Если оба индекса вышли за пределы строк, значит совпадение найдено
    if (seqIndex == sequence.length() && patIndex == pattern.length()) {
        return true;
    }

    // Если индекс шаблона вышел за пределы, а индекс последовательности нет, значит совпадение не найдено
    if (patIndex == pattern.length()) {
        return false;
    }

    // Если текущий символ шаблона - "*", то проверяем все возможные варианты
    if (pattern[patIndex] == '*') {
        // Пропускаем "*" и проверяем все возможные варианты для последовательности
        for (int i = seqIndex; i <= sequence.length(); ++i) {
            if (matchPattern(sequence, pattern, i, patIndex + 1)) {
                return true;
            }
        }
        return false;
    }

    // Если текущий символ шаблона - "?", то он соответствует любому одному символу
    if (pattern[patIndex] == '?' || pattern[patIndex] == sequence[seqIndex]) {
        return matchPattern(sequence, pattern, seqIndex + 1, patIndex + 1);
    }

    // Если символы не совпадают и не являются "?" или "*", значит совпадение не найдено
    return false;
}

bool matchesPattern(const string& sequence, const string& pattern) {
    return matchPattern(sequence, pattern, 0, 0);
}

int main() {
    string sequence, pattern;

    cout << "Введите последовательность: ";
    getline(cin, sequence);

    cout << "Введите шаблон: ";
    getline(cin, pattern);

    if (matchesPattern(sequence, pattern)) {
        cout << "'" << sequence << "' соответствует шаблону '" << pattern << "'" << endl;
    } else {
        cout << "'" << sequence << "' не соответствует шаблону '" << pattern << "'" << endl;
    }

    return 0;
}