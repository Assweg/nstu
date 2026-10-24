#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

// Структура для представления товара
struct Product {
    int size;           // Размер товара
    int cost;           // Стоимость хранения товара
    double priority;    // Приоритет размещения товара (cost / size)

    // Конструктор для инициализации полей структуры
    Product(int s, int c) : size(s), cost(c) {
        priority = static_cast<double>(cost) / size;
    }
};

// Функция для сравнения товаров по приоритету (для сортировки)
bool comparePriority(const Product &a, const Product &b) {
    return a.priority > b.priority; // Товары с более высоким приоритетом идут первыми
}

// Функция для оптимизации размещения товаров в заданной вместимости
void optimizePlacement(vector<Product> &products, int capacity) {
    // Сортируем товары по убыванию приоритета
    sort(products.begin(), products.end(), comparePriority);

    int remainingCapacity = capacity;   // Оставшаяся вместимость склада
    double totalCost = 0.0;             // Общая стоимость размещенных товаров

    // Проходим по каждому товару
    for (const auto &product : products) {
        if (remainingCapacity >= product.size) {     // Если есть достаточно места для текущего товара
            remainingCapacity -= product.size;       // Уменьшаем оставшуюся вместимость
            totalCost += product.cost;               // Добавляем стоимость товара к общей сумме
            cout << "Размещен товар с размером " << product.size 
                 << " и стоимостью " << product.cost 
                 << ". Осталось места: " << remainingCapacity << endl;
        } else {
            cout << "Недостаточно места для товара с размером " << product.size 
                 << " и стоимостью " << product.cost << endl;
        }
    }
    cout << "Общие затраты на хранение: " << totalCost << endl;
}

int main() {
    // Создаем вектор товаров (размер, стоимость)
    vector<Product> products = {
        {2, 10},
        {3, 5},
        {4, 8},
        {5, 1},
        {4, 2}, 
        {10, 3}
    };

    int capacity = 14; // Вместимость склада

    // Функция оптимизации размещения товаров
    optimizePlacement(products, capacity);

    return 0;
}