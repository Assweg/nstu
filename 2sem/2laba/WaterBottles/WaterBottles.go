package main

import (
        "fmt"
        )

func main() {
    var bottles, rate int

    // Ввод количества банок с водой
    fmt.Print("Введите количество банок с водой: ")
    fmt.Scan(&bottles)

    // Ввод курса обмена пустых банок на новые
    fmt.Print("Введите курс обмена пустых банок на новые: ")
    fmt.Scan(&rate)

    bottlesDrank := drinkWater(bottles, rate) // Вызов функции drinkWater
    fmt.Println("Максимальное число банок, которое можно выпить:", bottlesDrank) // Вывод результата
}

func drinkWater(bottles int, rate int) int {
    bottlesDrank := bottles // Начальное количество выпитых банок
    emptyBottles := bottles  // Начальное количество пустых банок
    steps := 0              // Счетчик шагов

    fmt.Println("Дано:")
    printHappyFaces(bottles)
    steps++
    fmt.Printf("Шаг: %d\n", steps)
    printEmptyBottles(emptyBottles)

    for emptyBottles >= rate { // Цикл, пока пустых банок достаточно для обмена
        exchangedBottles := emptyBottles / rate
        bottlesDrank += exchangedBottles // Обновление количества выпитых банок

        remainingEmptyBottles := emptyBottles % rate // Оставшиеся пустые банки
        emptyBottles = exchangedBottles + remainingEmptyBottles // Обновление количества пустых банок

        steps++
        fmt.Printf("Шаг: %d\n", steps)
        printHappyFaces(exchangedBottles)
        printEmptyBottles(remainingEmptyBottles)

        steps++
        fmt.Printf("Шаг: %d\n", steps)
        printEmptyBottles(emptyBottles)
    }

    fmt.Printf("Количество итераций: %d\n", steps) // Вывод количества итераций
    return bottlesDrank // Возврат общего количества выпитых банок
}

func printHappyFaces(n int) { // Функция для печати улыбающихся лиц
    for i := 1; i <= n; i++ {
        fmt.Print("☺") // Вывод улыбающегося лица
        if i%3 == 0 { // Каждые 3 улыбающихся лица переход на новую строку
            fmt.Println()
        }
        if i == n && i%3 != 0 { // Переход на новую строку, если последнее лицо не третье
            fmt.Println()
        }
    }
}

func printEmptyBottles(n int) { // Функция для печати пустых банок
    for i := 1; i <= n; i++ {
        fmt.Print("©") // Вывод пустой банки
        if i%3 == 0 { // Каждые 3 банки переход на новую строку
            fmt.Println()
        }
        if i == n && i%3 != 0 { // Переход на новую строку, если последняя банка не третья
            fmt.Println()
        }
    }
}
