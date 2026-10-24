--
-- PostgreSQL database dump
--

-- Dumped from database version 16.8 (Ubuntu 16.8-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.8 (Ubuntu 16.8-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Источники инцидентов; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Источники инцидентов" (
    id integer NOT NULL,
    name text NOT NULL,
    source_type_id integer,
    description text
);


ALTER TABLE public."Источники инцидентов" OWNER TO postgres;

--
-- Name: incident_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.incident_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.incident_sources_id_seq OWNER TO postgres;

--
-- Name: incident_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.incident_sources_id_seq OWNED BY public."Источники инцидентов".id;


--
-- Name: Статусы инцидентов; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Статусы инцидентов" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Статусы инцидентов" OWNER TO postgres;

--
-- Name: incident_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.incident_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.incident_statuses_id_seq OWNER TO postgres;

--
-- Name: incident_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.incident_statuses_id_seq OWNED BY public."Статусы инцидентов".id;


--
-- Name: Виды инцидентов; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Виды инцидентов" (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public."Виды инцидентов" OWNER TO postgres;

--
-- Name: incident_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.incident_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.incident_types_id_seq OWNER TO postgres;

--
-- Name: incident_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.incident_types_id_seq OWNED BY public."Виды инцидентов".id;


--
-- Name: Виды источников; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Виды источников" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Виды источников" OWNER TO postgres;

--
-- Name: source_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.source_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.source_types_id_seq OWNER TO postgres;

--
-- Name: source_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.source_types_id_seq OWNED BY public."Виды источников".id;


--
-- Name: Виды уязвимостей; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Виды уязвимостей" (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Виды уязвимостей" OWNER TO postgres;

--
-- Name: Виды уязвимостей_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Виды уязвимостей_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Виды уязвимостей_id_seq" OWNER TO postgres;

--
-- Name: Виды уязвимостей_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Виды уязвимостей_id_seq" OWNED BY public."Виды уязвимостей".id;


--
-- Name: Действия по устранению; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Действия по устранению" (
    id integer NOT NULL,
    incident_id integer NOT NULL,
    description text NOT NULL,
    performed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    result text
);


ALTER TABLE public."Действия по устранению" OWNER TO postgres;

--
-- Name: Действия по устранению_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Действия по устранению_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Действия по устранению_id_seq" OWNER TO postgres;

--
-- Name: Действия по устранению_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Действия по устранению_id_seq" OWNED BY public."Действия по устранению".id;


--
-- Name: Инциденты; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Инциденты" (
    id integer NOT NULL,
    date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type_id integer NOT NULL,
    threat_level_id integer NOT NULL,
    status_id integer NOT NULL,
    description text,
    source_id integer NOT NULL,
    employee_id integer
);


ALTER TABLE public."Инциденты" OWNER TO postgres;

--
-- Name: Инциденты_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Инциденты_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Инциденты_id_seq" OWNER TO postgres;

--
-- Name: Инциденты_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Инциденты_id_seq" OWNED BY public."Инциденты".id;


--
-- Name: Позиции сотрудников; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Позиции сотрудников" (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public."Позиции сотрудников" OWNER TO postgres;

--
-- Name: Позиции сотрудников_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Позиции сотрудников_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Позиции сотрудников_id_seq" OWNER TO postgres;

--
-- Name: Позиции сотрудников_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Позиции сотрудников_id_seq" OWNED BY public."Позиции сотрудников".id;


--
-- Name: Сотрудники; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Сотрудники" (
    id integer NOT NULL,
    full_name text NOT NULL,
    position_id integer,
    phone text,
    email text
);


ALTER TABLE public."Сотрудники" OWNER TO postgres;

--
-- Name: Сотрудники_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Сотрудники_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Сотрудники_id_seq" OWNER TO postgres;

--
-- Name: Сотрудники_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Сотрудники_id_seq" OWNED BY public."Сотрудники".id;


--
-- Name: Уровни угрозы; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Уровни угрозы" (
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL
);


