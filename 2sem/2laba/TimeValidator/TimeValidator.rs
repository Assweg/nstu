use std::io;
use std::str::FromStr;

fn is_valid_time(time: &str) -> bool {
    if time.len() != 4 {
        return false; // Должно быть ровно 4 цифры
    }

    // Первые 2 символа - часы, последние 2 символа - минуты
    let hours = &time[0..2];
    let minutes = &time[2..4];

    // Преобразуем строки в числа
    let h: i32 = i32::from_str(hours).unwrap_or(-1);
    let m: i32 = i32::from_str(minutes).unwrap_or(-1);

    // Проверяем диапазоны
    (0..=23).contains(&h) && (0..=59).contains(&m)
}

fn main() {
    let mut input = String::new();
    println!("Введите последовательность чисел: ");
    io::stdin().read_line(&mut input).unwrap();
    let input = input.trim();

    if is_valid_time(input) {
        println!("YES");
    } else {
        println!("NO");
    }
}
