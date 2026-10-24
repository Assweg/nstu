#include <iostream>
#include <random>
#include <algorithm>
#include <iomanip>
#include <string>
#include <vector>
 
 
using namespace std;
#pragma once

using namespace std;
// Функция выполняет подстановку байтов в соответствии с предопределенной таблицей подстановки (S-box)
void SubBytes(vector<unsigned char>& state) {
   vector<unsigned char> Sbox = {  // 256 элементов, однобайтовые значения
      0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
      0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
      0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
      0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
      0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
      0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
      0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
      0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
      0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
      0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
      0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
      0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
      0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
      0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
      0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
      0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
   };
 
   vector<unsigned char> temp;
   for (auto i : state) {
       temp.push_back(Sbox[i]);
   }
   state = temp;
}
 
// Функция выполняет обратную подстановку байтов (Inverse S-box)
void InversionSubBytes(vector<unsigned char>& state) {
   vector<unsigned char> InvSbox = {   // 256 элементов, однобайтовые значения
        0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
        0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
        0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
        0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
        0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
        0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
        0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
        0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
        0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
        0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
        0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
        0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
        0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
        0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
        0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
        0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
   };
 
   vector<unsigned char> temp;
   for (auto i : state) { // Проходимся по каждому элементу строки 
       temp.push_back(InvSbox[i]); // Заменяем его на табличное значение
   }
   state = temp;
}
 
 
// Функция генерирует случайный ключ из 16 символов, от 0 до 9
void  keyGeneration(vector<unsigned char>& key) { 
   mt19937_64 gen(random_device{}());  // Генератор случайных чисел для получения начального значения
   uniform_int_distribution<int> numbers(0, 9);    // Равномерное распределение случайных чисел от 0 до 9
   for (int i = 1; i <= 16; i++) {
       key.push_back('0' + numbers(gen));
   }
}
 
// Функция операции XOR для добавления ключа к данным
vector<unsigned char> AddRoundKey(vector<unsigned char>& first, vector<unsigned char>& second) {    // функция, которая принимает два вектора по ссылке и возвращает новый вектор
   vector<unsigned char> temp; // Временный вектор, для хранения результатов операций XOR
   for (int i = 0; i < 4; ++i) {
       temp.push_back(first[i] ^ second[i]);   // Операция XOR
   }
   return temp;
}

// Функция сдвигает все элементы влево (первый элемент становится последним)
void ShiftElmnts(vector<unsigned char>& state) {    
   vector<unsigned char> temp(state.size());
   for (int i = 1; i < state.size(); i++) {
       temp[i - 1] = state[i]; // Каждый элемент вектора state сдвигается влево на одну позицию в векторе temp
   }
   temp[state.size() - 1] = state[0];  // Первый элемент вектора state становится последним элементом в векторе temp
 
   state = temp;
}
 
// Функция выполняет умножение в поле Галуа с использованием полинома
unsigned char galuaMn(unsigned char a, unsigned char b) { 
   unsigned char result = 0;   // Хранение результата умножения
   unsigned char hi_bit_set;   // Переменная для проверки, установлен ли самый старший бит в a
   for (unsigned char i = 0; i < 8; i++) { // Поле Галуа размером 8 бит
       if (b & 1) {    // Если младший бит в b равен 1
           result ^= a;    // То a прибавляется к result с помощью операции XOR
       }
       hi_bit_set = a & 0x80;  // Проверка, установлен ли самый старший бит в a
       a <<= 1;    // Сдвиг влево на один бит
       if (hi_bit_set) {   // Если самый старший бит в a был установлен до сдвига
           a ^= 0x1b;  // То к a применяется операция XOR
       }
       b >>= 1;    // сдвиг вправо на один бит
   }
   return result; 
}

// Функция для ускорения последующих операций умножения
vector<unsigned char> tabl_2() {
   vector<unsigned char> tabl_with_2(256);
   for (int i = 0; i < 256; ++i) {
       tabl_with_2[i] = galuaMn(i, 2); // Вызов функции, которая выполняет умножение в поле Галуа для числа i на 2
   }
   return tabl_with_2; // Возвращение заполненной таблицы умножения
}
 
