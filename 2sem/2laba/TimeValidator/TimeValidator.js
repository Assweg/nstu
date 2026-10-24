const readline = require('readline');

function isValidTime(time) {
    // Должно быть ровно 4 цифры
    if (time.length !== 4) {
        return false;
    }

    // Первые 2 символа - часы, последние 2 символа - минуты
    const hours = time.slice(0, 2);
    const minutes = time.slice(2, 4);

    // Преобразуем строки в числа
    const h = parseInt(hours, 10);
    const m = parseInt(minutes, 10);

    // Проверяем диапазоны
    return (h >= 0 && h <= 23) && (m >= 0 && m <= 59);
}

// Создаем интерфейс для чтения данных из стандартного ввода
const rl = readline.createInterface({
    input: process.stdin,
            output: process.stdout
});

// Запрашиваем у пользователя ввод
        rl.question('Введите последовательность чисел: ', (input) => {
        if (isValidTime(input)) {
        console.log('YES');
    } else {
            console.log('NO');
    }
            rl.close(); // Закрываем интерфейс
});
