document.addEventListener('DOMContentLoaded', async () => {
    try {
        // Загружаем данные о уроках
        const response = await fetch('/api/lessons');
        if (!response.ok) {
            throw new Error(`Ошибка загрузки уроков (${response.status})`);
        }

        const lessons = await response.json();

        const lessonList = document.getElementById('test-list');
        lessons.forEach(lesson => {
            const isCompleted = lesson.completed;

            const lessonCard = document.createElement('div');
            lessonCard.classList.add('lesson-card');

            lessonCard.innerHTML = `
                <h3>${lesson.title}</h3>
                <p>${lesson.description || 'Описание отсутствует'}</p>
                <div class="progress-indicator ${isCompleted ? '' : 'not-completed'}">
                    ${isCompleted ? 'Пройдено' : 'Не пройдено'}
                </div>
                <a href="/lessons?id=${lesson.id}" class="btn">Начать урок</a>
            `;
            lessonList.appendChild(lessonCard);
        });
    } catch (err) {
        console.error('Ошибка:', err.message);
        alert('Не удалось загрузить уроки');
    }
});