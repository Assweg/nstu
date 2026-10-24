const fs = require('fs');
const path = require('path');
const { query, pool } = require('./db');

async function importLessons() {
    const lessonsPath = path.join(__dirname, 'data', 'lessons.json');
    const lessons = JSON.parse(fs.readFileSync(lessonsPath, 'utf8'));
    for (const lesson of lessons) {
        await query(
            'INSERT INTO lessons (id, title, description, file) VALUES ($1, $2, $3, $4) ON CONFLICT (id) DO NOTHING',
            [lesson.id, lesson.title, lesson.description, lesson.file]
        );
    }
    console.log('Уроки импортированы.');
}

async function importTests() {
    const testsPath = path.join(__dirname, 'data', 'tests.json');
    const tests = JSON.parse(fs.readFileSync(testsPath, 'utf8'));
    for (const test of tests) {
        // Вставляем тест
        await query(
            'INSERT INTO tests (id, title, description) VALUES ($1, $2, $3)\n             ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description',
            [test.id, test.title, test.description]
        );
        const testId = test.id;
        // Вставляем вопросы
        for (const question of test.questions) {
            const qRes = await query(
                'INSERT INTO questions (test_id, text) VALUES ($1, $2)\n                 ON CONFLICT (test_id, text) DO UPDATE SET text = EXCLUDED.text\n                 RETURNING id',
                [testId, question.text]
            );
            const questionId = qRes.rows[0].id;
            // Вставляем варианты ответов
            for (const option of question.options) {
                await query(
                    'INSERT INTO options (question_id, text, correct) VALUES ($1, $2, $3)\n                     ON CONFLICT (question_id, text) DO UPDATE SET text = EXCLUDED.text, correct = EXCLUDED.correct',
                    [questionId, option.text, option.correct]
                );
            }
        }
    }
    console.log('Тесты импортированы.');
}

async function main() {
    try {
        await importLessons();
        await importTests();
    } catch (err) {
        console.error('Ошибка импорта:', err);
    } finally {
        await pool.end();
        process.exit();
    }
}

main(); 