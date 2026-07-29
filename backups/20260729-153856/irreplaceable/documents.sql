--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4 (Debian 15.4-2.pgdg120+1)
-- Dumped by pg_dump version 15.4 (Debian 15.4-2.pgdg120+1)

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
-- Name: documents; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.documents (
    id integer NOT NULL,
    title text NOT NULL,
    body text NOT NULL
);


ALTER TABLE public.documents OWNER TO aiuser;

--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.documents_id_seq OWNER TO aiuser;

--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.documents (id, title, body) FROM stdin;
1	Sermon 1	Grace and forgiveness.
2	Sermon 2	Hope in difficult times.
3	Announcement	Community dinner on Friday.
\.


--
-- Name: documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.documents_id_seq', 3, true);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