// Функция создает и возвращает таблицу умножения в поле Галуа
vector<unsigned char> tabl_3() {
   vector<unsigned char> tabl_with_3(256);
   for (int i = 0; i < 256; ++i) {
       tabl_with_3[i] = galuaMn(i, 3);
   }
   return tabl_with_3;
}
 
// Функция создает и возвращает таблицу умножения в поле Галуа для числа 14
vector<unsigned char> tabl_14() {
   vector<unsigned char> tabl_with_14(256);
   for (int i = 0; i < 256; ++i) {
       tabl_with_14[i] = galuaMn(i, 14);
   }
   return tabl_with_14;
}
 
// Функция создает и возвращает таблицу умножения в поле Галуа для числа 9
vector<unsigned char> tabl_9() {
   vector<unsigned char> tabl_with_9(256);
   for (int i = 0; i < 256; ++i) {
       tabl_with_9[i] = galuaMn(i, 9);
   }
   return tabl_with_9;
}
 
// Функция создает и возвращает таблицу умножения в поле Галуа для числа 13
vector<unsigned char> tabl_13() {
   vector<unsigned char> tabl_with_13(256);
   for (int i = 0; i < 256; ++i) {
       tabl_with_13[i] = galuaMn(i, 13);
   }
   return tabl_with_13;
}
// Функция создает и возвращает таблицу умножения в поле Галуа для числа 11
vector<unsigned char> tabl_11() {
   vector<unsigned char> tabl_with_11(256);
   for (int i = 0; i < 256; ++i) {
       tabl_with_11[i] = galuaMn(i, 11);
   }
   return tabl_with_11;
}
 
// Функция выполняет операции умножения на 2 и 3 над столбцами матрицы данных
void MnMatrix(vector<unsigned char>& state) {
   vector<unsigned char> tabl_with_2 = tabl_2();   // Вектор содержит таблицу умножения в поле Галуа для числа 2
 
   vector<unsigned char> tabl_with_3 = tabl_3();   // Вектор содержит таблицу умножения в поле Галуа для числа 3
 
   vector<unsigned char> temp;
   // Вычисление новых значений
   temp.push_back(tabl_with_2[state[0]] ^ tabl_with_3[state[1]] ^ state[2] ^ state[3]);
   temp.push_back(tabl_with_2[state[1]] ^ tabl_with_3[state[2]] ^ state[0] ^ state[3]);
   temp.push_back(tabl_with_2[state[2]] ^ tabl_with_3[state[3]] ^ state[0] ^ state[1]);
   temp.push_back(tabl_with_2[state[3]] ^ tabl_with_3[state[0]] ^ state[1] ^ state[2]);
   state = temp;
}
 
// Функция выполняет расширение ключа (операция сдвига, замена байтов, применение констант для каждого раунда)
void KeyExpansion(vector<unsigned char>& key, vector<vector<unsigned char>>& roundKeys) {
   const vector<unsigned char> Rcon = {    // Вектор для операции XOR с ключом
       0x00, 0x00, 0x00, 0x00,
       0x01, 0x00, 0x00, 0x00,
       0x02, 0x00, 0x00, 0x00,
       0x04, 0x00, 0x00, 0x00,
       0x08, 0x00, 0x00, 0x00,
       0x10, 0x00, 0x00, 0x00,
       0x20, 0x00, 0x00, 0x00,
       0x40, 0x00, 0x00, 0x00,
       0x80, 0x00, 0x00, 0x00,
       0x1b, 0x00, 0x00, 0x00,
       0x36, 0x00, 0x00, 0x00
   };
 
   vector<unsigned char> temp;
   int i = 0;
   int Nk = 4;  // размер ключа
   int Nb = 4;  // размер блока
   int Nr = 10; // количество раундов
 
   roundKeys.resize(Nb * (Nr + 1), vector<unsigned char>(4));  // Изменение размера вектора для вмещения расширенных ключей
 
   // Заполнение первых ключей из исходного ключа
   while (i < Nk) {
       temp = { key[4 * i], key[4 * i + 1], key[4 * i + 2], key[4 * i + 3] };  // Копирование 4-байтного блока из исходного ключа
       roundKeys[i] = temp;
       i++;
   }
 
   // Расширение ключей
   i = Nk;
   while (i < (Nb * (Nr + 1))) {   // Цикл для расширения ключа до необходимого размера
       temp = roundKeys[i - 1]; 
       if (i % Nk == 4) {  // Проверка, нужно ли применять операции SubBytes и ShiftElmnts к блоку ключа
           ShiftElmnts(temp);  // Сдвиг элементов
           SubBytes(temp); // Замена элементов на другие значения
           for (int k = 0; k < temp.size(); ++k) {
               temp[k] = temp[k] ^ Rcon[i / Nk];   // Применение операции XOR к каждому элементу
           }
       }
       else if (Nk > 6 && (i % Nk == 4)) { // Условие, которое проверяет, нужно ли применять операцию SubBytes к блоку ключа
           SubBytes(temp);
       }
       for (int j = 0; j < temp.size(); ++j) {
           roundKeys[i][j] = roundKeys[i - Nk][j] ^ temp[j];   // применение операции XOR между предыдущим расширенным ключом и temp для получения нового расширенного ключа
       }
       i++;
   }
}
 
