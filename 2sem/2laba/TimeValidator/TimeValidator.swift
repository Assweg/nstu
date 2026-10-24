import Foundation

func isValidTime(_ time: String) -> Bool {
    // Должно быть ровно 4 цифры
    if time.count != 4 {
        return false
    }

    // Первые 2 символа - часы, последние 2 символа - минуты
    let hours = String(time.prefix(2))
    let minutes = String(time.suffix(2))

    // Преобразуем строки в числа
    guard let h = Int(hours), let m = Int(minutes) else {
        return false
    }

    // Проверяем диапазоны
    return (h >= 0 && h <= 23) && (m >= 0 && m <= 59)
}

print("Введите последовательность чисел: ", terminator: "")
if let input = readLine() {
        if isValidTime(input) {
    print("YES")
} else {
print("NO")
    }
            }