ALTER TABLE public."Уровни угрозы" OWNER TO postgres;

--
-- Name: Уровни уязвимостей; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Уровни уязвимостей" (
    id integer NOT NULL,
    name text NOT NULL,
    min_score numeric(3,1) NOT NULL,
    max_score numeric(3,1) NOT NULL,
    description text
);


ALTER TABLE public."Уровни уязвимостей" OWNER TO postgres;

--
-- Name: Уровни уязвимотей_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Уровни уязвимотей_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Уровни уязвимотей_id_seq" OWNER TO postgres;

--
-- Name: Уровни уязвимотей_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Уровни уязвимотей_id_seq" OWNED BY public."Уровни уязвимостей".id;


--
-- Name: Уязвимости; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Уязвимости" (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    type_id integer,
    level_id integer
);


ALTER TABLE public."Уязвимости" OWNER TO postgres;

--
-- Name: Уязвимости инцидентов; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Уязвимости инцидентов" (
    incident_id integer NOT NULL,
    vulnerability_id integer NOT NULL
);


ALTER TABLE public."Уязвимости инцидентов" OWNER TO postgres;

CREATE TABLE public."Лог предупреждений" (
    id SERIAL PRIMARY KEY,
    incident_id INTEGER NOT NULL,
    warning_message TEXT NOT NULL,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public."Лог предупреждений" OWNER TO postgres;

--
-- Name: Уязвимости_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Уязвимости_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Уязвимости_id_seq" OWNER TO postgres;

--
-- Name: Уязвимости_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Уязвимости_id_seq" OWNED BY public."Уязвимости".id;


--
-- Name: Виды инцидентов id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Виды инцидентов" ALTER COLUMN id SET DEFAULT nextval('public.incident_types_id_seq'::regclass);


--
-- Name: Виды источников id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Виды источников" ALTER COLUMN id SET DEFAULT nextval('public.source_types_id_seq'::regclass);


--
-- Name: Виды уязвимостей id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Виды уязвимостей" ALTER COLUMN id SET DEFAULT nextval('public."Виды уязвимостей_id_seq"'::regclass);


--
-- Name: Действия по устранению id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Действия по устранению" ALTER COLUMN id SET DEFAULT nextval('public."Действия по устранению_id_seq"'::regclass);


--
-- Name: Инциденты id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Инциденты" ALTER COLUMN id SET DEFAULT nextval('public."Инциденты_id_seq"'::regclass);


--
-- Name: Источники инцидентов id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Источники инцидентов" ALTER COLUMN id SET DEFAULT nextval('public.incident_sources_id_seq'::regclass);


--
-- Name: Позиции сотрудников id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Позиции сотрудников" ALTER COLUMN id SET DEFAULT nextval('public."Позиции сотрудников_id_seq"'::regclass);


--
-- Name: Сотрудники id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Сотрудники" ALTER COLUMN id SET DEFAULT nextval('public."Сотрудники_id_seq"'::regclass);


--
-- Name: Статусы инцидентов id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Статусы инцидентов" ALTER COLUMN id SET DEFAULT nextval('public.incident_statuses_id_seq'::regclass);


--
-- Name: Уровни уязвимостей id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Уровни уязвимостей" ALTER COLUMN id SET DEFAULT nextval('public."Уровни уязвимотей_id_seq"'::regclass);


--
-- Name: Уязвимости id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Уязвимости" ALTER COLUMN id SET DEFAULT nextval('public."Уязвимости_id_seq"'::regclass);


--
-- Data for Name: Виды инцидентов; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Виды инцидентов" (id, name, description) FROM stdin;
1	Вредоносное ПО	Обнаружение и заражение систем вредоносными программами
2	Фишинг	Мошеннические письма с целью получить данные пользователя
3	DoS-атака	Атака на отказ в обслуживании
4	Утечка данных	Несанкционированная передача данных за пределы системы
5	Неавторизованный доступ	Получение доступа к системе без разрешения
6	Физическое вмешательство	Физический доступ к оборудованию или системам
7	Социальная инженерия	Манипуляция пользователя с целью получения конфиденциальной информации
\.


--
-- Data for Name: Виды источников; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Виды источников" (id, name) FROM stdin;
1	Пользователь
2	Сервер
3	Приложение
4	Сеть
5	Оборудование
\.


--
-- Data for Name: Виды уязвимостей; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Виды уязвимостей" (id, name) FROM stdin;
1	Программная
2	Сетевая
3	Конфигурационная
4	Физическая
5	Социальная
6	Управленческая
\.


--
-- Data for Name: Действия по устранению; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Действия по устранению" (id, incident_id, description, performed_at, result) FROM stdin;
1	1	Сброшен пароль пользователя	2025-04-12 20:25:00	Доступ восстановлен
2	1	Удалено фишинговое письмо из почты	2025-04-12 20:25:00	Письмо удалено из всех ящиков
3	2	Перезагружен сервер	2025-04-13 10:00:00	Сервер восстановлен
4	4	Исправлена уязвимость Cross-Site Scripting (XSS) в API	2025-04-16 15:00:00	Утечка данных прекращена
5	3	Исправлена уязвимость SQL Injection в приложении	2025-04-15 12:00:00	Проведено обновление кода и очистка зараженной системы
6	5	Проведена проверка системы на наличие других уязвимостей повышения привилегий	2025-04-16 16:30:00	Обнаружены и устранены дополнительные уязвимости
7	6	Установлены новые замки на серверную и организовано видеонаблюдение	2025-04-17 19:00:00	Физический доступ ограничен
8	7	Проведено обучение сотрудников по распознаванию социальной инженерии	2025-04-18 10:00:00	Сотрудники проинформированы о методах защиты
9	8	Удален троян и установлены патчи безопасности на сервер	2025-04-18 14:00:00	Система восстановлена
\.


--
-- Data for Name: Инциденты; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Инциденты" (id, date, type_id, threat_level_id, status_id, description, source_id, employee_id) FROM stdin;
1	2025-04-12 20:20:00	2	2	2	Пользователь Петров получил письмо-фишинг	1	1
2	2025-04-13 09:00:00	3	1	2	DoS-атака на сервер базы данных	3	1
3	2025-04-15 10:00:00	1	3	1	Обнаружен вирус на рабочей станции	1	4
4	2025-04-16 09:15:00	4	2	1	Утечка данных через незащищенный API	4	3
5	2025-04-16 13:45:00	5	3	2	Неавторизованный доступ к серверу	2	1
6	2025-04-17 16:20:00	6	1	3	Физическое повреждение сетевого оборудования	5	5
7	2025-04-18 08:50:00	7	2	1	Социальная инженерия через телефон	1	4
8	2025-04-18 12:10:00	1	3	2	Заражение сервера трояном	2	2
\.


--
-- Data for Name: Источники инцидентов; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Источники инцидентов" (id, name, source_type_id, description) FROM stdin;
1	user-petrov	1	Рабочее место сотрудника Петрова
2	server-db-prod	2	Основной сервер базы данных
3	network-router	4	Маршрутизатор корпоративной сети
4	web-application	3	Корпоративное веб-приложение
5	firewall-device	4	Сетевой экран
6	wifi-router-01	5	Точка доступа Wi-Fi
\.


--
-- Data for Name: Позиции сотрудников; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Позиции сотрудников" (id, name, description) FROM stdin;
1	Специалист ИБ	Обрабатывает и расследует инциденты
2	Инженер ИБ	Разрабатывает и внедряет меры защиты
3	Менеджер ИБ	Координирует работу отдела информационной безопасности
4	Специалист по мониторингу	Отслеживает события в системе
5	Технический специалист	Выполняет техническое обслуживание оборудования
\.


--
-- Data for Name: Сотрудники; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Сотрудники" (id, full_name, position_id, phone, email) FROM stdin;
1	Дональд Краснов	1	+79529123432	krasnov@mail.ru
2	Мария Сидорова	3	+79109876543	sidorova@example.com
3	Александр Иванов	2	+79211234567	ivanov@example.com
4	Евгений Петров	4	+79056789012	petrov@example.com
5	Дмитрий Смирнов	5	+79259876543	smirnov@example.com
\.


--
-- Data for Name: Статусы инцидентов; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Статусы инцидентов" (id, name) FROM stdin;
1	Ожидает обработки
2	В процессе
3	Устранен
\.


--
-- Data for Name: Уровни угрозы; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Уровни угрозы" (id, name, description) FROM stdin;
1	Критический	Критически опасный инцидент с очень большими последствиями
2	Серьезный	Серьезный инцидент со значительными последствиями
3	Незначительный	Несерьезный инцидент с незначительными последствиями
\.


--
-- Data for Name: Уровни уязвимостей; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Уровни уязвимостей" (id, name, min_score, max_score, description) FROM stdin;
1	Критический	9.0	10.0	Может привести к полному захвату системы без необходимости аутентификации или взаимодействия с пользователем.
2	Высокий	7.0	8.9	Может привести к серьезным потерям данных или длительному простою, но требует более сложной эксплуатации.
3	Средний	4.0	6.9	Может потребовать социальной инженерии или наличия у злоумышленника доступа к локальной сети.
4	Низкий	0.1	3.9	Малоопасна, часто требует физического или локального доступа, с минимальным влиянием.
\.


--
-- Data for Name: Уязвимости; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Уязвимости" (id, name, description, type_id, level_id) FROM stdin;
1	SQL Injection	Уязвимость, позволяющая выполнять произвольные SQL-запросы через вводимые данные.	1	1
2	Cross-Site Scripting (XSS)	Внедрение вредоносного скрипта в веб-приложение	1	2
3	Default Credentials	Использование стандартных учетных данных для доступа к системе	6	3
4	Open Network Port	Открытый порт в сети, доступный для внешнего подключения	2	2
5	Man-in-the-Middle (MitM)	Атака по перехвату трафика между двумя сторонами	2	3
6	Privilege Escalation	Повышение привилегий в системе через уязвимость	1	1
7	Denial of Service (DoS)	Атака, направленная на отказ в обслуживании системы	3	3
8	Malicious Attachment	Вредоносное вложение в электронном письме	5	2
9	Social Engineering via Email	Манипуляция пользователя через электронную почту	5	2
10	Unsecured Physical Access	Отсутствие контроля физического доступа к серверной	4	1
11	Unattended Workstations	Рабочие станции остаются без присмотра	4	3
\.


--
-- Data for Name: Уязвимости инцидентов; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Уязвимости инцидентов" (incident_id, vulnerability_id) FROM stdin;
3	1
4	2
5	6
6	10
7	9
8	6
1	8
2	7
\.


--
-- Name: incident_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.incident_sources_id_seq', 3, true);


--
-- Name: incident_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.incident_statuses_id_seq', 3, true);


--
-- Name: incident_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.incident_types_id_seq', 4, true);


--
-- Name: source_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.source_types_id_seq', 4, true);


--
-- Name: Виды уязвимостей_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Виды уязвимостей_id_seq"', 1, false);


--
-- Name: Действия по устранению_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Действия по устранению_id_seq"', 9, true);


--
-- Name: Инциденты_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Инциденты_id_seq"', 10, true);


--
-- Name: Позиции сотрудников_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Позиции сотрудников_id_seq"', 5, true);


--
-- Name: Сотрудники_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Сотрудники_id_seq"', 5, true);


--
-- Name: Уровни уязвимотей_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Уровни уязвимотей_id_seq"', 4, true);


--
-- Name: Уязвимости_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Уязвимости_id_seq"', 11, true);


--
-- Name: Источники инцидентов incident_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Источники инцидентов"
    ADD CONSTRAINT incident_sources_pkey PRIMARY KEY (id);


--
-- Name: Статусы инцидентов incident_statuses_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Статусы инцидентов"
    ADD CONSTRAINT incident_statuses_name_key UNIQUE (name);


--
-- Name: Статусы инцидентов incident_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Статусы инцидентов"
    ADD CONSTRAINT incident_statuses_pkey PRIMARY KEY (id);


--
-- Name: Виды инцидентов incident_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Виды инцидентов"
    ADD CONSTRAINT incident_types_name_key UNIQUE (name);


--
-- Name: Виды инцидентов incident_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Виды инцидентов"
    ADD CONSTRAINT incident_types_pkey PRIMARY KEY (id);


--
-- Name: Виды источников source_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Виды источников"
    ADD CONSTRAINT source_types_name_key UNIQUE (name);


--
-- Name: Виды источников source_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Виды источников"
    ADD CONSTRAINT source_types_pkey PRIMARY KEY (id);


--
-- Name: Уровни угрозы threat_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Уровни угрозы"
    ADD CONSTRAINT threat_levels_pkey PRIMARY KEY (id);


--
-- Name: Виды уязвимостей Виды уязвимостей_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Виды уязвимостей"
    ADD CONSTRAINT "Виды уязвимостей_name_key" UNIQUE (name);


--
-- Name: Виды уязвимостей Виды уязвимостей_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Виды уязвимостей"
    ADD CONSTRAINT "Виды уязвимостей_pkey" PRIMARY KEY (id);


--
-- Name: Действия по устранению Действия по устранению_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Действия по устранению"
    ADD CONSTRAINT "Действия по устранению_pkey" PRIMARY KEY (id);


--
-- Name: Инциденты Инциденты_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Инциденты"
    ADD CONSTRAINT "Инциденты_pkey" PRIMARY KEY (id);


--
-- Name: Позиции сотрудников Позиции сотрудников_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Позиции сотрудников"
    ADD CONSTRAINT "Позиции сотрудников_name_key" UNIQUE (name);


--
-- Name: Позиции сотрудников Позиции сотрудников_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Позиции сотрудников"
    ADD CONSTRAINT "Позиции сотрудников_pkey" PRIMARY KEY (id);


--
-- Name: Сотрудники Сотрудники_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Сотрудники"
    ADD CONSTRAINT "Сотрудники_email_key" UNIQUE (email);


--
-- Name: Сотрудники Сотрудники_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Сотрудники"
    ADD CONSTRAINT "Сотрудники_phone_key" UNIQUE (phone);


--
-- Name: Сотрудники Сотрудники_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Сотрудники"
    ADD CONSTRAINT "Сотрудники_pkey" PRIMARY KEY (id);


--
-- Name: Уровни уязвимостей Уровни уязвимотей_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Уровни уязвимостей"
    ADD CONSTRAINT "Уровни уязвимотей_name_key" UNIQUE (name);


--
-- Name: Уровни уязвимостей Уровни уязвимотей_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Уровни уязвимостей"
    ADD CONSTRAINT "Уровни уязвимотей_pkey" PRIMARY KEY (id);


--
-- Name: Уязвимости инцидентов Уязвимости инцидентов_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Уязвимости инцидентов"
    ADD CONSTRAINT "Уязвимости инцидентов_pkey" PRIMARY KEY (incident_id, vulnerability_id);


--
-- Name: Уязвимости Уязвимости_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Уязвимости"
    ADD CONSTRAINT "Уязвимости_pkey" PRIMARY KEY (id);


--
-- Name: Источники инцидентов incident_sources_source_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Источники инцидентов"
    ADD CONSTRAINT incident_sources_source_type_id_fkey FOREIGN KEY (source_type_id) REFERENCES public."Виды источников"(id);


--
-- Name: Действия по устранению Действия по устранению_incident_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Действия по устранению"
    ADD CONSTRAINT "Действия по устранению_incident_id_fkey" FOREIGN KEY (incident_id) REFERENCES public."Инциденты"(id) ON DELETE CASCADE;


--
-- Name: Инциденты Инциденты_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Инциденты"
    ADD CONSTRAINT "Инциденты_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES public."Сотрудники"(id);


--
-- Name: Инциденты Инциденты_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Инциденты"
    ADD CONSTRAINT "Инциденты_source_id_fkey" FOREIGN KEY (source_id) REFERENCES public."Источники инцидентов"(id);


--
-- Name: Инциденты Инциденты_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Инциденты"
    ADD CONSTRAINT "Инциденты_status_id_fkey" FOREIGN KEY (status_id) REFERENCES public."Статусы инцидентов"(id);


--
-- Name: Инциденты Инциденты_threat_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Инциденты"
    ADD CONSTRAINT "Инциденты_threat_level_id_fkey" FOREIGN KEY (threat_level_id) REFERENCES public."Уровни угрозы"(id);


--
-- Name: Инциденты Инциденты_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Инциденты"
    ADD CONSTRAINT "Инциденты_type_id_fkey" FOREIGN KEY (type_id) REFERENCES public."Виды инцидентов"(id);


--
-- Name: Сотрудники Сотрудники_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Сотрудники"
    ADD CONSTRAINT "Сотрудники_position_id_fkey" FOREIGN KEY (position_id) REFERENCES public."Позиции сотрудников"(id);


--
-- Name: Уязвимости инцидентов Уязвимости инцидентов_incident_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Уязвимости инцидентов"
    ADD CONSTRAINT "Уязвимости инцидентов_incident_id_fkey" FOREIGN KEY (incident_id) REFERENCES public."Инциденты"(id) ON DELETE CASCADE;


--
-- Name: Уязвимости инцидентов Уязвимости инцидентов_vulnerability_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Уязвимости инцидентов"
    ADD CONSTRAINT "Уязвимости инцидентов_vulnerability_id_fkey" FOREIGN KEY (vulnerability_id) REFERENCES public."Уязвимости"(id) ON DELETE CASCADE;


--
-- Name: Уязвимости Уязвимости_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Уязвимости"
    ADD CONSTRAINT "Уязвимости_level_id_fkey" FOREIGN KEY (level_id) REFERENCES public."Уровни уязвимостей"(id);


--
-- Name: Уязвимости Уязвимости_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Уязвимости"
    ADD CONSTRAINT "Уязвимости_type_id_fkey" FOREIGN KEY (type_id) REFERENCES public."Виды уязвимостей"(id);



--
-- Триггеры
--

-- Автоматическая установка даты инцидента, если она не указана при вставке новой записи

CREATE OR REPLACE FUNCTION set_incident_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.date IS NULL THEN
        NEW.date := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_incident_date
BEFORE INSERT ON public."Инциденты"
FOR EACH ROW
EXECUTE FUNCTION set_incident_date();

-- Проверка ссылочной целостности для поля "Уровень угрозы" в таблице "Инциденты", 
-- обеспечивая что указанный уровень угрозы действиятельно существует.

CREATE OR REPLACE FUNCTION validate_threat_level()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public."Уровни угрозы" WHERE id = NEW.threat_level_id) THEN
        RAISE EXCEPTION 'Недопустимый уровень угрозы: %', NEW.с;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_threat_level
