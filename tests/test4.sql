
CREATE TABLE perfil (
    id integer NOT NULL,
    codigo character varying(10),
    ucs character varying(10),
    clima integer,
    pendiente integer,
    erosion integer,
    drenaje integer,
    frag_suelo integer,
    frag_sup integer,
    inundacion character varying(20),
    fertilidad real,
    id_profundidad_efectiva integer,
    id_clase_inundacion integer,
    id_paso_ucs_perfil integer
);


ALTER TABLE public.perfil OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 43063)
-- Dependencies: 4303 4304 4305 8
-- Name: perfil_simple; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE perfil_simple (
    id integer NOT NULL,
    codigo character(10) NOT NULL,
    id_unidad_cartografica integer NOT NULL,
    codigo_nuevo character varying(10) DEFAULT 0 NOT NULL,
    frag_suelo real DEFAULT 0 NOT NULL,
    frag_sup real DEFAULT 0 NOT NULL
);


ALTER TABLE public.perfil_simple OWNER TO postgres;


ALTER TABLE ONLY perfil
    ADD CONSTRAINT perfil_pkey PRIMARY KEY (id);


--
-- TOC entry 4368 (class 2606 OID 44138)
-- Dependencies: 277 277 277 4484
-- Name: perfil_unico_por_unidad_cartografica; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY perfil_simple
    ADD CONSTRAINT perfil_unico_por_unidad_cartografica UNIQUE (codigo, id_unidad_cartografica);

ALTER TABLE ONLY perfil_simple ADD CONSTRAINT any_name UNIQUE (codigo_nuevo);