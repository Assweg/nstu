
-- 
CREATE SEQUENCE public.incident_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--

--
CREATE SEQUENCE public.incident_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--


--
CREATE SEQUENCE public.source_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--


--
CREATE SEQUENCE public."Виды уязвимостей_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--



--
CREATE SEQUENCE public."Действия по устранению_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--

--
CREATE SEQUENCE public."Инциденты_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--


--
CREATE SEQUENCE public."Позиции сотрудников_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--


--
CREATE SEQUENCE public."Сотрудники_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--


--
CREATE SEQUENCE public."Уровни уязвимотей_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--


--
CREATE SEQUENCE public."Уязвимости_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
--

--
ALTER SEQUENCE public."Уязвимости_id_seq" OWNER TO postgres;

ALTER SEQUENCE public."Уязвимости_id_seq" OWNED BY public."Уязвимости".id;
--



--
ALTER TABLE ONLY public."Уязвимости" ALTER COLUMN id SET DEFAULT nextval('public."Уязвимости_id_seq"'::regclass);
--

--
SELECT pg_catalog.setval('public."Уязвимости_id_seq"', 11, true);
--