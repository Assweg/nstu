#include <iostream>
#include <iomanip>
#include <cmath>
#include <vector>
 
using namespace std;
 
const double EPS = 0.001;   // Точность
const int MAX_ITERATIONS = 1000;

// Функция для вывода вектора
void printVector(const vector<double>& vec) {
   for (double val : vec) {
       cout << val << " ";
   }
   cout << endl;
}
 
// Функция для вывода матрицы
void printMatrix(const vector<vector<double>>& mat) {
   for (const auto& row : mat) {
       printVector(row);
   }
}
 
// Функция для решения системы методом LU-разложения
vector<double> solveLU(const vector<vector<double>>& A, const vector<double>& b) {
    int n = A.size(); // Размерность матрицы (n x n)
    vector<vector<double>> L(n, vector<double>(n, 0.0)), U(n, vector<double>(n, 0.0)); // Матрицы L и U
    
    // LU-разложение: разбиваем матрицу A на произведение двух матриц L и U
    for (int i = 0; i < n; i++) { // Проходим по строкам матрицы
        for (int j = 0; j < n; j++) { // Проходим по столбцам матрицы
            if (i <= j) {
                U[i][j] = A[i][j];
                for (int k = 0; k < i; k++) { // Вычитаем сумму уже найденных произведений L[i][k] * U[k][j]
                    U[i][j] -= L[i][k] * U[k][j];
                }
            }
            if (i > j) {
                L[i][j] = A[i][j]; // Начальное значение L[i][j] равно соответствующему элементу A[i][j]
                for (int k = 0; k < j; k++) { // Вычитаем сумму уже найденных произведений L[i][k] * U[k][j]
                    L[i][j] -= L[i][k] * U[k][j];
                }
                L[i][j] /= U[j][j]; // Делим на диагональный элемент U[j][j], чтобы получить единичную диагональ в L
            }
        }
    }

    // Прямой ход: решаем Ly = b
    vector<double> y(n, 0.0); // Вектор промежуточных значений
    for (int i = 0; i < n; i++) { // Проходим по строкам матрицы L
        y[i] = b[i]; // Начальное значение y[i] равно соответствующему элементу b[i]
        for (int j = 0; j < i; j++) { // Вычитаем сумму уже найденных произведений L[i][j] * y[j]
            y[i] -= L[i][j] * y[j];
        }
    }

    // Обратный ход: решаем Ux = y
    vector<double> x(n, 0.0); // Искомый вектор решений
    for (int i = n - 1; i >= 0; i--) { // Проходим по строкам матрицы U снизу вверх
        x[i] = y[i]; // Начальное значение x[i] равно соответствующему элементу y[i]
        for (int j = i + 1; j < n; j++) { // Вычитаем сумму уже найденных произведений U[i][j] * x[j]
            x[i] -= U[i][j] * x[j];
        }
        x[i] /= U[i][i]; // Делим на диагональный элемент U[i][i]
    }

    return x;
}
 
// Функция для решения системы методом Зейделя
vector<double> solveGaussSeidel(const vector<vector<double>>& A, const vector<double>& b) {
    int n = A.size(); // Размерность системы (количество уравнений и переменных)
    vector<double> x(n, 0.0), x_new(n, 0.0); // Векторы текущего и нового приближений
    double sum; // Переменная для хранения промежуточной суммы
    double norm_diff; // Норма разности между текущим и новым приближениями
    int iteration = 0; // Счетчик итераций

    do {
        x = x_new; // Обновляем текущее приближение на основе нового
        for (int i = 0; i < n; i++) { // Проходим по всем переменным
            sum = b[i]; // Начинаем с правой части уравнения b[i]

            // Вычисляем сумму для всех j != i (исключая диагональный элемент)
            for (int j = 0; j < n; j++) {
                if (i != j) {
                    sum -= A[i][j] * x[j]; // Вычитаем произведение коэффициента и текущего значения x[j]
                }
            }

            // Вычисляем новое значение x_new[i], используя диагональный элемент A[i][i]
            x_new[i] = sum / A[i][i];
        }

        // Вычисляем норму разности между текущим и новым приближениями
        norm_diff = 0.0;
        for (int i = 0; i < n; ++i) {
            norm_diff += (x_new[i] - x[i]) * (x_new[i] - x[i]); // Сумма квадратов разностей
        }
        norm_diff = sqrt(norm_diff); // Корень из суммы квадратов (евклидова норма)

        iteration++; // Увеличиваем счетчик итераций
    } while (norm_diff > EPS && iteration < MAX_ITERATIONS); // Повторяем, пока не достигнем точности или лимита итераций

    // Если метод не сошелся за максимальное количество итераций, выводим сообщение
    if (iteration == MAX_ITERATIONS) {
        cout << "Превышено максимальное количество итераций. Метод не сошелся." << endl;
    }

    return x_new;
}
 
