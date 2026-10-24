fun isValidTime(time: String): Boolean {
    // Проверяем, что длина строки равна 4
    if (time.length != 4) {
        return false // Должно быть ровно 4 цифры
    }

    // Первые 2 символа - часы, последние 2 символа - минуты
    val hours = time.substring(0, 2)
    val minutes = time.substring(2, 4)

    // Преобразуем строки в числа
    val h = hours.toInt()
    val m = minutes.toInt()

    // Проверяем диапазоны
    return (h in 0..23) && (m in 0..59)
}

fun main() {
    print("Введите последовательность чисел: ")
    val input = readLine() ?: ""

    if (isValidTime(input)) {
        println("YES")
    } else {
        println("NO")
    }
}
