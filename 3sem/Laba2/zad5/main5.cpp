#include "Tree.h"
#include <iostream>

using namespace std;

int main() {
    BinarySearchTree<int> bst;
    int choice, value;

    while (true) {
        cout << "\nВыберите операцию:\n";
        cout << "1. Вставить элемент\n";
        cout << "2. Найти элемент\n";
        cout << "3. Удалить элемент\n";
        cout << "4. Вывести дерево\n";
        cout << "5. Считать дерево из файла\n";
        cout << "6. Записать дерево в файл\n";
        cout << "7. Выход\n";
        cout << "Ваш выбор: "; 
        cin >> choice;

        switch (choice) {
            case 1:
                cout << "Введите значение для вставки: ";
                cin >> value;
                bst.Tinsert(value);
                break;
            case 2:
                cout << "Введите значение для поиска: ";
                cin >> value;
                if (bst.Tsearch(value)) {
                    cout << "Значение найдено в дереве.\n";
                } else {
                    cout << "Значение не найдено в дереве.\n";
                }
                break;
            case 3:
                cout << "Введите значение для удаления: ";
                cin >> value;
                bst.Tremove(value);
                break;
            case 4:
                bst.Tprint();
                break;
            case 5: {
                cout << "Введите имя файла для чтения: ";
                string readFilename;
                cin >> readFilename;
                bst.TreadFromFile(readFilename);
                break;
            }
            case 6: {
                cout << "Введите имя файла для записи: ";
                string writeFilename;
                cin >> writeFilename;
                bst.TwriteToFile(writeFilename);
                break;
            }
            case 7:
                return 0;
            default:
                cout << "Неверный выбор. Попробуйте снова.\n";
        }
    }

    return 0;
}