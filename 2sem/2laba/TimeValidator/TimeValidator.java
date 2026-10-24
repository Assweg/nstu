package TimeValidator;

import java.util.Scanner;

class TimeValidator {

    // Метод для проверки корректности времени
    public static boolean isValidTime(String time) {
        if (time.length() != 4) {
            return false; // Должно быть ровно 4 цифры
        }

        // Первые 2 символа - часы, последние 2 символа - минуты
        String hours = time.substring(0, 2);
        String minutes = time.substring(2, 4);

        // Преобразуем строки в числа
        int h = Integer.parseInt(hours);
        int m = Integer.parseInt(minutes);

        // Проверяем диапазоны
        return (h >= 0 && h <= 23) && (m >= 0 && m <= 59);
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Введите последовательность чисел: ");
        String input = scanner.nextLine();

        if (isValidTime(input)) {
            System.out.println("YES");
        } else {
            System.out.println("NO");
        }

        scanner.close();
    }
}
