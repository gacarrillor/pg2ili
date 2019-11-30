--

CREATE TABLE clima (
    id integer NOT NULL,
    nombre character(100) NOT NULL,
    geometria geometry(Point, 3115) NOT NULL
);


ALTER TABLE public.clima OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 43039)
-- Dependencies: 4285 4286 4287 4288 4289 4290 4291 4292 8
-- Name: fase_cartografica; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE fase_cartografica (
    id integer NOT NULL,
    simbolo character(8) NOT NULL,
    id_pendiente integer NOT NULL,
    id_pedregosidad integer DEFAULT 2,
    id_salinidad integer DEFAULT 2,
    id_erosion integer DEFAULT 1,
    id_inundabilidad integer DEFAULT 1,
    id_unidad_cartografica integer NOT NULL,
    frag_sup integer DEFAULT 0 NOT NULL,
    frag_suelo integer DEFAULT 0 NOT NULL,
    capacidad character varying(50) DEFAULT 'ND'::character varying NOT NULL,
    vocacion character varying(50) DEFAULT 'ND'::character varying NOT NULL,
    geom geometry(MultiPolygon,4326)
);


ALTER TABLE public.fase_cartografica OWNER TO postgres;

--