BEFORE INSERT OR UPDATE ON public."Инциденты"
FOR EACH ROW
EXECUTE FUNCTION validate_threat_level();

-- Проверка при вставке или обновлении записей в таблице "Инциденты",
-- чтобы убедиться, что поле "источник инцидента" заполнено.

CREATE OR REPLACE FUNCTION check_incident_source()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.source_id IS NULL THEN
        RAISE EXCEPTION 'Источник инцидента обязателен для заполнения';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_incident_source
BEFORE INSERT OR UPDATE ON public."Инциденты"
FOR EACH ROW
EXECUTE FUNCTION check_incident_source();

-- Обновление статуса инцидента на "Устранен", когда для него добавляется или обновляется 
-- действие по устранению с указанным результатом.

CREATE OR REPLACE FUNCTION update_incident_status_after_remediation()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.result IS NOT NULL THEN
        UPDATE public."Инциденты"
        SET status_id = 3 -- "Устранен"
        WHERE id = NEW.incident_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_incident_status_after_remediation
AFTER INSERT OR UPDATE ON public."Действия по устранению"
FOR EACH ROW
EXECUTE FUNCTION update_incident_status_after_remediation();

-- Проверка соблюдение нормативного времени реагирования на инциденты и 
-- создает запись в логе предупреждений при его превышении.

