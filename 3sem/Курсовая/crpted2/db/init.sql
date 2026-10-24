-- Создание схемы БД
CREATE TABLE IF NOT EXISTS users (
	id SERIAL PRIMARY KEY,
	username TEXT NOT NULL UNIQUE,
	password_hash TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS lessons (
	id INTEGER PRIMARY KEY,
	title TEXT NOT NULL,
	description TEXT,
	file TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS tests (
	id INTEGER PRIMARY KEY,
	title TEXT NOT NULL,
	description TEXT
);

CREATE TABLE IF NOT EXISTS questions (
	id SERIAL PRIMARY KEY,
	test_id INTEGER NOT NULL REFERENCES tests(id) ON DELETE CASCADE,
	text TEXT NOT NULL,
	CONSTRAINT uq_questions_test_text UNIQUE (test_id, text)
);

CREATE TABLE IF NOT EXISTS options (
	id SERIAL PRIMARY KEY,
	question_id INTEGER NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
	text TEXT NOT NULL,
	correct BOOLEAN NOT NULL DEFAULT false,
	CONSTRAINT uq_options_question_text UNIQUE (question_id, text)
);

CREATE TABLE IF NOT EXISTS progress (
	id SERIAL PRIMARY KEY,
	user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
	lesson_id INTEGER REFERENCES lessons(id) ON DELETE CASCADE,
	test_id INTEGER REFERENCES tests(id) ON DELETE CASCADE,
	current_page INTEGER NOT NULL DEFAULT 0,
	score INTEGER,
	completed BOOLEAN NOT NULL DEFAULT false,
	CHECK ((lesson_id IS NOT NULL) <> (test_id IS NOT NULL))
);

-- Уникальные индексы для прогресса
CREATE UNIQUE INDEX IF NOT EXISTS uniq_progress_user_lesson
ON progress (user_id, lesson_id) WHERE lesson_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uniq_progress_user_test
ON progress (user_id, test_id) WHERE test_id IS NOT NULL;
