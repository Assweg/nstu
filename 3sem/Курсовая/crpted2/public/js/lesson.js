document.addEventListener('DOMContentLoaded', async () => {
    const params = new URLSearchParams(window.location.search);
    const lessonId = parseInt(params.get('id'));

    if (isNaN(lessonId)) {
        console.error('Неверный ID урока');
        alert('Неверный ID урока');
        return;
    }

    try {
        console.log('Загружаю урок с ID:', lessonId);

        const response = await fetch(`/api/lessons/${lessonId}`);
        if (!response.ok) {
            throw new Error(`Ошибка загрузки урока (${response.status})`);
        }

        const lesson = await response.json();
        document.getElementById('lesson-title').innerText = lesson.title;

        let currentPage = lesson.currentPage || 0;
        const totalPages = lesson.pages.length;

        function renderPage() {
            const pageContent = document.getElementById('page-content');
            pageContent.innerHTML = `<p>${lesson.pages[currentPage].content}</p>`;

            document.getElementById('prev-page').style.display = currentPage === 0 ? 'none' : 'inline-block';
            document.getElementById('next-page').style.display = currentPage === totalPages - 1 ? 'none' : 'inline-block';
            document.getElementById('finish-lesson').style.display = currentPage === totalPages - 1 ? 'inline-block' : 'none';
        }

        renderPage();

        document.getElementById('prev-page').addEventListener('click', async () => {
            if (currentPage > 0) {
                currentPage--;
                renderPage();
                await saveProgress(currentPage);
            }
        });

        document.getElementById('next-page').addEventListener('click', async () => {
            if (currentPage < totalPages - 1) {
                currentPage++;
                renderPage();
                await saveProgress(currentPage);
            }
        });

        document.getElementById('finish-lesson').addEventListener('click', async () => {
            try {
                console.log('Отправляем запрос на завершение урока');
        
                const params = new URLSearchParams(window.location.search);
                const lessonId = parseInt(params.get('id'));
        
                if (isNaN(lessonId)) {
                    console.error('Ошибка: Неверный ID урока');
                    alert('Неверный ID урока');
                    return;
                }
        
                console.log('ID урока:', lessonId);
        
                const response = await fetch('/api/complete-lesson', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ lessonId }),
                });
        
                if (!response.ok) {
                    const errorText = await response.text();
                    console.error(`Ошибка завершения урока (${response.status}):`, errorText);
                    throw new Error(errorText || `Ошибка завершения урока (${response.status})`);
                }
        
                alert('Урок завершен!');
                window.location.href = '/lessons';
            } catch (err) {
                console.error('Ошибка:', err.message);
                alert('Не удалось завершить урок');
            }
        });

        async function saveProgress(page) {
            try {
                await fetch('/api/save-progress', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ lessonId, currentPage: page }),
                });
            } catch (err) {
                console.error('Ошибка сохранения прогресса:', err.message);
            }
        }
    } catch (err) {
        console.error('Ошибка:', err.message);
        alert('Не удалось загрузить урок');
    }
});