// Функция выполняет обратный сдвиг элементов
void InversionShiftElmnts(vector<unsigned char>& state) {
   vector<unsigned char> temp(state.size());
   for (int i = 0; i < state.size(); i++) { 
       temp[i] = state[(i - (i % 4) * (i % 4)) % state.size()]; // Обратный сдвиг элементов
   }
   state = temp;
}
 
// Функция выполняет обратные операции умножения над столбцами матрицы данных
void InversionMnMatrix(vector<unsigned char>& state) {
   vector<unsigned char> tabl_with_14 = tabl_14();
   vector<unsigned char> tabl_with_9 = tabl_9();
   vector<unsigned char> tabl_with_13 = tabl_13(); 
   vector<unsigned char> tabl_with_11 = tabl_11();
 
   vector<unsigned char> temp; // Хранение результатов операций
   // Вычисление новых значений
   temp.push_back(tabl_with_14[state[0]] ^ tabl_with_9[state[1]] ^ tabl_with_13[state[2]] ^ tabl_with_11[state[3]]);
   temp.push_back(tabl_with_14[state[1]] ^ tabl_with_9[state[2]] ^ tabl_with_13[state[3]] ^ tabl_with_11[state[0]]);
   temp.push_back(tabl_with_14[state[2]] ^ tabl_with_9[state[3]] ^ tabl_with_13[state[0]] ^ tabl_with_11[state[1]]);
   temp.push_back(tabl_with_14[state[3]] ^ tabl_with_9[state[0]] ^ tabl_with_13[state[1]] ^ tabl_with_11[state[2]]);
   state = temp;
}
 
// Функция разбивает входную строку на блоки размером 16 байт
void createBlocks(string& text, vector<vector<vector<unsigned char>>>& block) {
   while (text.size() % 16 != 0) { // Цикл пока размер строки не будет кратен 16
       text += ' ';
   }
 
   vector<vector<vector<unsigned char>>> temporary;    // Временный вектор для хранения блоков
   vector<vector<unsigned char>> sixteen(4, vector<unsigned char>(4)); // Матрица 4x4, в которой будут храниться байты из строки
 
   for (int i = 0; i < text.size(); ++i) {
       int a = (i % 16) % 4;   // Вычисление индексов для текущего символа в матрице
       int b = (i % 16) / 4;
       sixteen[a][b] = text[i];
 
       if ((i + 1) % 16 == 0) {
           temporary.push_back(sixteen);   // Текущий блок (матрица sixteen) добавляется в вектор temporary
           sixteen = vector<vector<unsigned char>>(4, vector<unsigned char>(4));   // Матрица sixteen обнуляется для следующего блока
       }
   }
 
   block = temporary;
}
 
