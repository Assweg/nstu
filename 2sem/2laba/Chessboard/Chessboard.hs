import Control.Monad (unless)
import Data.Char (isDigit)

-- Функция для проверки корректности введенного времени
isValidTime :: String -> Bool
        isValidTime time
| length time /= 4 = False  -- Должно быть ровно 4 цифры
| otherwise =
let hours = take 2 time     -- Первые 2 символа - часы
        minutes = drop 2 time   -- Последние 2 символа - минуты
        h = read hours :: Int     -- Преобразуем строки в число
m = read minutes :: Int
        in (h >= 0 && h <= 23) && (m >= 0 && m <= 59)  -- Проверяем диапазоны

main :: IO ()
main = do
putStrLn "Введите последовательность чисел: "
input <- getLine  -- Считываем строку ввода
if isValidTime input
then putStrLn "YES"  -- Если время корректное
else putStrLn "NO"   -- Если время некорректное
