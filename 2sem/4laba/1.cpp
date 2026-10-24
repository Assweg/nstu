#include <iostream>
#include <vector>
#include <cmath>
#include <limits>
#include <iomanip>
#include <string>

using namespace std;

// Функция f(x) = x^2 - 3*sin(x)
double f(double x) {
    return x * x - 3 * sin(x);
}

// Производная функции f(x), 2*x - 3*cos(x)
double df(double x) {
    return 2 * x - 3 * cos(x);
}

// Функция для метода простых итераций, phi(x) = sqrt(3*sin(x))
double phi(double x) {
    return sqrt(3 * sin(x));
}

// Метод Ньютона
vector<vector<double>> newtonMethod(double x0, double eps) {
    vector<vector<double>> history;
    double x = x0, h;

    if (abs(df(x)) < numeric_limits<double>::epsilon()) {
        cout << "Производная равна нулю в начальной точке." << endl;
        return history;
    }

    do {
        double x_prev = x; // Tекущее значение x
        h = f(x) / df(x);   // Корректируем текущее значение x, чтобы приблизиться к корню
        x -= h; // Новое приближение к корню
        history.push_back({x_prev, x, abs(h)});
    } while (abs(h) >= eps);

    cout << fixed << setprecision(numeric_limits<double>::digits10);
    cout << "Найденный корень: " << x << endl;
    return history;
}

// Метод бисекции
vector<vector<double>> bisection(double a, double b, double eps) {
    vector<vector<double>> history;
    double c, fa = f(a), fb = f(b), fc;

    if (fa * fb >= 0) {
        cerr << "Функция имеет одинаковые знаки на концах интервала." << endl;
        return history;
    }

    do {
        c = (a + b) / 2.0;
        fc = f(c);
        history.push_back({a, b, b - a});

        if (fa * fc < 0) {
            b = c;
            fb = fc;
        } else {
            a = c;
            fa = fc;
        }

        if (abs(fc) < eps || abs(b - a) <= eps) {
            history.push_back({a, b, b - a});
            break;
        }
    } while (true);

    cout << fixed << setprecision(numeric_limits<double>::digits10);
    cout << "Найденный корень: " << c << endl;
    return history;
}

// Метод простых итераций
vector<vector<double>> simpleIterationMethod(double x0, double eps) {
    vector<vector<double>> history;
    double x = x0, x_next;
    do {
        x_next = phi(x);
        double error = fabs(x_next - x);
        history.push_back({x, x_next, error});
        x = x_next;
    } while (history.back()[2] >= eps);

    cout << fixed << setprecision(numeric_limits<double>::digits10);
    cout << "Найденный корень: " << x << endl;
    return history;
}

// Функция для вывода таблицы
void printTable(const vector<vector<double>>& data, const string& header1, const string& header2, const string& header3) {
    cout << left << setw(10) << "N" << setw(25) << header1 << setw(25) << header2 << setw(25) << header3 << endl;
    for (size_t i = 0; i < data.size(); ++i) {
        cout << left << setw(10) << i + 1 << setw(25) << data[i][0] << setw(25) << data[i][1] << setw(25) << data[i][2] << endl;
    }
}

int main() {
    double a1 = -0.5, b1 = 0.5; // Интервалы для метода бисекции
    double a = 1, b = 2;        // Другой интервал для бисекции
    double eps = 1e-4;          // Точность для всех методов
    double x0 = 0;              // Начальное приближение
    double x01 = 1;             // Второе начальное приближение

    // Вывод метода Ньютона
    cout << string(18, '-') << "Метод Ньютона" << string(18, '-') << endl;
    vector<vector<double>> newton1 = newtonMethod(x0, eps);
    vector<vector<double>> newton2 = newtonMethod(x01, eps);

    printTable(newton1, "xn", "xn+1", "|xn+1 - xn|");
    cout << endl;
    printTable(newton2, "xn", "xn+1", "|xn+1 - xn|");

    // Вывод метода бисекции
    cout << string(18, '-') << "Метод бисекции" << string(18, '-') << endl;
    vector<vector<double>> bisection1 = bisection(a1, b1, eps);
    vector<vector<double>> bisection2 = bisection(a, b, eps);

    printTable(bisection1, "an", "bn", "|bn - an|");
    cout << endl;
    printTable(bisection2, "an", "bn", "|bn - an|");

    // Вывод метода простых итераций
    cout << string(18, '-') << "Метод простых итераций" << string(18, '-') << endl;
    vector<vector<double>> simple_iterations1 = simpleIterationMethod(x0, eps);
    vector<vector<double>> simple_iterations2 = simpleIterationMethod(x01, eps);

    printTable(simple_iterations1, "xn", "xn+1", "|xn+1 - xn|");
    cout << endl;
    printTable(simple_iterations2, "xn", "xn+1", "|xn+1 - xn|");

    // Вывод сходимости
    cout << "Количество итераций метода Ньютона: " << newton2.size() << endl;
    cout << "Количество итераций метода бисекции: " << bisection2.size() << endl;
    cout << "Количество итераций метода простых итераций: " << simple_iterations2.size() << endl;

    return 0;
}