// Функция для решения системы методом простых итераций
vector<double> solveSimpleIteration(const vector<vector<double>>& A, const vector<double>& b, const vector<double>& x0) {
    int n = A.size(); // Размерность системы (количество уравнений и переменных)
    vector<double> x = x0; // Текущее приближение решения (начальное значение)
    vector<double> x_new(n, 0.0); // Новое приближение решения
    double norm_diff; // Норма разности между текущим и новым приближениями
    int iteration = 0; // Счетчик итераций

    do {
        for (int i = 0; i < n; ++i) { // Проходим по всем переменным
            double sum = b[i]; // Начинаем с правой части уравнения b[i]

            // Вычисляем сумму для всех j != i (исключая диагональный элемент)
            for (int j = 0; j < n; ++j) {
                if (i != j) { // Исключаем диагональный элемент
                    sum -= A[i][j] * x[j]; // Вычитаем произведение коэффициента и текущего значения x[j]
                }
            }

            if (fabs(A[i][i]) > EPS) { // Если диагональный элемент не равен нулю
                x_new[i] = sum / A[i][i]; // Вычисляем новое значение x_new[i]
            } else {
                cout << "Ошибка: деление на ноль при итерации " << iteration << endl;
                return x; // Возвращаем текущее приближение в случае ошибки
            }
        }

        // Вычисляем норму разности между текущим и новым приближениями
        norm_diff = 0.0;
        for (int i = 0; i < n; ++i) {
            norm_diff += (x_new[i] - x[i]) * (x_new[i] - x[i]); // Сумма квадратов разностей
        }
        norm_diff = sqrt(norm_diff); // Корень из суммы квадратов (евклидова норма)

        x = x_new; // Обновляем текущее приближение на основе нового
        iteration++; // Увеличиваем счетчик итераций
    } while (norm_diff > EPS && iteration < MAX_ITERATIONS); // Повторяем, пока не достигнем точности или лимита итераций

    // Если метод не сошелся за максимальное количество итераций, выводим сообщение
    if (iteration == MAX_ITERATIONS) {
        cout << "Превышено максимальное количество итераций. Метод не сошелся." << endl;
    }

    return x; // Возвращаем найденное решение
}
 
int main() {
   // Инициализация системы уравнений
   vector<vector<double>> A = { {0.89, -0.04, 0.21, -18}, {0.25, -1.23, 0.08, -0.09}, {-0.21, 0.08, 0.8, -0.13}, {0.15, -1.31, 0.06, -1.21} };
   vector<double> b = { -1.24, -1.21, 2.56, 0.89 };
 
   // Решение системы прямым методом LU-разложения
   vector<double> x_lu = solveLU(A, b);
   cout << "Решение системы прямым методом LU-разложения:" << endl;
   printVector(x_lu);
 
   // Решение системы приближенным методом Зейделя
   vector<double> x_gauss = solveGaussSeidel(A, b);
   cout << "Решение системы приближенным методом Зейделя:" << endl;
   printVector(x_gauss);
 
   // Преобразование системы к каноническому виду
   vector<vector<double>> B(4, vector<double>(4, 0.0));
   vector<double> f(4, 0.0);
   for (size_t i = 0; i < 4; ++i) {
       for (size_t j = 0; j < 4; ++j) {
           if (i == j) {
               B[i][j] = 0.0;
           }
           else {
               B[i][j] = -A[i][j] / A[i][i];
           }
       }
       f[i] = b[i] / A[i][i];
   }
 
   // Начальное приближение
   vector<double> x0 = { 0.0, 0.0, 0.0, 0.0 };
 
   // Решение системы итерационным методом
   vector<double> x_iter = solveSimpleIteration(B, f, x0);
   cout << "Решение системы итерационным методом:" << endl;
   printVector(x_iter);
 
   // Вывод результатов в таблицу
   cout << "N\tx1\tx2\tx3\tx4\tEPS" << endl;
   for (int i = 0; i < x_lu.size(); i++) {
       cout << i + 1 << "\t";
       for (size_t j = 0; j < x_lu.size(); ++j) {
           cout << x_lu[j] << "\t";
       }
       // Вычисляем норму разности векторов вручную
       double norm_diff = 0.0;
       for (size_t j = 0; j < x_lu.size(); ++j) {
           norm_diff += (x_lu[j] - x_gauss[j]) * (x_lu[j] - x_gauss[j]);
       }
       norm_diff = sqrt(norm_diff);
       cout << "\t" << norm_diff << endl;
   }

   cout << "Корни системы уравнений:" << endl;
   printVector(x_lu);
 
   return 0;
}