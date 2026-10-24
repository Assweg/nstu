using System;

class Program
{
    static bool IsValidTime(string time)
    {
        // Должно быть ровно 4 цифры
        if (time.Length != 4)
        {
            return false;
        }

        // Первые 2 символа - часы, последние 2 символа - минуты
        string hours = time.Substring(0, 2);
        string minutes = time.Substring(2, 2);

        // Преобразуем строки в числа
        if (int.TryParse(hours, out int h) && int.TryParse(minutes, out int m))
        {
            // Проверяем диапазоны
            return (h >= 0 && h <= 23) && (m >= 0 && m <= 59);
        }

        return false;
    }

    static void Main()
    {
        Console.Write("Введите последовательность чисел: ");
        string input = Console.ReadLine();

        if (IsValidTime(input))
        {
            Console.WriteLine("YES");
        }
        else
        {
            Console.WriteLine("NO");
        }
    }
}
