package main

import (
        "fmt"
        "strconv"
        )

func isValidTime(time string) bool {
    if len(time) != 4 {
        return false // Должно быть ровно 4 цифры
    }

    // Первые 2 символа - часы, последние 2 символа - минуты
    hours := time[:2]
    minutes := time[2:]

    // Преобразуем строки в числа
    h, err1 := strconv.Atoi(hours)
    m, err2 := strconv.Atoi(minutes)

    // Проверяем, что преобразование прошло успешно и диапазоны
    return err1 == nil && err2 == nil && h >= 0 && h <= 23 && m >= 0 && m <= 59
}

func main() {
    var input string
    fmt.Print("Введите последовательность чисел: ")
    fmt.Scan(&input)
    if isValidTime(input) {
        fmt.Println("YES")
    } else {
        fmt.Println("NO")
    }
}
