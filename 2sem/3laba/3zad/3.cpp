#include <iostream>
#include <vector>
#include <cmath>
#include <iomanip>

using namespace std;

// Функция для вычисления температуры кофе в момент времени t
double coffeeTemperature(double T0, double Ts, double r, double t) {
    return Ts + (T0 - Ts) * exp(-r * t);
}

// Функция для вычисления коэффициентов линейной аппроксимации (y = a * x + b)
pair<double, double> linearApproximation(const vector<double>& x, const vector<double>& y) {
    double sum_x = 0, sum_y = 0, sum_xy = 0, sum_x2 = 0;
    int n = x.size();

    for (int i = 0; i < n; i++) {
        sum_x += x[i];
        sum_y += y[i];
        sum_xy += x[i] * y[i];
        sum_x2 += x[i] * x[i];
    }

    double a = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x);
    double b = (sum_y - a * sum_x) / n;

    return make_pair(a, b);
}

// // Функция для вычисления коэффициента корреляции
// double correlationCoefficient(const vector<double>& x, const vector<double>& y) {
//     double sum_x = 0, sum_y = 0, sum_xy = 0, sum_x2 = 0, sum_y2 = 0;
//     int n = x.size();

//     for (int i = 0; i < n; i++) {
//         sum_x += x[i];
//         sum_y += y[i];
//         sum_xy += x[i] * y[i];
//         sum_x2 += x[i] * x[i];
//         sum_y2 += y[i] * y[i];
//     }

//     double numerator = sum_xy - (sum_x * sum_y) / n;
//     double denominator_x = sqrt(sum_x2 - (sum_x * sum_x) / n);
//     double denominator_y = sqrt(sum_y2 - (sum_y * sum_y) / n);

//     return numerator / (denominator_x * denominator_y);
// }

// Функция для вычисления коэффициента корреляции
double correlationCoefficient(const vector<double>& x, const vector<double>& y) {
    double sum_x = 0, sum_y = 0, sum_xy = 0, sum_x2 = 0, sum_y2 = 0;
    int n = x.size();

    // Вычисляем средние значения
    for (int i = 0; i < n; i++) {
        sum_x += x[i];
        sum_y += y[i];
    }
    double mean_x = sum_x / n;
    double mean_y = sum_y / n;

    double numerator = 0, denominator_x = 0, denominator_y = 0;
    for (int i = 0; i < n; i++) {
        numerator += (x[i] - mean_x) * (y[i] - mean_y);
        denominator_x += (x[i] - mean_x) * (x[i] - mean_x);
        denominator_y += (y[i] - mean_y) * (y[i] - mean_y);
    }

    return numerator / sqrt(denominator_x * denominator_y);
}

int main() {
    // Ввод параметров
    double T0, Ts, r, time_limit;
    cout << "Введите начальную температуру кофе (в градусах Цельсия): ";
    cin >> T0;
    cout << "Введите температуру окружающей среды (в градусах Цельсия): ";
    cin >> Ts;
    cout << "Введите коэффициент охлаждения (dC): ";
    cin >> r;
    cout << "Введите время полного охлаждения (в секундах): ";
    cin >> time_limit;

    // Генерация данных
    vector<double> time;
    vector<double> temperature;
    for (double t = 0; t <= time_limit; t += 1.0) {
        time.push_back(t);
        temperature.push_back(coffeeTemperature(T0, Ts, r, t));
    }

    // Аппроксимация данных
    pair<double, double> coeffs = linearApproximation(time, temperature);
    double a = coeffs.first;
    double b = coeffs.second;

    // Вычисление коэффициента корреляции
    double corr = correlationCoefficient(time, temperature);

    cout << "Коэффициенты аппроксимирующей прямой: a = " << a << ", b = " << b << endl;
    cout << "Коэффициент корреляции: " << corr << endl;

    // Вывод таблицы
    cout << "+------+------------+" << endl;
    cout << "| Время | Температура |" << endl;
    cout << "+------+------------+" << endl;
    for (size_t i = 0; i < time.size(); i++) {
        cout << "| " << setw(5) << time[i] << " | " << setw(10) << temperature[i] << " |" << endl;
    }
    cout << "+------+------------+" << endl;

    return 0;
}