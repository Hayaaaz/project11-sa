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
-- Name: embeddings; Type: TABLE; Schema: public; Owner: aiuser
--

CREATE TABLE public.embeddings (
    id integer NOT NULL,
    document_id integer,
    embedding public.vector(10)
);


ALTER TABLE public.embeddings OWNER TO aiuser;

--
-- Name: embeddings_id_seq; Type: SEQUENCE; Schema: public; Owner: aiuser
--

CREATE SEQUENCE public.embeddings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.embeddings_id_seq OWNER TO aiuser;

--
-- Name: embeddings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: aiuser
--

ALTER SEQUENCE public.embeddings_id_seq OWNED BY public.embeddings.id;


--
-- Name: embeddings id; Type: DEFAULT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.embeddings ALTER COLUMN id SET DEFAULT nextval('public.embeddings_id_seq'::regclass);


--
-- Data for Name: embeddings; Type: TABLE DATA; Schema: public; Owner: aiuser
--

COPY public.embeddings (id, document_id, embedding) FROM stdin;
1	1	[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1]
2	2	[0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1,0]
3	3	[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]
\.


--
-- Name: embeddings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aiuser
--

SELECT pg_catalog.setval('public.embeddings_id_seq', 3, true);


--
-- Name: embeddings embeddings_pkey; Type: CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.embeddings
    ADD CONSTRAINT embeddings_pkey PRIMARY KEY (id);


--
-- Name: embeddings_hnsw_idx; Type: INDEX; Schema: public; Owner: aiuser
--

CREATE INDEX embeddings_hnsw_idx ON public.embeddings USING hnsw (embedding public.vector_l2_ops);


--
-- Name: embeddings embeddings_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: aiuser
--

ALTER TABLE ONLY public.embeddings
    ADD CONSTRAINT embeddings_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- PostgreSQL database dump complete
--