CREATE OR REPLACE FUNCTION check_response_time()
RETURNS TRIGGER AS $$
DECLARE
    response_deadline TIMESTAMP;
BEGIN
    -- Нормативное время реагирования: 24 часа
    response_deadline := NEW.date + INTERVAL '24 hours';

    IF CURRENT_TIMESTAMP > response_deadline AND NEW.status_id != 3 THEN
        INSERT INTO public."Лог предупреждений" (incident_id, warning_message)
        VALUES (NEW.id, 'Превышен нормативный срок реагирования на инцидент');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_response_time
AFTER INSERT OR UPDATE ON public."Инциденты"
FOR EACH ROW
EXECUTE FUNCTION check_response_time();

-- 
-- Функции
--

--- 1  Функция вычисляет среднее время реагирования на инциденты - промежуток между датой возникновения инцидента и датой выполнения действий по его устранению.

CREATE OR REPLACE FUNCTION calculate_average_response_time()
RETURNS INTERVAL AS $$
DECLARE
    avg_response_time INTERVAL;
BEGIN
    SELECT AVG(d.performed_at - i.date) INTO avg_response_time
    FROM public."Действия по устранению" d
    JOIN public."Инциденты" i ON d.incident_id = i.id
    WHERE d.performed_at IS NOT NULL;

    RETURN avg_response_time;