// Функция выполняет шифрование блока данных с использованием ключа и раундовых ключей
vector<vector<unsigned char>> Encrypt(vector<vector<unsigned char>>& block, vector<vector<unsigned char>>& roundKeys, vector<unsigned char> key) {
 
   vector<vector<unsigned char>> temp(4, vector<unsigned char>(4, 0)); // Хранение промежуточных результатов шифрования
   for (int i = 0; i < 4; ++i) {
       temp[i] = AddRoundKey(block[i], roundKeys[i]);   // Начальное добавление раундового ключа к блоку данных
   }
 
   for (int i = 1; i <= 9; i++) { 
       for (int j = 0; j <= 3; j++) {  // Операции шифрования для каждого столбца блока данных
           SubBytes(temp[j]);  // Замена каждого байта в столбце на другой байт
           ShiftElmnts(temp[j]);   // Сдвиг элементов в столбце влево на один байт
           MnMatrix(temp[j]);  // Функция выполняет операции умножения над столбцом в поле Галуа
           temp[j] = AddRoundKey(temp[j], roundKeys[i]);   // Добавляем раундовый ключ к столбцу
       }
   }
 
   for (int j = 0; j <= 3; j++) {
       SubBytes(temp[j]);
       ShiftElmnts(temp[j]);
       temp[j] = AddRoundKey(temp[j], roundKeys[10]);
   }
 
   return temp;
}
 
// Функция выполняет дешифрование блока данных с использованием ключа и раундовых ключей
vector<vector<unsigned char>> Decrypt(vector<vector<unsigned char>>& block, vector<vector<unsigned char>>& roundKeys, vector<unsigned char> key) {  // принимает зашифрованный блок данных, вектор раундовых ключей и ключ, возвращает дешифрованный блок данных
   vector<vector<unsigned char>> roundKeysDec(44, vector<unsigned char>(4));   // вектор размером 44x4 для хранения раундовых ключей после расширения ключа
   KeyExpansion(key, roundKeysDec);    // функция расширяет ключ key и сохраняет расширенные ключи в roundKeysDec
 
   vector<vector<unsigned char>> temporary(4, vector<unsigned char>(4, 0));    // временный вектор размером 4x4, заполненный нулями (для хранения промежуточных результатов дешифрования)
 
   for (int j = 0; j <= 3; j++) {  // цикл выполняет начальное добавление последнего раундового ключа к блоку данных
       temporary[j] = AddRoundKey(block[j], roundKeys[10]);
   }
 
   for (int i = 9; i >= 1; i--) {  // основной цикл дешифрования, который выполняется 9 раз для каждого из 10 раундов в обратном порядке
       for (int j = 0; j <= 3; j++) {  // цикл, где выполняются обратные операции шифрования для каждого столбца блока данных
           temporary[j] = AddRoundKey(temporary[j], roundKeys[i]); // функция добавляет раундовый ключ к столбцу
           InversionMnMatrix(temporary[j]);    // функция выполняет обратные операции умножения над столбцом в поле Галуа
           InversionShiftElmnts(temporary[j]); // функция выполняет обратный сдвиг элементов в столбце
           InversionSubBytes(temporary[j]);    // функция выполняет обратную замену байтов в столбце
       }
   }
 
   for (int j = 0; j <= 3; j++) {  // цикл добавляет первый раундовый ключ к каждому столбцу
       temporary[j] = AddRoundKey(temporary[j], roundKeys[0]);
   }
   for (int j = 0; j <= 3; j++) {  // цикл выполняет обратные операции шифрования для первого раунда
       InversionShiftElmnts(temporary[j]);
       InversionSubBytes(temporary[j]);
   }
 
   return temporary;   // возвращение дешифрованного блока данных
}
 
