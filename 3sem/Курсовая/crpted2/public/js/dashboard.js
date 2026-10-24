document.addEventListener('DOMContentLoaded', async () => {
    try {
        console.log('Загружаем данные для Dashboard');
        const response = await fetch('/api/dashboard');
        
        if (!response.ok) {
            throw new Error(`Ошибка загрузки данных (${response.status})`);
        }

        const data = await response.json();
        console.log('Данные для Dashboard:', data);

        // Обновляем основную статистику
        updateBasicStats(data);
        
        // Обновляем списки тестов
        updateTestLists(data);
        
        // Строим график
        renderProgressChart(data);
        
        // Обновляем круговой прогресс
        updateProgressCircle(data);

    } catch (err) {
        console.error('Ошибка:', err.message);
        showErrorNotification('Не удалось загрузить данные для Dashboard');
    }
});

function updateBasicStats(data) {
    document.getElementById('completed-lessons').textContent = data.completedLessons;
    document.getElementById('completed-tests').textContent = data.completedTests;
    document.getElementById('total-lessons').textContent = data.totalLessons;
    document.getElementById('total-tests').textContent = data.totalTests;
}

function updateTestLists(data) {
    const passedTestsList = document.getElementById('passed-tests-list');
    const incompleteTestsList = document.getElementById('incomplete-tests-list');
    
    // Очищаем списки
    passedTestsList.innerHTML = '';
    incompleteTestsList.innerHTML = '';
    
    // Добавляем пройденные тесты
    if (data.passedTests && data.passedTests.length > 0) {
        data.passedTests.forEach(test => {
            passedTestsList.appendChild(createTestItem(test, true));
        });
    } else {
        passedTestsList.innerHTML = '<p class="no-items">Нет пройденных тестов</p>';
    }
    
    // Добавляем незавершенные тесты
    if (data.incompleteTests && data.incompleteTests.length > 0) {
        data.incompleteTests.forEach(test => {
            incompleteTestsList.appendChild(createTestItem(test, false));
        });
    } else {
        incompleteTestsList.innerHTML = '<p class="no-items">Все тесты пройдены!</p>';
    }
}

function createTestItem(test, isCompleted) {
    const item = document.createElement('div');
    item.className = 'test-item';
    
    item.innerHTML = `
        <div class="test-info">
            <h4>${test.title}</h4>
            ${isCompleted ? 
                `<p class="score">Результат: <span>${test.score}/${test.maxScore}</span></p>` : 
                `<p class="status">Не завершен</p>`
            }
        </div>
        <a href="/test/${test.id}" class="btn small">
            ${isCompleted ? 'Повторить' : 'Продолжить'}
        </a>
    `;
    
    return item;
}

function renderProgressChart(data) {
    const ctx = document.getElementById('progressChart').getContext('2d');
    
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['Уроки', 'Тесты'],
            datasets: [{
                label: 'Прогресс',
                data: [
                    (data.completedLessons / data.totalLessons) * 100,
                    (data.completedTests / data.totalTests) * 100
                ],
                backgroundColor: [
                    'rgba(54, 162, 235, 0.7)',
                    'rgba(255, 99, 132, 0.7)'
                ],
                borderColor: [
                    'rgba(54, 162, 235, 1)',
                    'rgba(255, 99, 132, 1)'
                ],
                borderWidth: 1
            }]
        },
        options: {
            scales: {
                y: {
                    beginAtZero: true,
                    max: 100,
                    ticks: {
                        callback: function(value) {
                            return value + '%';
                        }
                    }
                }
            },
            plugins: {
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return context.parsed.y.toFixed(2) + '%';
                        }
                    }
                }
            }
        }
    });
}

function updateProgressCircle(data) {
    const totalProgress = ((data.completedLessons + data.completedTests) / 
                          (data.totalLessons + data.totalTests)) * 100;
    const circle = document.querySelector('.progress-ring-circle');
    const text = document.querySelector('.progress-text');
    
    const radius = 50;
    const circumference = 2 * Math.PI * radius;
    const offset = circumference - (totalProgress / 100) * circumference;
    
    circle.style.strokeDasharray = `${circumference} ${circumference}`;
    circle.style.strokeDashoffset = offset;
    text.textContent = Math.round(totalProgress) + '%';
}

function showErrorNotification(message) {
    const notification = document.createElement('div');
    notification.className = 'notification error';
    notification.innerHTML = `
        <i class="fas fa-exclamation-circle"></i>
        <span>${message}</span>
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 5000);
}