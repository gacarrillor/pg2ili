CREATE TABLE capacidad (
    id integer NOT NULL,
    id_unidad_cartografica integer NOT NULL,
    id_fase_cartografica integer NOT NULL,
    capacidad character varying(7) NOT NULL,
    descripcion character varying(300) DEFAULT 'pendiente'::character varying NOT NULL
);

ALTER TABLE public.capacidad OWNER TO postgres;

CREATE TABLE fase_cartografica (
    id integer NOT NULL,
    simbolo character(8) NOT NULL,
    id_pendiente integer NOT NULL,
    id_pedregosidad integer DEFAULT 2,
    id_salinidad integer DEFAULT 2,
    id_erosion integer DEFAULT 1,
    id_inundabilidad integer DEFAULT 1,
    id_unidad_cartografica integer,
    frag_sup integer DEFAULT 0 NOT NULL,
    frag_suelo integer DEFAULT 0 NOT NULL,
    capacidad character varying(50) DEFAULT 'ND'::character varying NOT NULL,
    vocacion character varying(50) DEFAULT 'ND'::character varying NOT NULL
);

ALTER TABLE public.fase_cartografica OWNER TO postgres;


CREATE TABLE unidad_cartografica (
    id integer NOT NULL,
    sigla character(15) NOT NULL,
    nombre character varying(100) NOT NULL,
    paisaje character varying(150) NOT NULL,
    mat_parental character varying(150) NOT NULL,
    localizacion character varying(150) NOT NULL,
    id_clima integer NOT NULL,
    fuente character(250),
    simbolo_antiguo character(15),
    simbolo character varying(6) DEFAULT 0 NOT NULL,
    estudio character varying(200)
);

ALTER TABLE public.unidad_cartografica OWNER TO postgres;


ALTER TABLE ONLY capacidad
    ADD CONSTRAINT capacidad_pkey PRIMARY KEY (id);

ALTER TABLE ONLY fase_cartografica
    ADD CONSTRAINT fase_cartografica_pkey PRIMARY KEY (id);

ALTER TABLE ONLY unidad_cartografica
    ADD CONSTRAINT unidad_cartografica_pkey PRIMARY KEY (id);

ALTER TABLE ONLY capacidad
    ADD CONSTRAINT unidad_cartografica_unique UNIQUE (id_unidad_cartografica);

ALTER TABLE ONLY capacidad
    ADD CONSTRAINT capacidad_id_unidad_cartografica_fkey FOREIGN KEY (id_unidad_cartografica) REFERENCES unidad_cartografica(id);

ALTER TABLE ONLY fase_cartografica
    ADD CONSTRAINT fase_cartografica_id_unidad_cartografica_fkey FOREIGN KEY (id_unidad_cartografica) REFERENCES unidad_cartografica(id) ON DELETE CASCADE;