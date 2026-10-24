import Foundation

// Функция для печати смайликов ☺
func printHappyFaces(_ n: Int) {
for i in 1...n { // Цикл по числам от 1 до n
print("☺", terminator: "") // Печать смайлика без перехода на новую строку
if i % 3 == 0 { // Если текущее число кратно 3
print() // Переход на новую строку
}
if i == n && i % 3 != 0 { // Если текущее число равно n и не кратно 3
print() // Переход на новую строку
}
}
}

// Функция для печати пустых бутылок ©
func printEmptyBottles(_ n: Int) {
for i in 1...n { // Цикл по числам от 1 до n
print("©", terminator: "") // Печать пустой бутылки без перехода на новую строку
if i % 3 == 0 { // Если текущее число кратно 3
print() // Переход на новую строку
}
if i == n && i % 3 != 0 { // Если текущее число равно n и не кратно 3
print() // Переход на новую строку
}
}
}

// Функция для рассчета количества выпитых бутылок воды
func drinkWater(_ bottles: Int, _ rate: Int) -> Int {
var bottlesDrank = bottles // Переменная для хранения количества выпитых бутылок
var emptyBottles = bottles // Переменная для хранения количества пустых бутылок
var steps = 1 // Шаги выпития бутылок, начиная с 1

print("Given:") // Печать информации о начальном состоянии
printHappyFaces(bottles) // Печать смайликов для каждой выпитой бутылки
print("Step: \(steps)") // Печать номера шага
printEmptyBottles(emptyBottles) // Печать пустых бутылок для каждой пустой бутылки

// Пока есть достаточное количество пустых бутылок для обмена
while emptyBottles >= rate {
let exchangedBottles = emptyBottles / rate // Вычисление количества обмененных бутылок
bottlesDrank += exchangedBottles // Прибавление к общему количеству выпитых бутылок
let remainingEmptyBottles = emptyBottles % rate // Вычисление оставшихся пустых бутылок
emptyBottles = exchangedBottles + remainingEmptyBottles // Обновление количества пустых бутылок
steps += 1 // Увеличение шага на 1

print("Step: \(steps)") // Печать номера шага
printHappyFaces(exchangedBottles) // Печать смайликов для каждой обмененной бутылки
printEmptyBottles(remainingEmptyBottles) // Печать пустых бутылок для каждой оставшейся пустой бутылки

steps += 1 // Увеличение шага на 1
print("Step: \(steps)") // Печать номера шага
printEmptyBottles(emptyBottles) // Печать пустых бутылок для каждой пустой бутылки
}

print("Number of iterations: \(steps)") // Печать количества шагов
return bottlesDrank // Возврат общего количества выпитых бутылок
}

// Основная функция программы
func main() {
    print("Enter the number of water bottles: ", terminator: "") // Печать приглашения для ввода количества бутылок
    if let bottles = Int(readLine() ?? "") { // Чтение количества бутылок из ввода
        print("Enter the exchange rate of empty bottles for new ones: ", terminator: "") // Печать приглашения для ввода курса обмена
        if let rate = Int(readLine() ?? "") { // Чтение курса обмена из ввода
            let bottlesDrank = drinkWater(bottles, rate) // Вызов функции для рассчета количества выпитых бутылок
            print("Maximum number of bottles that can be drunk: \(bottlesDrank)") // Печать общего количества выпитых бутылок
        }
    }
}

main() // Вызов основной функции программы

1.8 Go
        package main

import (
"fmt"
)

func main() {
    var bottles, rate int
    fmt.Print("Введите количество банок с водой: ")
    fmt.Scanln(&bottles) // Считываем количество банок с водой
    fmt.Print("Введите курс обмена пустых банок на новые: ")
    fmt.Scanln(&rate) // Считываем курс обмена пустых банок на новые

    bottlesDrank := drinkWater(bottles, rate) // Вызываем функцию для определения максимального числа банок, которое можно выпить
    fmt.Println("Максимальное число банок, которое можно выпить:", bottlesDrank) // Выводим результат
}

func drinkWater(bottles, rate int) int {
bottlesDrank := bottles // Инициализируем переменную для подсчета количества выпитых банок
emptyBottles := bottles // Инициализируем переменную для отслеживания количества пустых банок
steps := 1 // Инициализируем счетчик шагов

fmt.Println("Дано: ") // Выводим заголовок для начала алгоритма
printHappyFaces(bottles) // Выводим смайлики для текущего количества банок с водой
fmt.Println("Шаг:", steps) // Выводим текущий шаг
printEmptyBottles(emptyBottles) // Выводим пустые банки

for emptyBottles >= rate { // Пока есть достаточно пустых банок для обмена
exchangedBottles := emptyBottles / rate // Вычисляем количество обменяемых банок
bottlesDrank += exchangedBottles // Увеличиваем общее количество выпитых банок
remainingEmptyBottles := emptyBottles % rate // Вычисляем количество оставшихся пустых банок после обмена
emptyBottles = exchangedBottles + remainingEmptyBottles // Обновляем количество пустых банок
steps++ // Увеличиваем счетчик шагов

fmt.Println("Шаг:", steps) // Выводим номер текущего шага
printHappyFaces(exchangedBottles) // Выводим смайлики для обменяемых банок
printEmptyBottles(remainingEmptyBottles) // Выводим пустые банки после обмена

steps++ // Увеличиваем счетчик шагов
fmt.Println("Шаг:", steps) // Выводим номер текущего шага
printEmptyBottles(emptyBottles) // Выводим пустые банки после обмена
}

fmt.Println("Количество итераций:", steps) // Выводим общее количество итераций
return bottlesDrank // Возвращаем общее количество выпитых банок
}

func printHappyFaces(n int) {
    for i := 1; i <= n; i++ { // Итерируемся от 1 до количества банок с водой
        fmt.Print("☺") // Выводим смайлик для каждой банки
        if i%3 == 0 { // Если текущий номер кратен 3
            fmt.Println() // Выводим пустую строку
        }
        if i == n && i%3 != 0 { // Если последняя итерация и количество не кратно 3
            fmt.Println() // Выводим пустую строку
        }
    }
}

func printEmptyBottles(n int) {
    for i := 1; i <= n; i++ { // Итерируемся от 1 до количества пустых банок
        fmt.Print("©") // Выводим пустую банку для каждой пустой банки
        if i%3 == 0 { // Если текущий номер кратен 3
            fmt.Println() // Выводим пустую строку
        }
        if i == n && i%3 != 0 { // Если последняя итерация и количество не кратно 3
            fmt.Println() // Выводим пустую строку
        }
    }
}