#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <set>
#include <map>
#include <cmath>
#include <cstdint>
#include <random>
#include <iomanip>

using namespace std;

// Функция для генерации простых чисел с помощью решета Эратосфена
void resheto() {
    int n;
    cout << "Input amount of prime number "; // Запрос количества простых чисел
    cin >> n;
    if (n < 2) { // Если число меньше 2, простых чисел нет
        cout << "No prime numbers less than 2." << endl;
        return;
    }
    vector<int> prostchisla(n + 1, 1); // Создаем массив для отметки простых чисел
    for (int p = 2; p * p <= n; p++) { // Перебираем числа до sqrt(n)
        if (prostchisla[p] == 1) { // Если число простое
            for (int j = p * p; j <= n; j += p) // Отмечаем кратные числа как составные
                prostchisla[j] = 0;
        }
    }
    int linecount = 0; // Счетчик для форматирования вывода
    for (int p = 2; p <= n; p++) { // Выводим простые числа
        if (prostchisla[p] == 1) { // Если число простое
            if (linecount == 10) { // Если выведено 10 чисел в строке
                cout << "\n"; // Переходим на новую строку
                linecount = 0;
            }
            cout << setw(4) << p << " "; // Выводим число с выравниванием
            linecount += 1;
        }
    }
    cout << endl;
}

// Функция для возведения в степень по модулю
uint64_t mod(uint64_t number, uint64_t power, uint64_t n) {
    uint64_t res = 1; // Результат
    while (power) { // Пока степень больше нуля
        if (power % 2) res = (res * number) % n; // Если степень нечетная, умножаем результат
        number = (number * number) % n; // Возводим основание в квадрат
        power /= 2; // Уменьшаем степень вдвое
    }
    return res; // Возвращаем результат
}

// Функция для загрузки простых чисел из файла
void tableprost(vector<int>& pch) {
    ifstream file("numbers.txt"); // Открываем файл
    if (!file.is_open()) { // Если файл не открыт
        cerr << "Failed to open file numbers.txt" << endl; // Выводим ошибку
        return;
    }
    while (true) { // Читаем строки из файла
        string stroka;
        getline(file, stroka, ' '); // Читаем строку до пробела
        if (stroka == "@") break; // Если встретили символ '@', завершаем чтение
        pch.push_back(stoi(stroka)); // Преобразуем строку в число и добавляем в вектор
    }
}

// Тест Миллера-Рабина для проверки простоты числа
bool TestMillerasver(int t, int N, set<int> q, int& K) {
    int countT = 0, countF = 0; // Счетчики успешных и неудачных тестов
    random_device rd;
    mt19937 gen(rd()); // Генератор случайных чисел
    uniform_int_distribution<> dis(1, N - 1); // Распределение для выбора случайного числа
    for (int j = 0; j < 50; j++) { // Проводим 50 итераций теста
        vector<int> aj; // Массив случайных чисел
        for (int i = 0; i < t; i++) {
            aj.push_back(dis(gen)); // Генерируем случайные числа
        }
        int iscomposite = 0; // Флаг составного числа
        for (int aj1 : aj) { // Проверяем условия теста Миллера
            if (mod(aj1, N - 1, N) != 1) { // Если условие не выполнено
                iscomposite = 1; // Число составное
                break;
            }
        }
        if (iscomposite == 1) { // Если число составное
            countF++; // Увеличиваем счетчик неудач
            continue;
        }
        for (int aj1 : aj) { // Проверяем дополнительные условия
            for (int qi : q) {
                if (mod(aj1, (N - 1) / qi, N) != 1) { // Если условие не выполнено
                    iscomposite = 1; // Число составное
                    continue;
                }
            }
        }
        if (iscomposite == 0) countT++; // Если число прошло тест, увеличиваем счетчик успехов
        else countT++; // Иначе увеличиваем общий счетчик
    }
    if (countT > countF) return true; // Если больше успехов, число вероятно простое
    else {
        K++; // Увеличиваем счетчик неудач
        return false; // Число составное
    }
}

