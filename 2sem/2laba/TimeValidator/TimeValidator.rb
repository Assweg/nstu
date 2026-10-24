def valid_time?(time)
    # Должно быть ровно 4 цифры
return false if time.length != 4

    # Первые 2 символа - часы, последние 2 символа - минуты
    hours = time[0, 2]
minutes = time[2, 2]

    # Преобразуем строки в числа
h = hours.to_i
    m = minutes.to_i

# Проверяем диапазоны
    (0..23).include?(h) && (0..59).include?(m)
end

print "Введите последовательность чисел: "
input = gets.chomp

if valid_time?(input)
puts "YES"
    else
puts "NO"
end
