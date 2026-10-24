document.addEventListener('DOMContentLoaded', async () => {
    const pathParts = window.location.pathname.split('/');
    const testId = parseInt(pathParts[pathParts.length - 1]);
    let userAnswers = {};
    let testData = null;
    let currentQuestion = 0;

    if (isNaN(testId)) {
        alert('Неверный ID теста');
        window.location.href = '/tests';
        return;
    }

    try {
        // Загрузка теста
        const response = await fetch(`/api/tests/${testId}`);
        if (!response.ok) throw new Error('Тест не найден');
        testData = await response.json();
        
        document.getElementById('test-title').textContent = testData.title;
        renderQuestion();

        // Навигация
        document.getElementById('prev-question').addEventListener('click', () => {
            if (currentQuestion > 0) {
                currentQuestion--;
                renderQuestion();
            }
        });

        document.getElementById('next-question').addEventListener('click', () => {
            if (currentQuestion < testData.questions.length - 1) {
                currentQuestion++;
                renderQuestion();
            }
        });

        document.getElementById('finish-test').addEventListener('click', finishTest);

    } catch (err) {
        console.error('Ошибка:', err);
        alert('Не удалось загрузить тест');
        window.location.href = '/tests';
    }

    function renderQuestion() {
        const question = testData.questions[currentQuestion];
        const questionContent = document.getElementById('question-content');
        questionContent.innerHTML = '';

        // Вопрос
        const questionEl = document.createElement('div');
        questionEl.className = 'question';
        questionEl.innerHTML = `
            <h3>Вопрос ${currentQuestion + 1}/${testData.questions.length}</h3>
            <p>${question.text}</p>
        `;
        questionContent.appendChild(questionEl);

        // Варианты ответов
        question.options.forEach((option, idx) => {
            const optionEl = document.createElement('div');
            optionEl.className = 'option';
            optionEl.innerHTML = `
                <input type="radio" name="answer" id="opt-${idx}" value="${idx}" 
                    ${userAnswers[currentQuestion] === idx ? 'checked' : ''}>
                <label for="opt-${idx}">${option.text}</label>
            `;
            questionContent.appendChild(optionEl);
        });

        // Кнопка сохранения
        const saveBtn = document.createElement('button');
        saveBtn.className = 'btn save-btn';
        saveBtn.textContent = 'Сохранить ответ';
        saveBtn.addEventListener('click', saveAnswer);
        questionContent.appendChild(saveBtn);

        // Пояснение (если ответ сохранен)
        if (userAnswers[currentQuestion] !== undefined) {
            showExplanation();
        }

        // Обновление навигации
        document.getElementById('prev-question').style.display = 
            currentQuestion === 0 ? 'none' : 'block';
        document.getElementById('next-question').style.display = 
            currentQuestion === testData.questions.length - 1 ? 'none' : 'block';
        document.getElementById('finish-test').style.display = 
            currentQuestion === testData.questions.length - 1 ? 'block' : 'none';
    }

    function saveAnswer() {
        const selected = document.querySelector('input[name="answer"]:checked');
        if (!selected) {
            alert('Выберите вариант ответа!');
            return;
        }

        userAnswers[currentQuestion] = parseInt(selected.value);
        showExplanation();
        alert('Ответ сохранен!');
    }

    function showExplanation() {
        const oldExplanation = document.querySelector('.explanation');
        if (oldExplanation) oldExplanation.remove();

        const question = testData.questions[currentQuestion];
        const userAnswerIdx = userAnswers[currentQuestion];
        
        if (userAnswerIdx === undefined) return;

        const isCorrect = question.options[userAnswerIdx].correct;
        const explanationEl = document.createElement('div');
        explanationEl.className = `explanation ${isCorrect ? 'correct' : 'incorrect'}`;
        explanationEl.innerHTML = `
            <p>Ваш ответ: <strong>${isCorrect ? 'Правильно!' : 'Неправильно!'}</strong></p>
        `;
        
        document.getElementById('question-content').appendChild(explanationEl);
    }

    async function finishTest() {
        const unanswered = testData.questions.length - Object.keys(userAnswers).length;
        if (unanswered > 0 && !confirm(`Вы ответили не на все вопросы (осталось ${unanswered}). Завершить тест?`)) {
            return;
        }

        try {
            const score = calculateScore();
            const response = await fetch('/api/complete-test', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ 
                    testId, 
                    score,
                    total: testData.questions.length 
                })
            });

            if (!response.ok) throw new Error('Ошибка сохранения результатов');

            const result = await response.json();
            alert(`Тест завершен! Ваш результат: ${score}/${testData.questions.length}`);
            window.location.href = '/tests';
        } catch (err) {
            console.error('Ошибка:', err);
            alert('Ошибка при завершении теста');
        }
    }

    function calculateScore() {
        return Object.keys(userAnswers).reduce((score, qIdx) => {
            const answerIdx = userAnswers[qIdx];
            if (testData.questions[qIdx].options[answerIdx].correct) {
                return score + 1;
            }
            return score;
        }, 0);
    }
});