// Тест Поклингтона для проверки простоты числа
bool TestPoklingtona(int t, int N, set<int> q, int& K, vector<int> prostch) {
    int countT = 0, countF = 0; // Счетчики успешных и неудачных тестов
    random_device rd;
    mt19937 gen(rd()); // Генератор случайных чисел
    uniform_int_distribution<> dis(1, N - 1); // Распределение для выбора случайного числа
    for (int j = 0; j < 100; j++) { // Проводим 100 итераций теста
        vector<int> aj; // Массив случайных чисел
        for (int i = 0; i < t; i++) {
            aj.push_back(dis(gen)); // Генерируем случайные числа
        }
        int iscomposite = 0; // Флаг составного числа
        for (int aj1 : aj) { // Проверяем условия теста Поклингтона
            if (mod(aj1, N - 1, N) != 1) { // Если условие не выполнено
                iscomposite = 1; // Число составное
                break;
            }
        }
        if (iscomposite == 1) { // Если число составное
            countF++; // Увеличиваем счетчик неудач
            continue;
        }
        for (int aj1 : aj) { // Проверяем дополнительные условия
            for (int qj : q) {
                if (mod(aj1, (N - 1) / qj, N) == 1) { // Если условие не выполнено
                    iscomposite = 1; // Число составное
                    break;
                }
            }
            if (iscomposite == 1) break; // Прерываем цикл
        }
        if (iscomposite == 1) countF++; // Если число составное, увеличиваем счетчик неудач
        else countT++; // Иначе увеличиваем счетчик успехов
    }
    if (countT > countF) return true; // Если больше успехов, число вероятно простое
    K++; // Увеличиваем счетчик неудач
    return false; // Число составное
}

// Генерация простых чисел с использованием теста Миллера
void GenMillera(int size, vector<int> pch, vector<int>& pchM, vector<int>& KM) {
    set<int> similar; // Множество для исключения повторений
    int K = 0; // Счетчик неудач
    random_device rd;
    mt19937 gen(rd()); // Генератор случайных чисел
    for (int countcikl = 0; countcikl != 10;) { // Генерируем 10 чисел
        set<int> q; // Множество делителей
        for (int i = 0; i < 2; i++) {
            q.insert(pch[gen() % 93]); // Выбираем случайные делители
        }
        int m = 1;
        for (int chislo : q) m *= chislo; // Вычисляем произведение делителей
        int n = 2 * m + 1; // Формируем кандидата на простое число
        int n1 = n, countn1 = 0;
        while (n1 > 0) { // Подсчитываем количество цифр в числе
            countn1++;
            n1 /= 10;
        }
        if (similar.find(n) != similar.end()) continue; // Если число уже было, пропускаем
        if (countn1 != size) continue; // Если длина числа не соответствует требуемой, пропускаем
        if (TestMillerasver(1, n, q, K)) { // Проверяем простоту числа
            pchM.push_back(n); // Добавляем простое число в результат
            similar.insert(n); // Добавляем число в множество
            countcikl++; // Увеличиваем счетчик сгенерированных чисел
            KM.push_back(K); // Сохраняем счетчик неудач
            K = 0; // Сбрасываем счетчик
        }
    }
}

// Генерация простых чисел с использованием теста Поклингтона
void GenPoklingtona(int size, vector<int> pch, vector<int>& pchP, vector<int>& KP) {
    set<int> similar; // Множество для исключения повторений
    int K = 0; // Счетчик неудач
    random_device rd;
    mt19937 gen(rd()); // Генератор случайных чисел
    for (int countcikl = 0; countcikl != 10;) { // Генерируем 10 чисел
        set<int> q; // Множество делителей
        for (int i = 0; i < 2; i++) {
            q.insert(pch[gen() % 93]); // Выбираем случайные делители
        }
        int f = 1;
        for (int chislo : q) f *= chislo; // Вычисляем произведение делителей
        int r = gen() % ((3 * f) / 4); // Выбираем случайное число r
        if (r % 2 != 0) r += 1; // Делаем r четным
        int n = r * f + 1; // Формируем кандидата на простое число
        int n1 = n, countn1 = 0;
        while (n1 > 0) { // Подсчитываем количество цифр в числе
            countn1++;
            n1 /= 10;
        }
        if (similar.find(n) != similar.end()) continue; // Если число уже было, пропускаем
        if (countn1 != size) continue; // Если длина числа не соответствует требуемой, пропускаем
        if (TestPoklingtona(1, n, q, K, pch)) { // Проверяем простоту числа
            KP.push_back(K); // Сохраняем счетчик неудач
            pchP.push_back(n); // Добавляем простое число в результат
            similar.insert(n); // Добавляем число в множество
            countcikl++; // Увеличиваем счетчик сгенерированных чисел
            K = 0; // Сбрасываем счетчик
        }
    }
}

