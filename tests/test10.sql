--
-- PostgreSQL database dump
--

-- Dumped from database version 10.9 (Ubuntu 10.9-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.9 (Ubuntu 10.9-0ubuntu0.18.04.1)

-- Started on 2019-12-08 18:47:12 -05

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

SET default_with_oids = false;

--
-- TOC entry 603 (class 1259 OID 314880)
-- Name: a; Type: TABLE; Schema: _m_n_01; Owner: postgres
--

CREATE TABLE _m_n_01.a (
    t_id bigint DEFAULT nextval('_m_n_01.t_ili2db_seq'::regclass) NOT NULL,
    t_ili_tid character varying(200)
);


ALTER TABLE _m_n_01.a OWNER TO postgres;

--
-- TOC entry 605 (class 1259 OID 314892)
-- Name: associationdef89; Type: TABLE; Schema: _m_n_01; Owner: postgres
--

CREATE TABLE _m_n_01.associationdef89 (
    t_id bigint DEFAULT nextval('_m_n_01.t_ili2db_seq'::regclass) NOT NULL,
    t_ili_tid character varying(200),
    abc character varying(25) NOT NULL,
    role_a bigint NOT NULL,
    role_b bigint NOT NULL
);


ALTER TABLE _m_n_01.associationdef89 OWNER TO postgres;

--
-- TOC entry 604 (class 1259 OID 314886)
-- Name: b; Type: TABLE; Schema: _m_n_01; Owner: postgres
--

CREATE TABLE _m_n_01.b (
    t_id bigint DEFAULT nextval('_m_n_01.t_ili2db_seq'::regclass) NOT NULL,
    t_ili_tid character varying(200)
);


ALTER TABLE _m_n_01.b OWNER TO postgres;

--
-- TOC entry 5776 (class 0 OID 314880)
-- Dependencies: 603
-- Data for Name: a; Type: TABLE DATA; Schema: _m_n_01; Owner: postgres
--

COPY _m_n_01.a (t_id, t_ili_tid) FROM stdin;
\.


--
-- TOC entry 5778 (class 0 OID 314892)
-- Dependencies: 605
-- Data for Name: associationdef89; Type: TABLE DATA; Schema: _m_n_01; Owner: postgres
--

COPY _m_n_01.associationdef89 (t_id, t_ili_tid, role_a, role_b) FROM stdin;
\.


--
-- TOC entry 5777 (class 0 OID 314886)
-- Dependencies: 604
-- Data for Name: b; Type: TABLE DATA; Schema: _m_n_01; Owner: postgres
--

COPY _m_n_01.b (t_id, t_ili_tid) FROM stdin;
\.


--
-- TOC entry 5639 (class 2606 OID 314885)
-- Name: a a_pkey; Type: CONSTRAINT; Schema: _m_n_01; Owner: postgres
--

ALTER TABLE ONLY _m_n_01.a
    ADD CONSTRAINT a_pkey PRIMARY KEY (t_id);


--
-- TOC entry 5643 (class 2606 OID 314897)
-- Name: associationdef89 associationdef89_pkey; Type: CONSTRAINT; Schema: _m_n_01; Owner: postgres
--

ALTER TABLE ONLY _m_n_01.associationdef89
    ADD CONSTRAINT associationdef89_pkey PRIMARY KEY (t_id);


--
-- TOC entry 5641 (class 2606 OID 314891)
-- Name: b b_pkey; Type: CONSTRAINT; Schema: _m_n_01; Owner: postgres
--

ALTER TABLE ONLY _m_n_01.b
    ADD CONSTRAINT b_pkey PRIMARY KEY (t_id);


--
-- TOC entry 5644 (class 1259 OID 314898)
-- Name: associationdef89_role_a_idx; Type: INDEX; Schema: _m_n_01; Owner: postgres
--

CREATE INDEX associationdef89_role_a_idx ON _m_n_01.associationdef89 USING btree (role_a);


--
-- TOC entry 5645 (class 1259 OID 314899)
-- Name: associationdef89_role_b_idx; Type: INDEX; Schema: _m_n_01; Owner: postgres
--

CREATE INDEX associationdef89_role_b_idx ON _m_n_01.associationdef89 USING btree (role_b);


--
-- TOC entry 5647 (class 2606 OID 314978)
-- Name: associationdef89 associationdef89_role_a_fkey; Type: FK CONSTRAINT; Schema: _m_n_01; Owner: postgres
--

ALTER TABLE ONLY _m_n_01.associationdef89
    ADD CONSTRAINT associationdef89_role_a_fkey FOREIGN KEY (role_a) REFERENCES _m_n_01.a(t_id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 5646 (class 2606 OID 314983)
-- Name: associationdef89 associationdef89_role_b_fkey; Type: FK CONSTRAINT; Schema: _m_n_01; Owner: postgres
--

ALTER TABLE ONLY _m_n_01.associationdef89
    ADD CONSTRAINT associationdef89_role_b_fkey FOREIGN KEY (role_b) REFERENCES _m_n_01.b(t_id) DEFERRABLE INITIALLY DEFERRED;


-- Completed on 2019-12-08 18:47:12 -05

--
-- PostgreSQL database dump complete
--
