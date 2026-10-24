#include "HashTable.h"

bool areIsomorphic(const string &str1, const string &str2) {
    // Если длины строк не совпадают, они не могут быть изоморфными
    if (str1.length() != str2.length()) {
        return false;
    }

    HashTable mapping1, mapping2;

    // Проходим по всем символам строк
    for (size_t i = 0; i < str1.length(); ++i) {
        char char1 = str1[i]; // Текущий символ из str1
        char char2 = str2[i]; // Текущий символ из str2

        string value;

        // Проверяем, есть ли уже сопоставление для char1 в mapping1
        if (mapping1.Hget(string(1, char1), value)) {
            // Если символ из str1 уже сопоставлен, проверяем, совпадает ли сопоставление
            if (value != string(1, char2)) {
                // Если сопоставление не совпадает, строки не изоморфны
                return false;
            }
        } else {
            // Если символ из str1 еще не сопоставлен, добавляем сопоставление
            mapping1.Hinsert(string(1, char1), string(1, char2));
        }

        // Проверяем, есть ли уже сопоставление для char2 в mapping2
        if (mapping2.Hget(string(1, char2), value)) {
            // Если символ из str2 уже сопоставлен, проверяем, совпадает ли сопоставление
            if (value != string(1, char1)) {
                // Если сопоставление не совпадает, строки не изоморфны
                return false;
            }
        } else {
            // Если символ из str2 еще не сопоставлен, добавляем сопоставление
            mapping2.Hinsert(string(1, char2), string(1, char1));
        }
    }

    // Если все проверки пройдены, строки изоморфны
    return true;
}

int main() {
    string str1, str2;

    cout << "Введите первую строку: ";
    cin >> str1;
    cout << "Введите вторую строку: ";
    cin >> str2;

    if (areIsomorphic(str1, str2)) {
        cout << "Строки изоморфны." << endl;
    } else {
        cout << "Строки не изоморфны." << endl;
    }

    return 0;
}