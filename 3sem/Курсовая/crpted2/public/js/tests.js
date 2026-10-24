document.addEventListener('DOMContentLoaded', async () => {
    try {
        console.log('Загружаем данные о тестах');

        const response = await fetch('/api/tests');
        if (!response.ok) {
            throw new Error(`Ошибка загрузки тестов (${response.status})`);
        }

        const tests = await response.json();
        const testListContainer = document.querySelector('.test-cards-container');

        testListContainer.innerHTML = '';

        tests.forEach(test => {
            const isCompleted = test.completed;

            const testCard = document.createElement('div');
            testCard.classList.add('test-card');

            testCard.innerHTML = `
                <h3>${test.title}</h3>
                <p>${test.description || 'Описание отсутствует'}</p>
                <div class="progress-indicator ${isCompleted ? 'completed' : 'not-completed'}">
                    ${isCompleted ? 'Пройдено' : 'Не пройдено'}
                </div>
                <a href="/test/${test.id}" class="btn">Начать тест</a>
            `;
            testListContainer.appendChild(testCard);
        });
    } catch (err) {
        console.error('Ошибка:', err.message);
        alert('Не удалось загрузить тесты');
    }
});