// Генерация простых чисел по ГОСТ
void GenGOST(int size, vector<int> pch, vector<int>& pchG, vector<int>& KG) {
    set<int> similar; // Множество для исключения повторений
    int K = 0; // Счетчик неудач
    random_device rd;
    mt19937 gen(rd()); // Генератор случайных чисел
    for (int countcikl = 0; countcikl != 10;) { // Генерируем 10 чисел
        int q = pch[gen() % 93]; // Выбираем случайный делитель
        K = 0; // Сбрасываем счетчик
        for (int u = 0; true; u += 2) { // Цикл для поиска простого числа
            int N = (1 << (size - 1)) / q; // Вычисляем начальное значение N
            if (N % 2 != 0) N += 1; // Делаем N четным
            int p = (N + u) * q + 1; // Формируем кандидата на простое число
            if (mod(2, p - 1, p) == 1 && mod(2, N + u, p) != 1) { // Проверяем условия ГОСТ
                int n1 = p, countn1 = 0;
                while (n1 > 0) { // Подсчитываем количество цифр в числе
                    countn1++;
                    n1 /= 10;
                }
                if (similar.find(p) != similar.end()) continue; // Если число уже было, пропускаем
                if (countn1 == size) { // Если длина числа соответствует требуемой
                    KG.push_back(K); // Сохраняем счетчик неудач
                    pchG.push_back(p); // Добавляем простое число в результат
                    countcikl++;
                    similar.insert(p); // Добавляем число в множество
                }
                break;
            }
            K++; // Увеличиваем счетчик неудач
        }
    }
}

int main() {
    int size = 3; // Размер генерируемых простых чисел
    vector<int> prostch; // Вектор для хранения простых чисел из файла
    vector<int> pchM, pchP, pchG; // Векторы для хранения сгенерированных простых чисел
    vector<int> KM, KP, KG; // Векторы для хранения счетчиков неудач
    tableprost(prostch); // Загружаем простые числа из файла
    cout << "Test Milera" << endl;
    GenMillera(size, prostch, pchM, KM); // Генерация чисел с использованием теста Миллера
    cout << "Num ";
    for (int i = 1; i <= 10; i++) cout << setw(4) << i << " "; // Вывод номеров
    cout << "\n";
    cout << " p  ";
    for (int prch : pchM) cout << setw(4) << prch << " "; // Вывод простых чисел
    cout << "\n";
    for (int i = 0; i < 10; i++) { // Вывод разделителей
        if (i == 0) cout << "    +";
        else cout << "   +";
    }
    cout << "\n";
    cout << " K  ";
    for (int K : KM) cout << setw(4) << K << " "; // Вывод счетчиков неудач
    cout << endl;
    cout << "\n" << "Test Poklingtona" << endl;
    GenPoklingtona(size, prostch, pchP, KP); // Генерация чисел с использованием теста Поклингтона
    cout << "Num ";
    for (int i = 1; i <= 10; i++) cout << setw(4) << i << " "; // Вывод номеров
    cout << "\n";
    cout << " p  ";
    for (int prch : pchP) cout << setw(4) << prch << " "; // Вывод простых чисел
    cout << "\n";
    for (int i = 0; i < 10; i++) { // Вывод разделителей
        if (i == 0) cout << "    +";
        else cout << "   +";
    }
    cout << "\n";
    cout << " K  ";
    for (int K : KP) cout << setw(4) << K << " "; // Вывод счетчиков неудач
    cout << endl;
    cout << "\n" << "GOST" << endl;
    GenGOST(size, prostch, pchG, KG); // Генерация чисел по стандарту ГОСТ
    cout << "Num ";
    for (int i = 1; i <= 10; i++) cout << setw(4) << i << " "; // Вывод номеров
    cout << "\n";
    cout << " p  ";
    for (int prch : pchG) cout << setw(4) << prch << " "; // Вывод простых чисел
    cout << "\n";
    for (int i = 0; i < 10; i++) { // Вывод разделителей
        if (i == 0) cout << "    +";
        else cout << "   +";
    }
    cout << "\n";
    cout << " K  ";
    for (int K : KG) cout << setw(4) << K << " "; // Вывод счетчиков неудач
    cout << "\n\n";
    resheto(); // Генерация простых чисел с помощью решета Эратосфена
}