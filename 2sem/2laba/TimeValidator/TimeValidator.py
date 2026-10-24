def is_valid_time(time):
        # Должно быть ровно 4 цифры
    if len(time) != 4:
        return False
    
    # Первые 2 символа - часы, последние 2 символа - минуты
        hours = time[:2]
minutes = time[2:]

        # Преобразуем строки в числа
h = int(hours)
m = int(minutes)
    
    # Проверяем диапазоны
    return (0 <= h <= 23) and (0 <= m <= 59)

# Запрашиваем ввод у пользователя
input_time = input("Введите последовательность чисел: ")

if is_valid_time(input_time):
print("YES")
else:
print("NO")
