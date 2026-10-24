#ifndef BINARYSEARCHTREE_H
#define BINARYSEARCHTREE_H

#include <iostream>
#include <fstream>
#include <string>
#include <iomanip>

using namespace std;

template <typename T>
class BinarySearchTree {
private:
    // структура Node, представляющая узел дерева
    struct Node {
        T data;         // Данные, хранящиеся в узле
        Node* left;     // Указатель на левого потомка
        Node* right;    // Указатель на правого потомка

        // Конструктор узла, инициализирующий данные и указатели на потомков
        Node(const T& value) : data(value), left(nullptr), right(nullptr) {}
    };

    Node* root;  // Указатель на узел дерева

    void insert(Node*& node, const T& value);
    bool search(Node* node, const T& value) const;
    void printTree(Node* node, int indent) const;
    void readFromFile(Node*& node, ifstream& file);
    void writeToFile(Node* node, ofstream& file) const;
    void remove(Node*& node, const T& value);
    void clear(Node* node);

public:
    // Конструктор и деструктор
    BinarySearchTree();
    ~BinarySearchTree();

    // Публичные методы для выполнения операций над деревом
    void Tinsert(const T& value);
    bool Tsearch(const T& value) const;
    void Tprint() const;
    void TreadFromFile(const string& filename);
    void TwriteToFile(const string& filename) const;
    void Tremove(const T& value);
};

// Конструктор класса, инициализирующий корень дерева как nullptr
template <typename T>
BinarySearchTree<T>::BinarySearchTree() : root(nullptr) {}

// Деструктор класса, освобождающий память, занятую узлами дерева
template <typename T>
BinarySearchTree<T>::~BinarySearchTree() {
    clear(root);
}

// // Рекурсивная функция для очистки дерева
// template <typename T>
// void BinarySearchTree<T>::clear(Node* node) {
//     if (node) {
//         clear(node->left);   // Рекурсивно очищаем левое поддерево
//         clear(node->right);  // Рекурсивно очищаем правое поддерево
//         delete node;         // Удаляем текущий узел
//     }
// }

// Метод для вставки элемента в дерево
template <typename T>
void BinarySearchTree<T>::Tinsert(const T& value) {
    insert(root, value);
}

// Рекурсивная функция для вставки элемента в дерево
template <typename T>
void BinarySearchTree<T>::insert(Node*& node, const T& value) {
    if (!node) {
        // Если узел пустой, создаем новый узел с данным значением
        node = new Node(value);
    } else if (value < node->data) {
        // Если значение меньше данных в узле, вставляем в левое поддерево
        insert(node->left, value);
    } else if (value > node->data) {
        // Если значение больше данных в узле, вставляем в правое поддерево
        insert(node->right, value);
    } else {
        // Если значение уже существует в дереве, выводим сообщение
        cout << "Значение " << value << " уже существует в дереве.\n";
    }
}

// Публичный метод для поиска элемента в дереве
template <typename T>
bool BinarySearchTree<T>::Tsearch(const T& value) const {
    return search(root, value);
}

// Рекурсивная функция для поиска элемента в дереве
template <typename T>
bool BinarySearchTree<T>::search(Node* node, const T& value) const {
    if (!node) {
        // Если узел пустой, элемент не найден
        return false;
    } else if (value == node->data) {
        // Если значение равно данным в узле, элемент найден
        return true;
    } else if (value < node->data) {
        // Если значение меньше данных в узле, ищем в левом поддереве
        return search(node->left, value);
    } else {
        // Если значение больше данных в узле, ищем в правом поддереве
        return search(node->right, value);
    }
}

// Публичный метод для вывода дерева
template <typename T>
void BinarySearchTree<T>::Tprint() const {
    if (!root) {
        // Если дерево пустое, выводим сообщение
        cout << "Дерево пустое.\n";
        return;
    }
    // Вызываем рекурсивную функцию для вывода дерева
    printTree(root, 0);
}

// Рекурсивная функция для вывода дерева
template <typename T>
void BinarySearchTree<T>::printTree(Node* node, int indent) const {
    if (node) {
        // Выводим правое поддерево с отступом
        if (node->right) {
            printTree(node->right, indent + 4);
        }
        // Выводим текущий узел с отступом
        if (indent) {
            cout << setw(indent) << ' ';
        }
        if (node->right) {
            cout << " /\n" << setw(indent) << ' ';
        }
        cout << node->data << "\n ";
        // Выводим левое поддерево с отступом
        if (node->left) {
            cout << setw(indent) << ' ' << " \\\n";
            printTree(node->left, indent + 4);
        }
    }
}

// Публичный метод для чтения дерева из файла
template <typename T>
void BinarySearchTree<T>::TreadFromFile(const string& filename) {
    ifstream file(filename);
    if (!file.is_open()) {
        // Если файл не открыт, выводим сообщение об ошибке
        cout << "Не удалось открыть файл для чтения!" << endl;
        return;
    }

    T value;
    // Читаем значения из файла и вставляем их в дерево
    while (file >> value) {
        Tinsert(value);
    }

    file.close();
}

// Публичный метод для записи дерева в файл
template <typename T>
void BinarySearchTree<T>::TwriteToFile(const string& filename) const {
    ofstream file(filename);
    if (!file.is_open()) {
        // Если файл не открыт, выводим сообщение об ошибке
        cout << "Не удалось открыть файл для записи!" << endl;
        return;
    }

    // Вызываем рекурсивную функцию для записи дерева в файл
    writeToFile(root, file);

    file.close();
}

// Рекурсивная функция для записи дерева в файл
template <typename T>
void BinarySearchTree<T>::writeToFile(Node* node, ofstream& file) const {
    if (node) {
        // Записываем левое поддерево
        writeToFile(node->left, file);
        // Записываем данные текущего узла
        file << node->data << "\n";
        // Записываем правое поддерево
        writeToFile(node->right, file);
    }
}

// метод для удаления элемента из дерева
template <typename T>
void BinarySearchTree<T>::Tremove(const T& value) {
    remove(root, value);
}

// Рекурсивная функция для удаления элемента из дерева
template <typename T>
void BinarySearchTree<T>::remove(Node*& node, const T& value) {
    if (!node) {
        // Если узел пустой, элемент не найден
        cout << "Значение " << value << " не найдено в дереве.\n";
        return;
    }

    if (value < node->data) {
        // Если значение меньше данных в узле, удаляем из левого поддерева
        remove(node->left, value);
    } else if (value > node->data) {
        // Если значение больше данных в узле, удаляем из правого поддерева
        remove(node->right, value);
    } else {
        // Если значение равно данным в узле, удаляем текущий узел
        if (!node->left && !node->right) {
            // Если узел является листом, просто удаляем его
            delete node;
            node = nullptr;
        } else if (!node->left) {
            // Если у узла есть только правый потомок, заменяем узел на правого потомка
            Node* temp = node;
            node = node->right;
            delete temp;
        } else if (!node->right) {
            // Если у узла есть только левый потомок, заменяем узел на левого потомка
            Node* temp = node;
            node = node->left;
            delete temp;
        } else {
            // Если у узла есть оба потомка, находим минимальный элемент в правом поддереве
            Node* minRight = node->right;
            while (minRight->left) {
                minRight = minRight->left;
            }
            // Заменяем данные в текущем узле на данные минимального элемента
            node->data = minRight->data;
            // Удаляем минимальный элемент из правого поддерева
            remove(node->right, minRight->data);
        }
    }
}

#endif // BINARYSEARCHTREE_H