END;
$$ LANGUAGE plpgsql;

SELECT calculate_average_response_time();

--- 2 функция проверяет, указан ли уровень угрозы для конкретного инцидента в системе.

CREATE OR REPLACE FUNCTION check_threat_level_exists(incident_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    threat_level_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM public."Инциденты" i
        WHERE i.id = incident_id AND i.threat_level_id IS NOT NULL
    ) INTO threat_level_exists;

    RETURN threat_level_exists;
END;
$$ LANGUAGE plpgsql;

SELECT check_threat_level_exists(3);

--- 3 функция анализирует статистику инцидентов за указанный период и возвращает самый часто встречающийся тип инцидента.

CREATE OR REPLACE FUNCTION get_most_frequent_incident_type(start_date DATE, end_date DATE)
RETURNS TABLE(type_id INTEGER, type_name TEXT, incident_count BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id AS type_id, t.name AS type_name, COUNT(i.id) AS incident_count
    FROM public."Инциденты" i
    JOIN public."Виды инцидентов" t ON i.type_id = t.id
    WHERE i.date BETWEEN start_date AND end_date
    GROUP BY t.id, t.name
    ORDER BY incident_count DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_most_frequent_incident_type('2025-01-01', '2025-12-31');

--- 4 функция подсчитывает количество инцидентов, зарегистрированных в первые три квартала предыдущего года

CREATE OR REPLACE FUNCTION count_incidents_last_year_q1_q3()
RETURNS BIGINT AS $$
DECLARE
    total_incidents BIGINT;
BEGIN
    SELECT COUNT(*) INTO total_incidents
    FROM public."Инциденты"
    WHERE date >= DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '1 year'
      AND date <= DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '1 year' + INTERVAL '9 months';

    RETURN total_incidents;
END;
$$ LANGUAGE plpgsql;

SELECT count_incidents_last_year_q1_q3();

--- 5 функция возвращает список уязвимостей, которые были связаны с какими-либо инцидентами в системе.

CREATE OR REPLACE FUNCTION get_vulnerabilities_list()
RETURNS TABLE(vulnerability_id INTEGER, vulnerability_name TEXT, description TEXT, level_name TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT v.id AS vulnerability_id, v.name AS vulnerability_name, v.description, l.name AS level_name
    FROM public."Уязвимости" v
    JOIN public."Уровни уязвимостей" l ON v.level_id = l.id
    WHERE EXISTS (
        SELECT 1
        FROM public."Уязвимости инцидентов" vi
        WHERE vi.vulnerability_id = v.id
    );
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_vulnerabilities_list();

-- Запросы

--- 1 запрос анализирует источники инцидентов и выявляет те, которые вызывают больше инцидентов, чем в среднем по всем источникам.

WITH source_counts AS (
    SELECT i.source_id, COUNT(*) AS incident_count
    FROM "Инциденты" i
    GROUP BY i.source_id
)
SELECT s.name, sc.incident_count
FROM source_counts sc
JOIN "Источники инцидентов" s ON sc.source_id = s.id
WHERE sc.incident_count > (
    SELECT AVG(incident_count) FROM source_counts
);

-- 2 запрос вычисляет среднее время устранения инцидентов по каждому типу инцидентов.

SELECT t.name AS type_name, AVG(a.performed_at - i.date) AS avg_resolution_time
FROM "Инциденты" i
JOIN "Действия по устранению" a ON i.id = a.incident_id
JOIN "Виды инцидентов" t ON i.type_id = t.id
GROUP BY t.name;

-- 3 запрос выявляет сотрудников, которые обработали наибольшее количество инцидентов за период с 1 января 2024 года по 31 декабря 2025 года.

SELECT e.full_name AS employee_name, counts.incident_count
FROM (
    SELECT employee_id, COUNT(*) AS incident_count
    FROM "Инциденты"
    WHERE date BETWEEN '2024-01-01' AND '2025-12-31'
    GROUP BY employee_id
) AS counts
JOIN "Сотрудники" e ON counts.employee_id = e.id
WHERE counts.incident_count = (
    SELECT MAX(emp_count)
    FROM (
        SELECT employee_id, COUNT(*) AS emp_count
        FROM "Инциденты"
        WHERE date BETWEEN '2024-01-01' AND '2025-12-31'
        GROUP BY employee_id
    ) AS sub_counts
);

-- 4 запрос анализирует распределение инцидентов по уровням угрозы и выявляет те уровни угрозы, количество инцидентов которых превышает среднемесячное количество инцидентов.

SELECT t.name AS threat_level_name, COUNT(*) AS incident_count
FROM "Инциденты" i
JOIN "Уровни угрозы" t ON i.threat_level_id = t.id
GROUP BY t.name
HAVING COUNT(*) > (
    SELECT AVG(monthly_count)
    FROM (
        SELECT DATE_TRUNC('month', i2.date) AS month, COUNT(*) AS monthly_count
        FROM "Инциденты" i2
        GROUP BY DATE_TRUNC('month', i2.date)
    ) AS monthly_totals
);

-- 5 запрос находит все инциденты, связанные с наиболее часто встречающейся уязвимостью за период с 15 апреля по 31 декабря 2025 года.

SELECT i.*
FROM "Уязвимости инцидентов" iu
JOIN "Инциденты" i ON iu.incident_id = i.id
WHERE i.date BETWEEN '2025-04-15' AND '2025-12-31'
  AND iu.vulnerability_id = (
    SELECT vulnerability_id
    FROM "Уязвимости инцидентов" iu2
    JOIN "Инциденты" i2 ON iu2.incident_id = i2.id
    WHERE i2.date BETWEEN '2025-04-15' AND '2025-12-31'
    GROUP BY vulnerability_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);















--
-- PostgreSQL database dump complete
--