int main() {
   // system("chcp 1251");
   string text;    // ввод строки текста
   cout << "Input message: ";
   getline(cin, text); // считывает строку текста, включая пробелы, и сохраняет ее в переменную text
 
   // Вывод блоков данных
   vector<vector<vector<unsigned char>>> block;    // трехмерный вектор (массив) внутри которого будут храниться блоки данных (генерация матрицы для работы)
   createBlocks(text, block);  // функция разбивает строку на блоки и сохраняет их в векторе
   cout << "----------------------------------------------";
   cout << "\nThe encryption block: \n";
   for (auto i : block) {  // вложенные циклы, которые проходят по всем элементам вектора и выводят их на экран
       for (auto j : i) {
           for (auto k : j) {
               cout << setw(4) << k << " ";    // вывод каждого байта k с отступом в 4 символа
           }
           cout << endl;
       }
   }
   cout << "\n----------------------------------------------" << endl;
 
   vector<unsigned char> key;  // вектор для записи сгенерированного ключа
   keyGeneration(key);    // функция генерирует ключ и записывает его в вектор
   cout << "128-bit key: ";
   for (auto i : key) {    // цикл проходит по каждому байту в векторе и выводит его на экран
       cout << i;
   }
   cout << "\n----------------------------------------------\n";
 
   vector<vector<unsigned char>> roundKeys;    // Двумерный вектор для записи раундовых ключей
   KeyExpansion(key, roundKeys);   // Расширение ключа
   cout << "Generated round keys: \n";
   for (auto i : roundKeys) {
       for (auto j : i) {
           cout << hex << setw(4) << static_cast<int>(j) << " ";   // Вывод каждого байта в шестнадцатеричном формате
 
       }
       cout << endl;
   }
   cout << "\n----------------------------------------------" << endl;
 
   vector<vector<unsigned char>> PREV(4, vector<unsigned char>(4, 0)); // Двумерный вектор размером 4x4, заполненный нулями
   vector<vector<unsigned char>> DEFOLT = PREV;
   vector<vector<unsigned char>> TEK;  // Двумерный вектор для хранения ключей
   vector<vector<vector<unsigned char>>> ECRYPT;   // Трехмерный вектор для хранения зашифрованных данных
 
   for (int i = 0; i < block.size(); i++) {
       vector<vector<unsigned char>> res(4, vector<unsigned char>(4, 0));  // Для хранения результата XOR-операции
       vector<vector<unsigned char>> B = block[i]; // Переменная для хранения i-го блока из вектора block
       TEK = Encrypt(PREV, roundKeys, key);
 
       for (int i = 0; i < 4; ++i) {   // Проход по каждому элементу
           for (int j = 0; j < 4; ++j) {
               res[i][j] = (TEK[i][j] ^ B[i][j]);  // Выполнение XOR-операцию между ними
 
           }
       }
       ECRYPT.push_back(res);
 
       PREV = TEK;
   }
 
   cout << "The encrypted message: \n" << endl;
   for (auto t : ECRYPT) {
       for (auto i : t) {
           for (auto j : i) {
               cout << setw(4) << j << " ";
           }
           cout << endl;
       }
   }
 
   cout << "\n----------------------------------------------\n";
 
   PREV = DEFOLT;
   vector<vector<vector<unsigned char>>> DECRYPT;  // Трехмерный вектор для расшифрованных данных
 
   for (int i = 0; i < ECRYPT.size(); ++i) {   // Цикл проходит по каждому блоку в векторе, который содержит зашифрованные данные
       vector<vector<unsigned char>> res(4, vector<unsigned char>(4, 0));
       vector<vector<unsigned char>> B = ECRYPT[i];    // Переменная для хранения i-го блока из вектора ECRYPT
       TEK = Encrypt(PREV, roundKeys, key);
 
       for (int i = 0; i < 4; ++i) {
           for (int j = 0; j < 4; ++j) {
               res[i][j] = (B[i][j] ^ TEK[i][j]);  // Выполняем XOR-операцию
           }
       }
       DECRYPT.push_back(res);
       PREV = TEK;
   }
 
   vector<vector<vector<unsigned char>>> DECRYPT_1;
 
   for (int i = 0; i < ECRYPT.size(); ++i) {
       vector<vector<unsigned char>> res(4, vector<unsigned char>(4, 0));  // Двумерный вектор размером 4x4, для хранения результата дешифрования
       vector<vector<unsigned char>> B = ECRYPT[i];    // Переменная для хранения i-го блока из вектора ECRYPT
       TEK = Decrypt(B, roundKeys, key);
 
       for (int i = 0; i < 4; ++i) {
           for (int j = 0; j < 4; ++j) {
               res[i][j] = TEK[i][j];
           }
       }
       DECRYPT_1.push_back(res);
   }
 
   cout << "The decrypted message: \n" << endl;
   for (int i = 0; i < DECRYPT.size(); i++) {
       vector<vector<unsigned char>>& decrypt = DECRYPT[i];    // Ссылка на i-й блок
       for (int j = 0; j < decrypt.size(); j++) {
           for (int k = 0; k < decrypt[j].size(); k++) {
               cout << decrypt[k][j]; 
           }
       }
   }
   cout << "\n----------------------------------------------\n" << endl;
 
   return 0;
}