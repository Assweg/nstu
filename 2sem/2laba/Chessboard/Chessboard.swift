import Foundation

// Функция isValidMove, которая проверяет, является ли передвижение по координатам (x, y)
// в пределах доски размера N x M, исходя из направления move ('L' - влево, 'R' - вправо, 'U' - вверх, 'D' - вниз).
func isValidMove(x: Int, y: Int, n: Int, m: Int, move: Character) -> Bool {
    switch move {
        case "L":
            return y > 1
        case "R":
            return y < m
        case "U":
            return x > 1
        case "D":
            return x < n
        default:
            return false
    }
}

        // Функция findStartPosition, которая находит стартовую позицию на доске размера N x M,
// с учетом строки команд s.
        func findStartPosition(n: Int, m: Int, s: String) -> (Int, Int) {
        for i in 1...n {
    for j in 1...m {
        var x = i
        var y = j
        var valid = true

        for move in s {
            if !isValidMove(x: x, y: y, n: n, m: m, move: move) {
                valid = false
                break
            }

            switch move {
                case "L":
                    y -= 1
                case "R":
                    y += 1
                case "U":
                    x -= 1
                case "D":
                    x += 1
                default:
                    break
            }
        }

        if valid {
            return (i, j)
        }
    }
}
    return (-1, -1)
            }

        // Основная функция программы.
        func main() {
            print("Enter size (N M): ")
            let sizeInput = readLine() ?? ""
            let dimensions = sizeInput.split(separator: " ").map { Int($0) ?? 0 }
            let n = dimensions[0]
            let m = dimensions[1]

            print("Enter string of commands: ")
            let commands = readLine() ?? ""

            let startPos = findStartPosition(n: n, m: m, s: commands)

            if startPos == (-1, -1) {
                print("It is impossible to complete all commands without leaving the board.")
            } else {
                print("Result: \(startPos)")
            }
        }

        // Вызов основной функции программы.
        main()
