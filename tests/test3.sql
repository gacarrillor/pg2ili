create extension postgis;
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.6
-- Dumped by pg_dump version 9.1.6
-- Started on 2019-11-29 15:21:18

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- TOC entry 612 (class 1255 OID 42637)
-- Dependencies: 8
-- Name: comma_cat(text[], text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comma_cat(text[], text) RETURNS text[]
    LANGUAGE sql
    AS $_$
  SELECT
    CASE WHEN $1 @> ARRAY[$2] THEN $1
    ELSE $1 || $2
  END
$_$;


ALTER FUNCTION public.comma_cat(text[], text) OWNER TO postgres;

--
-- TOC entry 626 (class 1255 OID 42638)
-- Dependencies: 8
-- Name: comma_finish(text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION comma_finish(text[]) RETURNS text
    LANGUAGE sql
    AS $_$
    SELECT array_to_string($1, ', ')
$_$;


ALTER FUNCTION public.comma_finish(text[]) OWNER TO postgres;

--
-- TOC entry 2734 (class 1255 OID 42707)
-- Dependencies: 612 626 8
-- Name: list(text); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE list(text) (
    SFUNC = comma_cat,
    STYPE = text[],
    INITCOND = '{NULL, NULL}',
    FINALFUNC = comma_finish
);


ALTER AGGREGATE public.list(text) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 288 (class 1259 OID 43110)
-- Dependencies: 8
-- Name: clima; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE clima (
    id integer NOT NULL,
    nombre character(100) NOT NULL
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
    vocacion character varying(50) DEFAULT 'ND'::character varying NOT NULL
);


ALTER TABLE public.fase_cartografica OWNER TO postgres;

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

--
-- TOC entry 279 (class 1259 OID 43073)
-- Dependencies: 4309 4310 4311 4312 8
-- Name: taxonomia; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE taxonomia (
    id integer NOT NULL,
    p_representacion double precision NOT NULL,
    nombre character varying(70) NOT NULL,
    id_profundidad_efectiva integer DEFAULT 6,
    id_drenaje_natural integer DEFAULT 6,
    id_fertilidad integer DEFAULT 6,
    id_unidad_cartografica integer NOT NULL,
    id_perfil integer NOT NULL,
    id_limitante_profundidad integer DEFAULT 2
);


ALTER TABLE public.taxonomia OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 43080)
-- Dependencies: 4314 8
-- Name: unidad_cartografica; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

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

--
-- TOC entry 323 (class 1259 OID 43219)
-- Dependencies: 4197 8
-- Name: leyenda_ini; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW leyenda_ini AS
    SELECT u.paisaje, c.nombre AS clima, u.mat_parental, t.nombre AS taxonomia, ps.codigo AS perfil, t.p_representacion, u.sigla AS sim_nuevo, u.simbolo_antiguo, t.id AS id_tax, f.id AS id_fase, ps.id AS id_perfil, f.simbolo AS fase, u.localizacion, u.id, u.nombre, u.fuente FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f, clima c WHERE ((((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) GROUP BY u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, u.id_clima, u.fuente, u.simbolo_antiguo, t.id, f.id, ps.id, c.nombre, t.nombre, ps.codigo, t.p_representacion, f.simbolo ORDER BY u.id, t.id, f.id;


ALTER TABLE public.leyenda_ini OWNER TO postgres;

--
-- TOC entry 539 (class 1259 OID 59062)
-- Dependencies: 4263 8
-- Name: leyenda_correlacion; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW leyenda_correlacion AS
    SELECT li.paisaje, li.clima, li.mat_parental, list((li.taxonomia)::text) AS taxonomia, list((li.perfil)::text) AS perfiles, list(to_char(li.p_representacion, '999'::text)) AS porcentajes, btrim((li.sim_nuevo)::text) AS sim_uninidad_nuevo, btrim((li.simbolo_antiguo)::text) AS sim_unidad_estudio, list(to_char(li.id_tax, '9999'::text)) AS ids_taxonomias, list(to_char(li.id_fase, '9999'::text)) AS ids_fases, list(to_char(li.id_perfil, '9999'::text)) AS ids_perfiles, btrim((li.fase)::text) AS fase, (btrim((li.sim_nuevo)::text) || btrim(lower((li.fase)::text))) AS sim_nuevo_comp, (btrim((li.simbolo_antiguo)::text) || btrim((li.fase)::text)) AS sim_antiguo_comp, li.localizacion, li.id, li.nombre, li.fuente FROM leyenda_ini li GROUP BY li.paisaje, li.clima, li.mat_parental, li.sim_nuevo, li.simbolo_antiguo, li.localizacion, li.id, li.nombre, li.fuente, li.fase ORDER BY li.id;


ALTER TABLE public.leyenda_correlacion OWNER TO postgres;

--
-- TOC entry 541 (class 1259 OID 59069)
-- Dependencies: 2568 8
-- Name: amazonas; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE amazonas (
    gid integer NOT NULL,
    ucsuelo character varying(10),
    s_uc character varying(254),
    s_uc_fase character varying(254),
    otras_fa_1 character varying(254),
    pendient_1 character varying(254),
    erosion_1 character varying(254),
    s_clima character varying(254),
    clima_1 character varying(254),
    s_paisaje character varying(254),
    paisaje_gp character varying(254),
    tipo_relie character varying(254),
    material_p character varying(254),
    subgrupo character varying(254),
    perfiles_gp character varying(254),
    porcentaje character varying(254),
    geom geometry(MultiPolygon,4326)
);


ALTER TABLE public.amazonas OWNER TO postgres;

--
-- TOC entry 540 (class 1259 OID 59067)
-- Dependencies: 541 8
-- Name: amazonas_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE amazonas_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.amazonas_gid_seq OWNER TO postgres;

--
-- TOC entry 4489 (class 0 OID 0)
-- Dependencies: 540
-- Name: amazonas_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE amazonas_gid_seq OWNED BY amazonas.gid;


--
-- TOC entry 272 (class 1259 OID 43032)
-- Dependencies: 8
-- Name: aptitud; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE aptitud (
    id_fase integer,
    sim_nuevo character(15),
    sim_anti character(15),
    fase character(8),
    id_cultivo integer,
    nombre character varying(58),
    tipo character varying(21),
    localizacion character varying(150)
);


ALTER TABLE public.aptitud OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 43035)
-- Dependencies: 4283 8
-- Name: drenaje_natural; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE drenaje_natural (
    id integer NOT NULL,
    codigo integer NOT NULL,
    descripcion character(50) NOT NULL,
    drenaje_vocacion integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.drenaje_natural OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 43050)
-- Dependencies: 4294 4295 4296 4297 4298 4299 8
-- Name: horizonte; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE horizonte (
    id integer NOT NULL,
    nombre character(8) NOT NULL,
    id_perfil integer NOT NULL,
    id_textura integer DEFAULT 6,
    id_estructura integer DEFAULT 1,
    id_color integer,
    ph double precision,
    cic double precision,
    bt double precision,
    sb double precision,
    co double precision DEFAULT 1,
    nt double precision,
    pp double precision,
    kc double precision,
    ce double precision DEFAULT 2,
    profundidad_inicial integer NOT NULL,
    profundidad_final integer NOT NULL,
    sat_al double precision DEFAULT 10,
    id_unidad_cartografica integer NOT NULL,
    nombre_corregido character varying(8),
    sat_sodio real DEFAULT 1
);


ALTER TABLE public.horizonte OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 43059)
-- Dependencies: 4301 8
-- Name: pendiente; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE pendiente (
    id integer NOT NULL,
    letra character(1) NOT NULL,
    lim_inf integer NOT NULL,
    lim_sup integer NOT NULL,
    descripcion character(10) NOT NULL,
    valor_medio integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.pendiente OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 43069)
-- Dependencies: 4307 8
-- Name: profundidad_efectiva; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE profundidad_efectiva (
    id integer NOT NULL,
    codigo integer NOT NULL,
    descripcion character(50) NOT NULL,
    valor_medio integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.profundidad_efectiva OWNER TO postgres;

--
-- TOC entry 282 (class 1259 OID 43092)
-- Dependencies: 4192 8
-- Name: aptitud_textura; Type: VIEW; Schema: public; Owner: postgres
--

--CREATE VIEW aptitud_textura AS
--    SELECT ap.id_fase, ap.id_ucs, ap.id_perfil, min(ap.id_horizonte) AS min_horizonte FROM vocacion.apt_datos2 ap GROUP BY ap.id_fase, ap.id_ucs, ap.id_perfil ORDER BY ap.id_fase, ap.id_ucs, ap.id_perfil;


--ALTER TABLE public.aptitud_textura OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 43096)
-- Dependencies: 4316 8
-- Name: capacidad; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE capacidad (
    id integer NOT NULL,
    id_unidad_cartografica integer NOT NULL,
    id_fase_cartografica integer NOT NULL,
    capacidad character varying(7) NOT NULL,
    descripcion character varying(300) DEFAULT 'pendiente'::character varying NOT NULL
);


ALTER TABLE public.capacidad OWNER TO postgres;

--
-- TOC entry 284 (class 1259 OID 43100)
-- Dependencies: 283 8
-- Name: capacidad_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE capacidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.capacidad_id_seq OWNER TO postgres;

--
-- TOC entry 4490 (class 0 OID 0)
-- Dependencies: 284
-- Name: capacidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE capacidad_id_seq OWNED BY capacidad.id;


--
-- TOC entry 285 (class 1259 OID 43102)
-- Dependencies: 8
-- Name: cartografia; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE cartografia (
    depto character varying(40) NOT NULL,
    sim_anti character varying(8) NOT NULL,
    capacidad character varying(15) NOT NULL,
    c_sim_anti character varying(20),
    c_s_nuevo character varying(15),
    depto_dos character varying(30)
);


ALTER TABLE public.cartografia OWNER TO postgres;

--
-- TOC entry 286 (class 1259 OID 43105)
-- Dependencies: 8
-- Name: clase_agrologica; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE clase_agrologica (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL
);


ALTER TABLE public.clase_agrologica OWNER TO postgres;

--
-- TOC entry 287 (class 1259 OID 43108)
-- Dependencies: 286 8
-- Name: clase_agrologica_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE clase_agrologica_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clase_agrologica_id_seq OWNER TO postgres;

--
-- TOC entry 4491 (class 0 OID 0)
-- Dependencies: 287
-- Name: clase_agrologica_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE clase_agrologica_id_seq OWNED BY clase_agrologica.id;


--
-- TOC entry 289 (class 1259 OID 43113)
-- Dependencies: 288 8
-- Name: clima_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE clima_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clima_id_seq OWNER TO postgres;

--
-- TOC entry 4492 (class 0 OID 0)
-- Dependencies: 289
-- Name: clima_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE clima_id_seq OWNED BY clima.id;


--
-- TOC entry 290 (class 1259 OID 43115)
-- Dependencies: 8
-- Name: color; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE color (
    id integer NOT NULL,
    cod_munsel character(15) NOT NULL,
    nombre character(50) NOT NULL
);


ALTER TABLE public.color OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 43118)
-- Dependencies: 8 290
-- Name: color_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE color_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.color_id_seq OWNER TO postgres;

--
-- TOC entry 4493 (class 0 OID 0)
-- Dependencies: 291
-- Name: color_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE color_id_seq OWNED BY color.id;


--
-- TOC entry 292 (class 1259 OID 43120)
-- Dependencies: 4321 8
-- Name: erosion; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE erosion (
    id integer NOT NULL,
    codigo integer NOT NULL,
    descripcion character(12) NOT NULL,
    codigo_vocacion integer DEFAULT 1
);


ALTER TABLE public.erosion OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 43124)
-- Dependencies: 4323 4324 8
-- Name: fertilidad; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE fertilidad (
    id integer NOT NULL,
    codigo integer NOT NULL,
    descripcion character(50) NOT NULL,
    lim_sup real DEFAULT 0 NOT NULL,
    valor_medio real DEFAULT 0 NOT NULL
);


ALTER TABLE public.fertilidad OWNER TO postgres;

--
-- TOC entry 294 (class 1259 OID 43129)
-- Dependencies: 8
-- Name: inundabilidad; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE inundabilidad (
    id integer NOT NULL,
    codigo character(1) NOT NULL,
    explicacion character(40) NOT NULL,
    clases character(40) NOT NULL
);


ALTER TABLE public.inundabilidad OWNER TO postgres;

--
-- TOC entry 295 (class 1259 OID 43132)
-- Dependencies: 8
-- Name: textura; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE textura (
    id integer NOT NULL,
    simbolo character(4) NOT NULL,
    descripcion character(30) NOT NULL
);


ALTER TABLE public.textura OWNER TO postgres;

--
-- TOC entry 296 (class 1259 OID 43135)
-- Dependencies: 4193 8
-- Name: datos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW datos AS
    SELECT h.id_perfil, f.id AS id_fase, u.id AS id_leyenda, h.id AS id_horizonte, c.id AS clima, h.nombre AS simbolo, tx.simbolo AS textura, h.sat_al, h.sat_sodio, h.ce, h.co AS carbono, p.codigo AS perfil, pd.valor_medio AS pendiente, e.codigo_vocacion AS erosion, d.drenaje_vocacion AS drenaje, p.frag_suelo, p.frag_sup, i.clases AS inundacion, ft.valor_medio AS fertilidad, pe.valor_medio AS profundidad, h.profundidad_inicial AS prof_inicial, h.profundidad_final AS prof_final, u.localizacion, u.sigla FROM horizonte h, fase_cartografica f, unidad_cartografica u, clima c, textura tx, pendiente pd, erosion e, perfil_simple p, drenaje_natural d, taxonomia t, inundabilidad i, fertilidad ft, profundidad_efectiva pe WHERE (((((((((((((((h.id_perfil = p.id) AND (h.id_unidad_cartografica = u.id)) AND (c.id = u.id_clima)) AND (h.id_textura = tx.id)) AND (pd.id = f.id_pendiente)) AND (e.id = f.id_erosion)) AND (f.id_unidad_cartografica = u.id)) AND (p.id_unidad_cartografica = u.id)) AND (d.id = t.id_drenaje_natural)) AND (t.id_unidad_cartografica = u.id)) AND (t.id_perfil = p.id)) AND (f.id_inundabilidad = i.id)) AND (ft.id = t.id_fertilidad)) AND (pe.id = t.id_profundidad_efectiva)) AND ((u.estudio)::text ~~ 'semidetallado guajira'::text)) GROUP BY h.id_perfil, f.id, u.id, h.id, c.id, h.nombre, tx.simbolo, h.sat_al, h.sat_sodio, h.ce, h.co, p.codigo, pd.valor_medio, e.codigo_vocacion, d.drenaje_vocacion, p.frag_suelo, p.frag_sup, i.clases, ft.valor_medio, pe.valor_medio, h.profundidad_inicial, h.profundidad_final, u.localizacion, u.sigla;


ALTER TABLE public.datos OWNER TO postgres;

--
-- TOC entry 297 (class 1259 OID 43140)
-- Dependencies: 8
-- Name: descripcion_observacion; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE descripcion_observacion (
    id integer NOT NULL,
    dia integer NOT NULL,
    mes integer NOT NULL,
    anio integer NOT NULL,
    tipo_observacion integer NOT NULL,
    numero_observacion character varying(10) NOT NULL,
    id_descriptor integer NOT NULL,
    sitio character varying(100),
    altitud integer NOT NULL,
    aerofotografia character varying(100) NOT NULL,
    faja character varying(100),
    id_paisaje integer NOT NULL,
    id_tipo_relieve integer NOT NULL,
    id_f_terreno integer NOT NULL,
    id_mat_parental integer NOT NULL,
    relieve character varying(100) NOT NULL,
    diseccion character varying(100) NOT NULL,
    microrelieve character varying(100) NOT NULL,
    gradiente_pendiente character varying(100) NOT NULL,
    longitud_pendiente character varying(100) NOT NULL,
    forma_pendiente character varying(100) NOT NULL,
    id_clima integer NOT NULL,
    formacion_ecologica character varying(100) NOT NULL,
    regimen_temperatura character varying(100) NOT NULL,
    regimen_humedad character varying(100) NOT NULL,
    clase_erosion character varying(100),
    tipo_erosion character varying(100),
    grado_frecuencia_erosion character varying(100),
    evidencia_erosion character varying(100),
    clase_afloramiento_rocoso character varying(100),
    p_superficie_cubierta integer,
    drenaje_interno integer,
    drenaje_externo integer,
    drenaje_natural integer,
    id_unidad_cartografica_medicion integer NOT NULL,
    taxonomia character varying(100) NOT NULL,
    h_superficial character varying(100),
    h_subsuperficial character varying(100),
    otras_caracteristicas character varying(255),
    id_inundacion integer NOT NULL,
    duracion_inundacion character varying(100),
    id_encharcamiento integer NOT NULL,
    duracion_encharcamiento character varying(100),
    naturaleza_nivel_freatico character(100),
    profundidad integer,
    id_profundidad_efectiva integer NOT NULL,
    id_limitante_profundidad_efectiva integer NOT NULL,
    factor_limitante_profundidad character varying(100),
    vegetacion_natural character varying(100),
    uso_actual character varying(100),
    limitante_uso character varying(100),
    nombre_cultivos_pastos character varying(255),
    id_clase_agrologica character varying NOT NULL,
    id_subclase_agrologica character varying NOT NULL,
    ancho_gritas integer,
    profundidad_gritas integer,
    volumen_plintita integer,
    fase_plintita integer,
    evidencias_sales character varying(255),
    observaciones character varying(255),
    id_tipo_observacion integer NOT NULL,
    aux character varying(255)
);


ALTER TABLE public.descripcion_observacion OWNER TO postgres;

--
-- TOC entry 298 (class 1259 OID 43146)
-- Dependencies: 297 8
-- Name: descripcion_observacion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE descripcion_observacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.descripcion_observacion_id_seq OWNER TO postgres;

--
-- TOC entry 4494 (class 0 OID 0)
-- Dependencies: 298
-- Name: descripcion_observacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE descripcion_observacion_id_seq OWNED BY descripcion_observacion.id;


--
-- TOC entry 299 (class 1259 OID 43148)
-- Dependencies: 8
-- Name: descripcion_perfil; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE descripcion_perfil (
    id integer NOT NULL,
    perfil character varying(10) NOT NULL,
    descripcion text NOT NULL,
    fertilidad real
);


ALTER TABLE public.descripcion_perfil OWNER TO postgres;

--
-- TOC entry 300 (class 1259 OID 43154)
-- Dependencies: 299 8
-- Name: descripcion_perfil_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE descripcion_perfil_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.descripcion_perfil_id_seq OWNER TO postgres;

--
-- TOC entry 4495 (class 0 OID 0)
-- Dependencies: 300
-- Name: descripcion_perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE descripcion_perfil_id_seq OWNED BY descripcion_perfil.id;


--
-- TOC entry 301 (class 1259 OID 43156)
-- Dependencies: 8
-- Name: descriptor; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE descriptor (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL,
    otra_info character varying(255)
);


ALTER TABLE public.descriptor OWNER TO postgres;

--
-- TOC entry 302 (class 1259 OID 43159)
-- Dependencies: 301 8
-- Name: descriptor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE descriptor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.descriptor_id_seq OWNER TO postgres;

--
-- TOC entry 4496 (class 0 OID 0)
-- Dependencies: 302
-- Name: descriptor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE descriptor_id_seq OWNED BY descriptor.id;


--
-- TOC entry 303 (class 1259 OID 43161)
-- Dependencies: 8 273
-- Name: drenaje_natural_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE drenaje_natural_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.drenaje_natural_id_seq OWNER TO postgres;

--
-- TOC entry 4497 (class 0 OID 0)
-- Dependencies: 303
-- Name: drenaje_natural_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE drenaje_natural_id_seq OWNED BY drenaje_natural.id;


--
-- TOC entry 304 (class 1259 OID 43163)
-- Dependencies: 8
-- Name: encharcamiento; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE encharcamiento (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL
);


ALTER TABLE public.encharcamiento OWNER TO postgres;

--
-- TOC entry 305 (class 1259 OID 43166)
-- Dependencies: 8 304
-- Name: encharcamiento_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE encharcamiento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.encharcamiento_id_seq OWNER TO postgres;

--
-- TOC entry 4498 (class 0 OID 0)
-- Dependencies: 305
-- Name: encharcamiento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE encharcamiento_id_seq OWNED BY encharcamiento.id;


--
-- TOC entry 306 (class 1259 OID 43168)
-- Dependencies: 8 292
-- Name: erosion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE erosion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.erosion_id_seq OWNER TO postgres;

--
-- TOC entry 4499 (class 0 OID 0)
-- Dependencies: 306
-- Name: erosion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE erosion_id_seq OWNED BY erosion.id;


--
-- TOC entry 307 (class 1259 OID 43170)
-- Dependencies: 8
-- Name: estructura; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE estructura (
    id integer NOT NULL,
    codigo integer NOT NULL,
    descripcion character(100) NOT NULL
);


ALTER TABLE public.estructura OWNER TO postgres;

--
-- TOC entry 308 (class 1259 OID 43173)
-- Dependencies: 307 8
-- Name: estructura_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE estructura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.estructura_id_seq OWNER TO postgres;

--
-- TOC entry 4500 (class 0 OID 0)
-- Dependencies: 308
-- Name: estructura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE estructura_id_seq OWNED BY estructura.id;


--
-- TOC entry 309 (class 1259 OID 43175)
-- Dependencies: 8 274
-- Name: fase_cartografica_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE fase_cartografica_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fase_cartografica_id_seq OWNER TO postgres;

--
-- TOC entry 4501 (class 0 OID 0)
-- Dependencies: 309
-- Name: fase_cartografica_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE fase_cartografica_id_seq OWNED BY fase_cartografica.id;


--
-- TOC entry 310 (class 1259 OID 43177)
-- Dependencies: 293 8
-- Name: fertilidad_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE fertilidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fertilidad_id_seq OWNER TO postgres;

--
-- TOC entry 4502 (class 0 OID 0)
-- Dependencies: 310
-- Name: fertilidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE fertilidad_id_seq OWNED BY fertilidad.id;


--
-- TOC entry 311 (class 1259 OID 43179)
-- Dependencies: 8
-- Name: forma_terreno; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE forma_terreno (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL
);


ALTER TABLE public.forma_terreno OWNER TO postgres;

--
-- TOC entry 312 (class 1259 OID 43182)
-- Dependencies: 8 311
-- Name: forma_terreno_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE forma_terreno_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.forma_terreno_id_seq OWNER TO postgres;

--
-- TOC entry 4503 (class 0 OID 0)
-- Dependencies: 312
-- Name: forma_terreno_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE forma_terreno_id_seq OWNED BY forma_terreno.id;


--
-- TOC entry 313 (class 1259 OID 43184)
-- Dependencies: 8
-- Name: fuente; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE fuente (
    id integer NOT NULL,
    descripcion character(255) NOT NULL,
    fecha date NOT NULL
);


ALTER TABLE public.fuente OWNER TO postgres;

--
-- TOC entry 314 (class 1259 OID 43187)
-- Dependencies: 8 313
-- Name: fuente_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE fuente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fuente_id_seq OWNER TO postgres;

--
-- TOC entry 4504 (class 0 OID 0)
-- Dependencies: 314
-- Name: fuente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE fuente_id_seq OWNED BY fuente.id;


--
-- TOC entry 542 (class 1259 OID 59149)
-- Dependencies: 4264 8 2568
-- Name: g_correlacion_geopedologia; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW g_correlacion_geopedologia AS
    SELECT a.gid, a.ucsuelo, a.s_uc, a.s_uc_fase, a.otras_fa_1, a.pendient_1, a.erosion_1, a.s_clima, a.clima_1, a.s_paisaje, a.paisaje_gp, a.tipo_relie, a.material_p, a.subgrupo, a.perfiles_gp, a.porcentaje, a.geom, l.paisaje, l.clima, l.mat_parental, l.taxonomia, l.perfiles, l.porcentajes, l.sim_uninidad_nuevo, l.sim_unidad_estudio, l.ids_taxonomias, l.ids_fases, l.ids_perfiles, l.fase, l.sim_nuevo_comp, l.sim_antiguo_comp, l.localizacion, l.id, l.nombre, l.fuente FROM amazonas a, leyenda_correlacion l WHERE ((a.s_uc_fase)::text = l.sim_nuevo_comp);


ALTER TABLE public.g_correlacion_geopedologia OWNER TO postgres;

--
-- TOC entry 544 (class 1259 OID 59170)
-- Dependencies: 4266 8 2568
-- Name: g_correlacion_geopedologia_amazonas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW g_correlacion_geopedologia_amazonas AS
    SELECT a.gid, a.ucsuelo, a.s_uc, a.s_uc_fase, a.otras_fa_1, a.pendient_1, a.erosion_1, a.s_clima, a.clima_1, a.s_paisaje, a.paisaje_gp, a.tipo_relie, a.material_p, a.subgrupo, a.perfiles_gp, a.porcentaje, a.geom, l.paisaje, l.clima, l.mat_parental, l.taxonomia, l.perfiles, l.porcentajes, l.sim_uninidad_nuevo, l.sim_unidad_estudio, l.ids_taxonomias, l.ids_fases, l.ids_perfiles, l.fase, l.sim_nuevo_comp, l.sim_antiguo_comp, l.localizacion, l.id, l.nombre, l.fuente FROM amazonas a, leyenda_correlacion l WHERE ((a.s_uc_fase)::text = l.sim_nuevo_comp);


ALTER TABLE public.g_correlacion_geopedologia_amazonas OWNER TO postgres;

--
-- TOC entry 543 (class 1259 OID 59159)
-- Dependencies: 4265 8 2568
-- Name: g_no_encontrados_amazonas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW g_no_encontrados_amazonas AS
    SELECT a.gid, a.ucsuelo, a.s_uc, a.s_uc_fase, a.otras_fa_1, a.pendient_1, a.erosion_1, a.s_clima, a.clima_1, a.s_paisaje, a.paisaje_gp, a.tipo_relie, a.material_p, a.subgrupo, a.perfiles_gp, a.porcentaje, a.geom FROM amazonas a WHERE (NOT ((a.s_uc_fase)::text IN (SELECT l.sim_nuevo_comp FROM leyenda_correlacion l)));


ALTER TABLE public.g_no_encontrados_amazonas OWNER TO postgres;

--
-- TOC entry 546 (class 1259 OID 60436)
-- Dependencies: 8 2568
-- Name: gp_antioquia; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE gp_antioquia (
    gid integer NOT NULL,
    ucsuelo character varying(10),
    s_uc character varying(254),
    s_uc_fase character varying(254),
    otras_fa_1 character varying(254),
    pendient_1 character varying(254),
    erosion_1 character varying(254),
    s_clima character varying(254),
    clima_1 character varying(254),
    s_paisaje character varying(254),
    paisaje character varying(254),
    tipo_relie character varying(254),
    material_p character varying(254),
    subgrupo character varying(254),
    perfiles character varying(254),
    porcentaje character varying(254),
    geom geometry(MultiPolygon,4326)
);


ALTER TABLE public.gp_antioquia OWNER TO postgres;

--
-- TOC entry 545 (class 1259 OID 60434)
-- Dependencies: 546 8
-- Name: gp_antioquia_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE gp_antioquia_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gp_antioquia_gid_seq OWNER TO postgres;

--
-- TOC entry 4505 (class 0 OID 0)
-- Dependencies: 545
-- Name: gp_antioquia_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE gp_antioquia_gid_seq OWNED BY gp_antioquia.gid;


--
-- TOC entry 315 (class 1259 OID 43195)
-- Dependencies: 4194 8
-- Name: horizonte03; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW horizonte03 AS
    SELECT horizonte.id, perfil_simple.codigo AS nombre, horizonte.nombre AS simbolo, textura.descripcion AS textura, horizonte.sat_al, horizonte.co AS carbono, horizonte.cic AS cica, horizonte.sb AS sba, horizonte.profundidad_inicial, horizonte.profundidad_final, horizonte.ce, horizonte.id_perfil FROM horizonte, perfil_simple, textura WHERE ((horizonte.id_perfil = perfil_simple.id) AND (horizonte.id_textura = textura.id)) ORDER BY horizonte.id;


ALTER TABLE public.horizonte03 OWNER TO postgres;

--
-- TOC entry 316 (class 1259 OID 43199)
-- Dependencies: 4195 8
-- Name: horizonte04; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW horizonte04 AS
    SELECT horizonte.id, perfil_simple.codigo AS nombre, horizonte.nombre AS simbolo, textura.descripcion AS textura, horizonte.sat_al, horizonte.co AS carbono, horizonte.cic AS cica, horizonte.sb AS sba, horizonte.profundidad_inicial, horizonte.profundidad_final, horizonte.ce, horizonte.id_perfil, horizonte.ph FROM horizonte, perfil_simple, textura WHERE ((horizonte.id_perfil = perfil_simple.id) AND (horizonte.id_textura = textura.id)) ORDER BY horizonte.id;


ALTER TABLE public.horizonte04 OWNER TO postgres;

--
-- TOC entry 317 (class 1259 OID 43203)
-- Dependencies: 8 275
-- Name: horizonte_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE horizonte_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.horizonte_id_seq OWNER TO postgres;

--
-- TOC entry 4506 (class 0 OID 0)
-- Dependencies: 317
-- Name: horizonte_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE horizonte_id_seq OWNED BY horizonte.id;


--
-- TOC entry 318 (class 1259 OID 43205)
-- Dependencies: 294 8
-- Name: inundabilidad_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inundabilidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inundabilidad_id_seq OWNER TO postgres;

--
-- TOC entry 4507 (class 0 OID 0)
-- Dependencies: 318
-- Name: inundabilidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inundabilidad_id_seq OWNED BY inundabilidad.id;


--
-- TOC entry 319 (class 1259 OID 43207)
-- Dependencies: 8
-- Name: inundacion; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE inundacion (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL
);


ALTER TABLE public.inundacion OWNER TO postgres;

--
-- TOC entry 320 (class 1259 OID 43210)
-- Dependencies: 8 319
-- Name: inundacion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inundacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inundacion_id_seq OWNER TO postgres;

--
-- TOC entry 4508 (class 0 OID 0)
-- Dependencies: 320
-- Name: inundacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inundacion_id_seq OWNED BY inundacion.id;


--
-- TOC entry 321 (class 1259 OID 43212)
-- Dependencies: 8
-- Name: letra_horizonte; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE letra_horizonte (
    id integer NOT NULL,
    letra character varying(3) NOT NULL
);


ALTER TABLE public.letra_horizonte OWNER TO postgres;

--
-- TOC entry 322 (class 1259 OID 43215)
-- Dependencies: 4196 8
-- Name: leyenda; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW leyenda AS
    SELECT u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, u.id_clima, u.fuente, u.simbolo_antiguo, t.nombre AS taxonomia FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f WHERE (((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) ORDER BY u.id;


ALTER TABLE public.leyenda OWNER TO postgres;

--
-- TOC entry 324 (class 1259 OID 43224)
-- Dependencies: 4198 8
-- Name: leyenda_final; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW leyenda_final AS
    SELECT li.paisaje, li.clima, li.mat_parental, list((li.taxonomia)::text) AS taxonomia, list((li.perfil)::text) AS perfiles, list(to_char(li.p_representacion, '999'::text)) AS porcentajes, li.sim_nuevo, li.simbolo_antiguo, list(to_char(li.id_tax, '9999'::text)) AS ids_taxonomias, list(to_char(li.id_fase, '9999'::text)) AS ids_fases, list(to_char(li.id_perfil, '9999'::text)) AS ids_perfiles, list((li.fase)::text) AS fases, li.localizacion, li.id, li.nombre, li.fuente FROM leyenda_ini li GROUP BY li.paisaje, li.clima, li.mat_parental, li.sim_nuevo, li.simbolo_antiguo, li.localizacion, li.id, li.nombre, li.fuente ORDER BY li.id;


ALTER TABLE public.leyenda_final OWNER TO postgres;

--
-- TOC entry 325 (class 1259 OID 43229)
-- Dependencies: 8
-- Name: leyenda_ini_; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE leyenda_ini_ (
    paisaje character varying(150),
    clima character(100),
    mat_parental character varying(150),
    taxonomia character varying(70),
    perfil character(10),
    p_representacion double precision,
    sim_nuevo character(15),
    simbolo_antiguo character(15),
    id_tax integer,
    id_fase integer,
    id_perfil integer,
    fase character(8),
    localizacion character varying(150),
    id integer,
    nombre character varying(100),
    fuente character(250),
    id_l integer NOT NULL
);


ALTER TABLE public.leyenda_ini_ OWNER TO postgres;

--
-- TOC entry 326 (class 1259 OID 43235)
-- Dependencies: 325 8
-- Name: leyenda_ini__id_l_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE leyenda_ini__id_l_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.leyenda_ini__id_l_seq OWNER TO postgres;

--
-- TOC entry 4509 (class 0 OID 0)
-- Dependencies: 326
-- Name: leyenda_ini__id_l_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE leyenda_ini__id_l_seq OWNED BY leyenda_ini_.id_l;


--
-- TOC entry 327 (class 1259 OID 43237)
-- Dependencies: 8
-- Name: leyenda_nueva; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE leyenda_nueva (
    id integer NOT NULL,
    paisaje character varying(150),
    clima character(100),
    mat_parental character varying(150),
    taxonomia text,
    perfiles text,
    porcentajes text,
    sim_nuevo character(15),
    simbolo_antiguo character(15),
    ids_taxonomias text,
    ids_fases text,
    ids_perfiles text,
    fases text,
    localizacion character varying(150),
    nombre character varying(100),
    fuente character(250)
);


ALTER TABLE public.leyenda_nueva OWNER TO postgres;

--
-- TOC entry 328 (class 1259 OID 43243)
-- Dependencies: 8
-- Name: limitante_profundidad; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE limitante_profundidad (
    id integer NOT NULL,
    codigo integer NOT NULL,
    descripcion character(70) NOT NULL
);


ALTER TABLE public.limitante_profundidad OWNER TO postgres;

--
-- TOC entry 329 (class 1259 OID 43246)
-- Dependencies: 328 8
-- Name: limitante_profundidad_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE limitante_profundidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.limitante_profundidad_id_seq OWNER TO postgres;

--
-- TOC entry 4510 (class 0 OID 0)
-- Dependencies: 329
-- Name: limitante_profundidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE limitante_profundidad_id_seq OWNED BY limitante_profundidad.id;


--
-- TOC entry 330 (class 1259 OID 43248)
-- Dependencies: 8
-- Name: localizacion; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE localizacion (
    id integer NOT NULL
);


ALTER TABLE public.localizacion OWNER TO postgres;

--
-- TOC entry 331 (class 1259 OID 43251)
-- Dependencies: 8 330
-- Name: localizacion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE localizacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.localizacion_id_seq OWNER TO postgres;

--
-- TOC entry 4511 (class 0 OID 0)
-- Dependencies: 331
-- Name: localizacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE localizacion_id_seq OWNED BY localizacion.id;


--
-- TOC entry 332 (class 1259 OID 43253)
-- Dependencies: 8
-- Name: material_parental; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE material_parental (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL
);


ALTER TABLE public.material_parental OWNER TO postgres;

--
-- TOC entry 333 (class 1259 OID 43256)
-- Dependencies: 8 332
-- Name: material_parental_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE material_parental_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.material_parental_id_seq OWNER TO postgres;

--
-- TOC entry 4512 (class 0 OID 0)
-- Dependencies: 333
-- Name: material_parental_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE material_parental_id_seq OWNED BY material_parental.id;


--
-- TOC entry 334 (class 1259 OID 43258)
-- Dependencies: 8
-- Name: nomenclatura; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE nomenclatura (
    id integer NOT NULL,
    nombre character varying(5) NOT NULL,
    descripcion character varying(120)
);


ALTER TABLE public.nomenclatura OWNER TO postgres;

--
-- TOC entry 335 (class 1259 OID 43261)
-- Dependencies: 334 8
-- Name: nomenclatura_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE nomenclatura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.nomenclatura_id_seq OWNER TO postgres;

--
-- TOC entry 4513 (class 0 OID 0)
-- Dependencies: 335
-- Name: nomenclatura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE nomenclatura_id_seq OWNED BY nomenclatura.id;


--
-- TOC entry 336 (class 1259 OID 43263)
-- Dependencies: 8
-- Name: observacion; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE observacion (
    id integer NOT NULL,
    prof_inicial integer NOT NULL,
    prof_final integer NOT NULL,
    id_nomenclatura integer NOT NULL,
    id_color integer NOT NULL,
    texto character varying(120),
    tipo_fragmentos_roca character varying(120),
    forma_fragmentos_roca character varying(120),
    estructura_fragmentos_roca character varying(120),
    tipo_estructura character varying(120),
    clase_estructura character varying(120),
    grado_estructura character varying(120),
    superficie_peds integer,
    clase_concentraciones character varying(120),
    campos_concentraciones character varying(120),
    consistencia_seco character varying(120),
    consistencia_humedo character varying(120),
    consistencia_mojado character varying(120),
    reaccion_hcl character varying(120),
    reaccion_naf character varying(120),
    reaccion_ph character varying(120),
    id_descripcion_observacion integer NOT NULL
);


ALTER TABLE public.observacion OWNER TO postgres;

--
-- TOC entry 337 (class 1259 OID 43269)
-- Dependencies: 336 8
-- Name: observacion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE observacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.observacion_id_seq OWNER TO postgres;

--
-- TOC entry 4514 (class 0 OID 0)
-- Dependencies: 337
-- Name: observacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE observacion_id_seq OWNED BY observacion.id;


--
-- TOC entry 338 (class 1259 OID 43271)
-- Dependencies: 8
-- Name: paisaje; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE paisaje (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL
);


ALTER TABLE public.paisaje OWNER TO postgres;

--
-- TOC entry 339 (class 1259 OID 43274)
-- Dependencies: 338 8
-- Name: paisaje_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE paisaje_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.paisaje_id_seq OWNER TO postgres;

--
-- TOC entry 4515 (class 0 OID 0)
-- Dependencies: 339
-- Name: paisaje_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE paisaje_id_seq OWNED BY paisaje.id;


--
-- TOC entry 340 (class 1259 OID 43276)
-- Dependencies: 8
-- Name: suelos_paramos; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE suelos_paramos (
    id integer NOT NULL,
    sim_nuevo character varying(5) NOT NULL,
    fase character varying(5) NOT NULL
);


ALTER TABLE public.suelos_paramos OWNER TO postgres;

--
-- TOC entry 341 (class 1259 OID 43279)
-- Dependencies: 4199 8
-- Name: paramos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW paramos AS
    SELECT suelos_paramos.sim_nuevo, suelos_paramos.fase FROM suelos_paramos GROUP BY suelos_paramos.sim_nuevo, suelos_paramos.fase;


ALTER TABLE public.paramos OWNER TO postgres;

--
-- TOC entry 342 (class 1259 OID 43283)
-- Dependencies: 8
-- Name: paso_ucs_perfil; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE paso_ucs_perfil (
    id integer NOT NULL,
    ucs_perfil character varying(15) NOT NULL,
    ucs character varying(5) NOT NULL,
    perfil character varying(6) NOT NULL,
    porcentaje integer,
    id_perfil integer,
    id_ucs integer
);


ALTER TABLE public.paso_ucs_perfil OWNER TO postgres;

--
-- TOC entry 343 (class 1259 OID 43286)
-- Dependencies: 4343 4344 8
-- Name: pedregosidad; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE pedregosidad (
    id integer NOT NULL,
    descripcion character(2) NOT NULL,
    frag_sup integer DEFAULT 0 NOT NULL,
    frag_suelo integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.pedregosidad OWNER TO postgres;

--
-- TOC entry 344 (class 1259 OID 43291)
-- Dependencies: 8 343
-- Name: pedregosidad_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pedregosidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pedregosidad_id_seq OWNER TO postgres;

--
-- TOC entry 4516 (class 0 OID 0)
-- Dependencies: 344
-- Name: pedregosidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pedregosidad_id_seq OWNED BY pedregosidad.id;


--
-- TOC entry 345 (class 1259 OID 43293)
-- Dependencies: 276 8
-- Name: pendiente_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pendiente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pendiente_id_seq OWNER TO postgres;

--
-- TOC entry 4517 (class 0 OID 0)
-- Dependencies: 345
-- Name: pendiente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pendiente_id_seq OWNED BY pendiente.id;


--
-- TOC entry 346 (class 1259 OID 43295)
-- Dependencies: 8
-- Name: perfil; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

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
-- TOC entry 347 (class 1259 OID 43298)
-- Dependencies: 4200 8
-- Name: perfil03; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW perfil03 AS
    SELECT perfil_simple.id, perfil_simple.codigo, taxonomia.id_drenaje_natural, fertilidad.lim_sup AS fertilidad, profundidad_efectiva.codigo AS id_profundidad_efectiva, taxonomia.id_unidad_cartografica FROM perfil_simple, taxonomia, profundidad_efectiva, fertilidad WHERE (((taxonomia.id_perfil = perfil_simple.id) AND (taxonomia.id_profundidad_efectiva = profundidad_efectiva.id)) AND (fertilidad.id = taxonomia.id_fertilidad)) ORDER BY perfil_simple.id;


ALTER TABLE public.perfil03 OWNER TO postgres;

--
-- TOC entry 348 (class 1259 OID 43302)
-- Dependencies: 346 8
-- Name: perfil_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE perfil_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.perfil_id_seq OWNER TO postgres;

--
-- TOC entry 4518 (class 0 OID 0)
-- Dependencies: 348
-- Name: perfil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE perfil_id_seq OWNED BY perfil.id;


--
-- TOC entry 349 (class 1259 OID 43304)
-- Dependencies: 277 8
-- Name: perfil_simple_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE perfil_simple_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.perfil_simple_id_seq OWNER TO postgres;

--
-- TOC entry 4519 (class 0 OID 0)
-- Dependencies: 349
-- Name: perfil_simple_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE perfil_simple_id_seq OWNED BY perfil_simple.id;


--
-- TOC entry 350 (class 1259 OID 43306)
-- Dependencies: 4201 8
-- Name: perfiles_unidad_cartografica; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW perfiles_unidad_cartografica AS
    SELECT ps.id, btrim((u.sigla)::text) AS sim_nuevo, btrim((u.simbolo_antiguo)::text) AS simbolo_antiguo, btrim((u.nombre)::text) AS nombre, btrim((u.localizacion)::text) AS localizacion, btrim((u.paisaje)::text) AS paisaje, btrim((c.nombre)::text) AS clima, btrim((u.mat_parental)::text) AS btrim, btrim((u.fuente)::text) AS fuente, btrim((t.nombre)::text) AS taxonomia, list(btrim((f.simbolo)::text)) AS fases, btrim((pe.descripcion)::text) AS profundidad, btrim((dn.descripcion)::text) AS drenaje_natural, btrim((ft.descripcion)::text) AS fertilidad, btrim((lp.descripcion)::text) AS limitante_profundidad, t.p_representacion AS p_representc, btrim((ps.codigo)::text) AS perfil FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f, clima c, profundidad_efectiva pe, drenaje_natural dn, fertilidad ft, limitante_profundidad lp WHERE (((((((((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) AND (t.id_profundidad_efectiva = pe.id)) AND (t.id_drenaje_natural = dn.id)) AND (t.id_fertilidad = ft.id)) AND (t.id_limitante_profundidad = lp.id)) AND ((u.localizacion)::text ~~ '%AMAZONAS%'::text)) GROUP BY u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, ps.codigo, t.p_representacion, ps.id, pe.descripcion, dn.descripcion, u.id_clima, u.fuente, u.simbolo_antiguo, c.nombre, t.nombre, ft.descripcion, lp.descripcion ORDER BY ps.codigo;


ALTER TABLE public.perfiles_unidad_cartografica OWNER TO postgres;

--
-- TOC entry 351 (class 1259 OID 43311)
-- Dependencies: 278 8
-- Name: profundidad_efectiva_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE profundidad_efectiva_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.profundidad_efectiva_id_seq OWNER TO postgres;

--
-- TOC entry 4520 (class 0 OID 0)
-- Dependencies: 351
-- Name: profundidad_efectiva_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE profundidad_efectiva_id_seq OWNED BY profundidad_efectiva.id;


--
-- TOC entry 352 (class 1259 OID 43313)
-- Dependencies: 8
-- Name: quimica; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE quimica (
    id integer NOT NULL,
    perfil character varying(10) NOT NULL,
    profundidades character varying(15) NOT NULL,
    simbolo character varying(20),
    descripcion text,
    arena integer NOT NULL,
    limo integer NOT NULL,
    arcilla integer NOT NULL,
    textura character varying(10),
    ph double precision,
    aluminio real,
    saturacion_aluminio real,
    fosforo_ppm real,
    cica real,
    cice real,
    cicv real,
    ca real,
    mg real,
    k real,
    na real,
    sba real,
    co real,
    mo real
);


ALTER TABLE public.quimica OWNER TO postgres;

--
-- TOC entry 353 (class 1259 OID 43319)
-- Dependencies: 352 8
-- Name: quimica_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE quimica_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quimica_id_seq OWNER TO postgres;

--
-- TOC entry 4521 (class 0 OID 0)
-- Dependencies: 353
-- Name: quimica_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE quimica_id_seq OWNED BY quimica.id;


--
-- TOC entry 354 (class 1259 OID 43321)
-- Dependencies: 8
-- Name: relieve; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE relieve (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL
);


ALTER TABLE public.relieve OWNER TO postgres;

--
-- TOC entry 355 (class 1259 OID 43324)
-- Dependencies: 8 354
-- Name: relieve_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE relieve_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.relieve_id_seq OWNER TO postgres;

--
-- TOC entry 4522 (class 0 OID 0)
-- Dependencies: 355
-- Name: relieve_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE relieve_id_seq OWNED BY relieve.id;


--
-- TOC entry 356 (class 1259 OID 43326)
-- Dependencies: 4202 8
-- Name: reporte; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW reporte AS
    SELECT list((unidad_cartografica.simbolo_antiguo)::text) AS sim_anti, list((unidad_cartografica.sigla)::text) AS sim_nuevo, unidad_cartografica.localizacion, count(unidad_cartografica.id) AS cuenta FROM unidad_cartografica GROUP BY unidad_cartografica.sigla, unidad_cartografica.localizacion ORDER BY unidad_cartografica.localizacion;


ALTER TABLE public.reporte OWNER TO postgres;

--
-- TOC entry 357 (class 1259 OID 43330)
-- Dependencies: 8
-- Name: salinidad; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE salinidad (
    id integer NOT NULL,
    codigo integer NOT NULL,
    descripcion character(50) NOT NULL
);


ALTER TABLE public.salinidad OWNER TO postgres;

--
-- TOC entry 358 (class 1259 OID 43333)
-- Dependencies: 4203 8
-- Name: reporte_suelos_total; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW reporte_suelos_total AS
    SELECT f.id, u.sigla AS sim_nuevo, u.simbolo_antiguo, u.nombre, u.localizacion, u.paisaje, c.nombre AS clima, u.mat_parental, u.fuente, t.nombre AS taxonomia, list((ps.codigo)::text) AS perfiles, list(to_char(t.p_representacion, '99'::text)) AS p_representc, list((f.simbolo)::text) AS fases, list((pe.descripcion)::text) AS profundidad, list((dn.descripcion)::text) AS drenaje_natural, ft.descripcion AS fertilidad, lp.descripcion AS limitante_profundidad, pd.descripcion AS pendiente, pg.descripcion AS pedregosidad, sl.descripcion AS salinidad, e.descripcion AS erosion, i.explicacion AS inundabilidad, list((h.nombre)::text) AS horizonte, list((te.descripcion)::text) AS textura, list(to_char(h.profundidad_inicial, '999d99'::text)) AS prof_inicial, list(to_char(h.profundidad_final, '999d99'::text)) AS prof_final, list((et.descripcion)::text) AS estructura, list((cl.nombre)::text) AS color, list(to_char(h.ph, '999D99'::text)) AS ph, list(to_char(h.cic, '999d99'::text)) AS cic, list(to_char(h.bt, '999d99'::text)) AS bt, list(to_char(h.sb, '999d99'::text)) AS sb, list(to_char(h.co, '999d99'::text)) AS co, list(to_char(h.nt, '999d99'::text)) AS nt, list(to_char(h.pp, '999d99'::text)) AS pp, list(to_char(h.kc, '999d99'::text)) AS kc, list(to_char(h.ce, '999d99'::text)) AS ce, list(to_char(h.sat_al, '999d99'::text)) AS sat_al FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f, clima c, horizonte h, profundidad_efectiva pe, drenaje_natural dn, fertilidad ft, limitante_profundidad lp, pendiente pd, pedregosidad pg, salinidad sl, erosion e, inundabilidad i, textura te, estructura et, color cl WHERE (((((((((((((((((((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) AND (t.id_profundidad_efectiva = pe.id)) AND (t.id_drenaje_natural = dn.id)) AND (t.id_fertilidad = ft.id)) AND (t.id_limitante_profundidad = lp.id)) AND (f.id_pendiente = pd.id)) AND (f.id_pedregosidad = pg.id)) AND (f.id_salinidad = sl.id)) AND (f.id_erosion = e.id)) AND (f.id_inundabilidad = i.id)) AND (h.id_unidad_cartografica = ps.id_unidad_cartografica)) AND (h.id_perfil = ps.id)) AND (h.id_textura = te.id)) AND (h.id_estructura = et.id)) AND (h.id_color = cl.id)) AND ((u.localizacion)::text = 'GUAJIRA'::text)) GROUP BY f.id, u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, u.id_clima, u.fuente, u.simbolo_antiguo, c.nombre, t.nombre, ft.descripcion, lp.descripcion, pd.descripcion, pg.descripcion, sl.descripcion, e.descripcion, i.explicacion ORDER BY f.id, u.id;


ALTER TABLE public.reporte_suelos_total OWNER TO postgres;

--
-- TOC entry 359 (class 1259 OID 43338)
-- Dependencies: 8 357
-- Name: salinidad_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE salinidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.salinidad_id_seq OWNER TO postgres;

--
-- TOC entry 4523 (class 0 OID 0)
-- Dependencies: 359
-- Name: salinidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE salinidad_id_seq OWNED BY salinidad.id;


--
-- TOC entry 360 (class 1259 OID 43340)
-- Dependencies: 8
-- Name: unidad_omitida; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE unidad_omitida (
    id integer NOT NULL,
    sim_nuevo character(15),
    sim_anti character(15),
    dpto character(60)
);


ALTER TABLE public.unidad_omitida OWNER TO postgres;

--
-- TOC entry 361 (class 1259 OID 43343)
-- Dependencies: 4204 8
-- Name: simbolos_faltantes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW simbolos_faltantes AS
    SELECT u.id, u.sim_nuevo, u.sim_anti, u.dpto FROM unidad_omitida u WHERE (NOT (u.sim_nuevo IN (SELECT uc.sigla FROM unidad_cartografica uc))) ORDER BY u.dpto, u.sim_nuevo;


ALTER TABLE public.simbolos_faltantes OWNER TO postgres;

--
-- TOC entry 362 (class 1259 OID 43353)
-- Dependencies: 8
-- Name: subclase_agrologica; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE subclase_agrologica (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL
);


ALTER TABLE public.subclase_agrologica OWNER TO postgres;

--
-- TOC entry 363 (class 1259 OID 43356)
-- Dependencies: 8 362
-- Name: subclase_agrologica_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE subclase_agrologica_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subclase_agrologica_id_seq OWNER TO postgres;

--
-- TOC entry 4524 (class 0 OID 0)
-- Dependencies: 363
-- Name: subclase_agrologica_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE subclase_agrologica_id_seq OWNED BY subclase_agrologica.id;


--
-- TOC entry 364 (class 1259 OID 43358)
-- Dependencies: 4205 8
-- Name: suelo_completo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW suelo_completo AS
    SELECT f.id, u.sigla AS sim_nuevo, u.simbolo_antiguo, u.nombre, u.localizacion, u.paisaje, c.nombre AS clima, u.mat_parental, u.fuente, t.nombre AS taxonomia, list((ps.codigo)::text) AS perfiles, list(to_char(t.p_representacion, '99'::text)) AS p_representc, list((f.simbolo)::text) AS fases, list((pe.descripcion)::text) AS profundidad, list((dn.descripcion)::text) AS drenaje_natural, ft.descripcion AS fertilidad, lp.descripcion AS limitante_profundidad, pd.descripcion AS pendiente, pg.descripcion AS pedregosidad, sl.descripcion AS salinidad, e.descripcion AS erosion, i.explicacion AS inundabilidad, list((h.nombre)::text) AS horizonte, list((te.descripcion)::text) AS textura, list(to_char(h.profundidad_inicial, '999d99'::text)) AS prof_inicial, list(to_char(h.profundidad_final, '999d99'::text)) AS prof_final, list((et.descripcion)::text) AS estructura, list((cl.nombre)::text) AS color, list(to_char(h.ph, '999D99'::text)) AS ph, list(to_char(h.cic, '999d99'::text)) AS cic, list(to_char(h.bt, '999d99'::text)) AS bt, list(to_char(h.sb, '999d99'::text)) AS sb, list(to_char(h.co, '999d99'::text)) AS co, list(to_char(h.nt, '999d99'::text)) AS nt, list(to_char(h.pp, '999d99'::text)) AS pp, list(to_char(h.kc, '999d99'::text)) AS kc, list(to_char(h.ce, '999d99'::text)) AS ce FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f, clima c, horizonte h, profundidad_efectiva pe, drenaje_natural dn, fertilidad ft, limitante_profundidad lp, pendiente pd, pedregosidad pg, salinidad sl, erosion e, inundabilidad i, textura te, estructura et, color cl WHERE ((((((((((((((((((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) AND (t.id_profundidad_efectiva = pe.id)) AND (t.id_drenaje_natural = dn.id)) AND (t.id_fertilidad = ft.id)) AND (t.id_limitante_profundidad = lp.id)) AND (f.id_pendiente = pd.id)) AND (f.id_pedregosidad = pg.id)) AND (f.id_salinidad = sl.id)) AND (f.id_erosion = e.id)) AND (f.id_inundabilidad = i.id)) AND (h.id_unidad_cartografica = ps.id_unidad_cartografica)) AND (h.id_perfil = ps.id)) AND (h.id_textura = te.id)) AND (h.id_estructura = et.id)) AND (h.id_color = cl.id)) GROUP BY f.id, u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, u.id_clima, u.fuente, u.simbolo_antiguo, c.nombre, t.nombre, ft.descripcion, lp.descripcion, pd.descripcion, pg.descripcion, sl.descripcion, e.descripcion, i.explicacion ORDER BY f.id, u.id;


ALTER TABLE public.suelo_completo OWNER TO postgres;

--
-- TOC entry 365 (class 1259 OID 43365)
-- Dependencies: 8
-- Name: suelo_completo_horizontes; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE suelo_completo_horizontes (
    estudio text,
    id integer,
    sim_nuevo text,
    simbolo_antiguo text,
    nombre text,
    localizacion text,
    paisaje text,
    clima text,
    btrim text,
    fuente text,
    taxonomia text,
    perfil text,
    p_representc double precision,
    fase text,
    profundidad text,
    drenaje_natural text,
    fertilidad text,
    limitante_profundidad text,
    pendiente text,
    pedregosidad text,
    salinidad text,
    erosion text,
    inundabilidad text,
    horizonte text,
    textura text,
    prof_inicial integer,
    prof_final integer,
    estructura text,
    color text,
    ph double precision,
    cic double precision,
    bt double precision,
    sb double precision,
    co double precision,
    nt double precision,
    pp double precision,
    kc double precision,
    ce double precision,
    sat_al double precision
);


ALTER TABLE public.suelo_completo_horizontes OWNER TO postgres;

--
-- TOC entry 366 (class 1259 OID 43372)
-- Dependencies: 8
-- Name: suelo_variables_fao; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE suelo_variables_fao (
    id integer,
    sim_nuevo text,
    sim_anti text,
    nombre text,
    localizacion text,
    paisaje text,
    clima text,
    mat_parental text,
    fuente text,
    taxonomia text,
    perfil text,
    p_representacion double precision,
    fase text,
    profundidad character(50),
    drenaje_natural character(50),
    fertilidad character(50),
    limitante_profundidad character(70),
    pendiente character(10),
    pedregosidad character(2),
    salinidad character(50),
    erosion character(12),
    inundabilidad character(40),
    horizonte character(8),
    textura character(30),
    profundidad_inicial integer,
    profundidad_final integer,
    estructura character(100),
    color character(50),
    ph double precision,
    cic double precision,
    bt double precision,
    sb double precision,
    co double precision,
    nt double precision,
    pp double precision,
    kc double precision,
    ce double precision,
    sat_al double precision
);


ALTER TABLE public.suelo_variables_fao OWNER TO postgres;

--
-- TOC entry 367 (class 1259 OID 43377)
-- Dependencies: 4208 8
-- Name: suelo_vars_fao_sin_fase; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW suelo_vars_fao_sin_fase AS
    SELECT btrim((u.sigla)::text) AS sim_nuevo, btrim((u.simbolo_antiguo)::text) AS sim_anti, btrim((u.nombre)::text) AS nombre, btrim((u.localizacion)::text) AS localizacion, btrim((u.paisaje)::text) AS paisaje, btrim((c.nombre)::text) AS clima, btrim((u.mat_parental)::text) AS mat_parental, btrim((u.fuente)::text) AS fuente, btrim((t.nombre)::text) AS taxonomia, btrim((ps.codigo)::text) AS perfil, t.p_representacion, pe.descripcion AS profundidad, dn.descripcion AS drenaje_natural, ft.descripcion AS fertilidad, lp.descripcion AS limitante_profundidad, h.nombre AS horizonte, te.descripcion AS textura, h.profundidad_inicial, h.profundidad_final, et.descripcion AS estructura, cl.nombre AS color, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al FROM unidad_cartografica u, perfil_simple ps, taxonomia t, clima c, horizonte h, profundidad_efectiva pe, drenaje_natural dn, fertilidad ft, limitante_profundidad lp, textura te, estructura et, color cl WHERE ((((((((((((t.id_perfil = ps.id) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) AND (t.id_profundidad_efectiva = pe.id)) AND (t.id_drenaje_natural = dn.id)) AND (t.id_fertilidad = ft.id)) AND (t.id_limitante_profundidad = lp.id)) AND (h.id_unidad_cartografica = ps.id_unidad_cartografica)) AND (h.id_perfil = ps.id)) AND (h.id_textura = te.id)) AND (h.id_estructura = et.id)) AND (h.id_color = cl.id)) GROUP BY u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, h.sat_al, u.id_clima, u.fuente, u.simbolo_antiguo, c.nombre, t.nombre, ft.descripcion, lp.descripcion, t.p_representacion, h.profundidad_inicial, h.profundidad_final, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, ps.codigo, pe.descripcion, dn.descripcion, h.nombre, te.descripcion, et.descripcion, cl.nombre ORDER BY u.id;


ALTER TABLE public.suelo_vars_fao_sin_fase OWNER TO postgres;

--
-- TOC entry 368 (class 1259 OID 43382)
-- Dependencies: 4209 8
-- Name: suelos_atlantico; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW suelos_atlantico AS
    SELECT f.id, u.sigla AS sim_nuevo, u.simbolo_antiguo, u.nombre, u.localizacion, u.paisaje, c.nombre AS clima, u.mat_parental, u.fuente, t.nombre AS taxonomia, list((ps.codigo)::text) AS perfiles, t.p_representacion, f.simbolo AS fase, pe.descripcion AS profundidad, dn.descripcion AS drenaje_natural, ft.descripcion AS fertilidad, lp.descripcion AS limitante_profundidad, pd.descripcion AS pendiente, pg.descripcion AS pedregosidad, sl.descripcion AS salinidad, e.descripcion AS erosion, i.explicacion AS inundabilidad, h.nombre AS horizonte, h.profundidad_inicial, h.profundidad_final, te.descripcion AS textura, et.descripcion AS estructura, cl.cod_munsel AS color, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f, clima c, horizonte h, profundidad_efectiva pe, drenaje_natural dn, fertilidad ft, limitante_profundidad lp, pendiente pd, pedregosidad pg, salinidad sl, erosion e, inundabilidad i, textura te, estructura et, color cl WHERE (((((((((((((((((((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) AND (t.id_profundidad_efectiva = pe.id)) AND (t.id_drenaje_natural = dn.id)) AND (t.id_fertilidad = ft.id)) AND (t.id_limitante_profundidad = lp.id)) AND (f.id_pendiente = pd.id)) AND (f.id_pedregosidad = pg.id)) AND (f.id_salinidad = sl.id)) AND (f.id_erosion = e.id)) AND (f.id_inundabilidad = i.id)) AND (h.id_unidad_cartografica = ps.id_unidad_cartografica)) AND (h.id_perfil = ps.id)) AND (h.id_textura = te.id)) AND (h.id_estructura = et.id)) AND (h.id_color = cl.id)) AND ((u.localizacion)::text = 'ATLANTICO'::text)) GROUP BY f.id, u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, u.id_clima, u.fuente, u.simbolo_antiguo, c.nombre, t.nombre, ft.descripcion, lp.descripcion, pd.descripcion, pg.descripcion, sl.descripcion, e.descripcion, i.explicacion, f.simbolo, pe.descripcion, h.profundidad_inicial, h.profundidad_final, et.descripcion, cl.cod_munsel, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al, t.p_representacion, dn.descripcion, h.nombre, te.descripcion, t.id, ps.id ORDER BY u.id, f.id, t.id, ps.id, h.profundidad_inicial, h.profundidad_final;


ALTER TABLE public.suelos_atlantico OWNER TO postgres;

--
-- TOC entry 369 (class 1259 OID 43387)
-- Dependencies: 4210 8
-- Name: suelos_bolivar; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW suelos_bolivar AS
    SELECT f.id, u.sigla AS sim_nuevo, u.simbolo_antiguo, u.nombre, u.localizacion, u.paisaje, c.nombre AS clima, u.mat_parental, u.fuente, t.nombre AS taxonomia, list((ps.codigo)::text) AS perfiles, t.p_representacion, f.simbolo AS fase, pe.descripcion AS profundidad, dn.descripcion AS drenaje_natural, ft.descripcion AS fertilidad, lp.descripcion AS limitante_profundidad, pd.descripcion AS pendiente, pg.descripcion AS pedregosidad, sl.descripcion AS salinidad, e.descripcion AS erosion, i.explicacion AS inundabilidad, h.nombre AS horizonte, h.profundidad_inicial, h.profundidad_final, te.descripcion AS textura, et.descripcion AS estructura, cl.cod_munsel AS color, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f, clima c, horizonte h, profundidad_efectiva pe, drenaje_natural dn, fertilidad ft, limitante_profundidad lp, pendiente pd, pedregosidad pg, salinidad sl, erosion e, inundabilidad i, textura te, estructura et, color cl WHERE (((((((((((((((((((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) AND (t.id_profundidad_efectiva = pe.id)) AND (t.id_drenaje_natural = dn.id)) AND (t.id_fertilidad = ft.id)) AND (t.id_limitante_profundidad = lp.id)) AND (f.id_pendiente = pd.id)) AND (f.id_pedregosidad = pg.id)) AND (f.id_salinidad = sl.id)) AND (f.id_erosion = e.id)) AND (f.id_inundabilidad = i.id)) AND (h.id_unidad_cartografica = ps.id_unidad_cartografica)) AND (h.id_perfil = ps.id)) AND (h.id_textura = te.id)) AND (h.id_estructura = et.id)) AND (h.id_color = cl.id)) AND ((u.localizacion)::text = 'BOLIVAR'::text)) GROUP BY f.id, u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, u.id_clima, u.fuente, u.simbolo_antiguo, c.nombre, t.nombre, ft.descripcion, lp.descripcion, pd.descripcion, pg.descripcion, sl.descripcion, e.descripcion, i.explicacion, f.simbolo, pe.descripcion, h.profundidad_inicial, h.profundidad_final, et.descripcion, cl.cod_munsel, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al, t.p_representacion, dn.descripcion, h.nombre, te.descripcion, t.id, ps.id ORDER BY u.id, f.id, t.id, ps.id, h.profundidad_inicial, h.profundidad_final;


ALTER TABLE public.suelos_bolivar OWNER TO postgres;

--
-- TOC entry 370 (class 1259 OID 43392)
-- Dependencies: 4211 8
-- Name: suelos_cordoba; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW suelos_cordoba AS
    SELECT f.id, u.sigla AS sim_nuevo, u.simbolo_antiguo, u.nombre, u.localizacion, u.paisaje, c.nombre AS clima, u.mat_parental, u.fuente, t.nombre AS taxonomia, list((ps.codigo)::text) AS perfiles, t.p_representacion, f.simbolo AS fase, pe.descripcion AS profundidad, dn.descripcion AS drenaje_natural, ft.descripcion AS fertilidad, lp.descripcion AS limitante_profundidad, pd.descripcion AS pendiente, pg.descripcion AS pedregosidad, sl.descripcion AS salinidad, e.descripcion AS erosion, i.explicacion AS inundabilidad, h.nombre AS horizonte, h.profundidad_inicial, h.profundidad_final, te.descripcion AS textura, et.descripcion AS estructura, cl.cod_munsel AS color, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f, clima c, horizonte h, profundidad_efectiva pe, drenaje_natural dn, fertilidad ft, limitante_profundidad lp, pendiente pd, pedregosidad pg, salinidad sl, erosion e, inundabilidad i, textura te, estructura et, color cl WHERE (((((((((((((((((((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) AND (t.id_profundidad_efectiva = pe.id)) AND (t.id_drenaje_natural = dn.id)) AND (t.id_fertilidad = ft.id)) AND (t.id_limitante_profundidad = lp.id)) AND (f.id_pendiente = pd.id)) AND (f.id_pedregosidad = pg.id)) AND (f.id_salinidad = sl.id)) AND (f.id_erosion = e.id)) AND (f.id_inundabilidad = i.id)) AND (h.id_unidad_cartografica = ps.id_unidad_cartografica)) AND (h.id_perfil = ps.id)) AND (h.id_textura = te.id)) AND (h.id_estructura = et.id)) AND (h.id_color = cl.id)) AND ((u.localizacion)::text = 'CORDOBA'::text)) GROUP BY f.id, u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, u.id_clima, u.fuente, u.simbolo_antiguo, c.nombre, t.nombre, ft.descripcion, lp.descripcion, pd.descripcion, pg.descripcion, sl.descripcion, e.descripcion, i.explicacion, f.simbolo, pe.descripcion, h.profundidad_inicial, h.profundidad_final, et.descripcion, cl.cod_munsel, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al, t.p_representacion, dn.descripcion, h.nombre, te.descripcion, t.id, ps.id ORDER BY u.id, f.id, t.id, ps.id, h.profundidad_inicial, h.profundidad_final;


ALTER TABLE public.suelos_cordoba OWNER TO postgres;

--
-- TOC entry 371 (class 1259 OID 43397)
-- Dependencies: 4212 8
-- Name: suelos_guajira; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW suelos_guajira AS
    SELECT f.id, u.sigla AS sim_nuevo, u.simbolo_antiguo, u.nombre, u.localizacion, u.paisaje, c.nombre AS clima, u.mat_parental, u.fuente, t.nombre AS taxonomia, list((ps.codigo)::text) AS perfiles, t.p_representacion, f.simbolo AS fase, pe.descripcion AS profundidad, dn.descripcion AS drenaje_natural, ft.descripcion AS fertilidad, lp.descripcion AS limitante_profundidad, pd.descripcion AS pendiente, pg.descripcion AS pedregosidad, sl.descripcion AS salinidad, e.descripcion AS erosion, i.explicacion AS inundabilidad, h.nombre AS horizonte, h.profundidad_inicial, h.profundidad_final, te.descripcion AS textura, et.descripcion AS estructura, cl.cod_munsel AS color, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f, clima c, horizonte h, profundidad_efectiva pe, drenaje_natural dn, fertilidad ft, limitante_profundidad lp, pendiente pd, pedregosidad pg, salinidad sl, erosion e, inundabilidad i, textura te, estructura et, color cl WHERE (((((((((((((((((((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) AND (t.id_profundidad_efectiva = pe.id)) AND (t.id_drenaje_natural = dn.id)) AND (t.id_fertilidad = ft.id)) AND (t.id_limitante_profundidad = lp.id)) AND (f.id_pendiente = pd.id)) AND (f.id_pedregosidad = pg.id)) AND (f.id_salinidad = sl.id)) AND (f.id_erosion = e.id)) AND (f.id_inundabilidad = i.id)) AND (h.id_unidad_cartografica = ps.id_unidad_cartografica)) AND (h.id_perfil = ps.id)) AND (h.id_textura = te.id)) AND (h.id_estructura = et.id)) AND (h.id_color = cl.id)) AND ((u.localizacion)::text = 'GUAJIRA'::text)) GROUP BY f.id, u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, u.id_clima, u.fuente, u.simbolo_antiguo, c.nombre, t.nombre, ft.descripcion, lp.descripcion, pd.descripcion, pg.descripcion, sl.descripcion, e.descripcion, i.explicacion, f.simbolo, pe.descripcion, h.profundidad_inicial, h.profundidad_final, et.descripcion, cl.cod_munsel, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al, t.p_representacion, dn.descripcion, h.nombre, te.descripcion, t.id, ps.id ORDER BY u.id, f.id, t.id, ps.id, h.profundidad_inicial, h.profundidad_final;


ALTER TABLE public.suelos_guajira OWNER TO postgres;

--
-- TOC entry 372 (class 1259 OID 43402)
-- Dependencies: 4213 8
-- Name: suelos_magdalena; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW suelos_magdalena AS
    SELECT f.id, u.sigla AS sim_nuevo, u.simbolo_antiguo, u.nombre, u.localizacion, u.paisaje, c.nombre AS clima, u.mat_parental, u.fuente, t.nombre AS taxonomia, list((ps.codigo)::text) AS perfiles, t.p_representacion, f.simbolo AS fase, pe.descripcion AS profundidad, dn.descripcion AS drenaje_natural, ft.descripcion AS fertilidad, lp.descripcion AS limitante_profundidad, pd.descripcion AS pendiente, pg.descripcion AS pedregosidad, sl.descripcion AS salinidad, e.descripcion AS erosion, i.explicacion AS inundabilidad, h.nombre AS horizonte, h.profundidad_inicial, h.profundidad_final, te.descripcion AS textura, et.descripcion AS estructura, cl.cod_munsel AS color, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f, clima c, horizonte h, profundidad_efectiva pe, drenaje_natural dn, fertilidad ft, limitante_profundidad lp, pendiente pd, pedregosidad pg, salinidad sl, erosion e, inundabilidad i, textura te, estructura et, color cl WHERE (((((((((((((((((((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) AND (t.id_profundidad_efectiva = pe.id)) AND (t.id_drenaje_natural = dn.id)) AND (t.id_fertilidad = ft.id)) AND (t.id_limitante_profundidad = lp.id)) AND (f.id_pendiente = pd.id)) AND (f.id_pedregosidad = pg.id)) AND (f.id_salinidad = sl.id)) AND (f.id_erosion = e.id)) AND (f.id_inundabilidad = i.id)) AND (h.id_unidad_cartografica = ps.id_unidad_cartografica)) AND (h.id_perfil = ps.id)) AND (h.id_textura = te.id)) AND (h.id_estructura = et.id)) AND (h.id_color = cl.id)) AND ((u.localizacion)::text = 'MAGDALENA'::text)) GROUP BY f.id, u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, u.id_clima, u.fuente, u.simbolo_antiguo, c.nombre, t.nombre, ft.descripcion, lp.descripcion, pd.descripcion, pg.descripcion, sl.descripcion, e.descripcion, i.explicacion, f.simbolo, pe.descripcion, h.profundidad_inicial, h.profundidad_final, et.descripcion, cl.cod_munsel, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al, t.p_representacion, dn.descripcion, h.nombre, te.descripcion, t.id, ps.id ORDER BY u.id, f.id, t.id, ps.id, h.profundidad_inicial, h.profundidad_final;


ALTER TABLE public.suelos_magdalena OWNER TO postgres;

--
-- TOC entry 373 (class 1259 OID 43407)
-- Dependencies: 4214 8
-- Name: suelos_paramos_taxonomia; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW suelos_paramos_taxonomia AS
    SELECT p.sim_nuevo, p.fase, t.nombre, array_to_string(array_agg(btrim((ps.codigo)::text)), ','::text) AS perfil, array_to_string(array_agg(t.p_representacion), ','::text) AS p_perfiles, u.localizacion FROM paramos p, unidad_cartografica u, fase_cartografica f, taxonomia t, perfil_simple ps WHERE ((((((btrim((p.sim_nuevo)::text) = btrim((u.sigla)::text)) AND (btrim((p.fase)::text) = btrim((f.simbolo)::text))) AND (u.id = f.id_unidad_cartografica)) AND (u.id = t.id_unidad_cartografica)) AND (ps.id_unidad_cartografica = u.id)) AND (ps.id = t.id_perfil)) GROUP BY p.sim_nuevo, p.fase, u.localizacion, t.nombre ORDER BY p.sim_nuevo, p.fase;


ALTER TABLE public.suelos_paramos_taxonomia OWNER TO postgres;

--
-- TOC entry 374 (class 1259 OID 43412)
-- Dependencies: 4215 8
-- Name: suelos_paramos_taxonomia_agrupado_perfiles; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW suelos_paramos_taxonomia_agrupado_perfiles AS
    SELECT p.sim_nuevo, p.fase, array_to_string(array_agg(t.nombre), ','::text) AS taxonomias, array_to_string(array_agg(btrim((ps.codigo)::text)), ','::text) AS perfil, array_to_string(array_agg(t.p_representacion), ','::text) AS p_perfiles, u.localizacion FROM paramos p, unidad_cartografica u, fase_cartografica f, taxonomia t, perfil_simple ps WHERE ((((((btrim((p.sim_nuevo)::text) = btrim((u.sigla)::text)) AND (btrim((p.fase)::text) = btrim((f.simbolo)::text))) AND (u.id = f.id_unidad_cartografica)) AND (u.id = t.id_unidad_cartografica)) AND (ps.id_unidad_cartografica = u.id)) AND (ps.id = t.id_perfil)) GROUP BY p.sim_nuevo, p.fase, u.localizacion ORDER BY p.sim_nuevo, p.fase;


ALTER TABLE public.suelos_paramos_taxonomia_agrupado_perfiles OWNER TO postgres;

--
-- TOC entry 375 (class 1259 OID 43417)
-- Dependencies: 4216 8
-- Name: suelos_sucre; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW suelos_sucre AS
    SELECT f.id, u.sigla AS sim_nuevo, u.simbolo_antiguo, u.nombre, u.localizacion, u.paisaje, c.nombre AS clima, u.mat_parental, u.fuente, t.nombre AS taxonomia, list((ps.codigo)::text) AS perfiles, t.p_representacion, f.simbolo AS fase, pe.descripcion AS profundidad, dn.descripcion AS drenaje_natural, ft.descripcion AS fertilidad, lp.descripcion AS limitante_profundidad, pd.descripcion AS pendiente, pg.descripcion AS pedregosidad, sl.descripcion AS salinidad, e.descripcion AS erosion, i.explicacion AS inundabilidad, h.nombre AS horizonte, h.profundidad_inicial, h.profundidad_final, te.descripcion AS textura, et.descripcion AS estructura, cl.cod_munsel AS color, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f, clima c, horizonte h, profundidad_efectiva pe, drenaje_natural dn, fertilidad ft, limitante_profundidad lp, pendiente pd, pedregosidad pg, salinidad sl, erosion e, inundabilidad i, textura te, estructura et, color cl WHERE (((((((((((((((((((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) AND (t.id_profundidad_efectiva = pe.id)) AND (t.id_drenaje_natural = dn.id)) AND (t.id_fertilidad = ft.id)) AND (t.id_limitante_profundidad = lp.id)) AND (f.id_pendiente = pd.id)) AND (f.id_pedregosidad = pg.id)) AND (f.id_salinidad = sl.id)) AND (f.id_erosion = e.id)) AND (f.id_inundabilidad = i.id)) AND (h.id_unidad_cartografica = ps.id_unidad_cartografica)) AND (h.id_perfil = ps.id)) AND (h.id_textura = te.id)) AND (h.id_estructura = et.id)) AND (h.id_color = cl.id)) AND ((u.localizacion)::text = 'SUCRE'::text)) GROUP BY f.id, u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, u.id_clima, u.fuente, u.simbolo_antiguo, c.nombre, t.nombre, ft.descripcion, lp.descripcion, pd.descripcion, pg.descripcion, sl.descripcion, e.descripcion, i.explicacion, f.simbolo, pe.descripcion, h.profundidad_inicial, h.profundidad_final, et.descripcion, cl.cod_munsel, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al, t.p_representacion, dn.descripcion, h.nombre, te.descripcion, t.id, ps.id ORDER BY u.id, f.id, t.id, ps.id, h.profundidad_inicial, h.profundidad_final;


ALTER TABLE public.suelos_sucre OWNER TO postgres;

--
-- TOC entry 376 (class 1259 OID 43422)
-- Dependencies: 8
-- Name: suelos_variables; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE suelos_variables (
    sim_nuevo character(15),
    simbolo_antiguo character(15),
    nombre character varying(100),
    localizacion character varying(150),
    paisaje character varying(150),
    clima character(100),
    mat_parental character varying(150),
    fuente character(250),
    taxonomia character varying(70),
    perfiles text,
    p_representc text,
    fases text,
    profundidad text,
    drenaje_natural text,
    fertilidad character(50),
    limitante_profundidad character(70),
    pendiente character(10),
    pedregosidad character(2),
    salinidad character(50),
    erosion character(12),
    inundabilidad character(40),
    horizonte text,
    textura text,
    prof_inicial text,
    prof_final text,
    estructura text,
    color text,
    ph text,
    cic text,
    bt text,
    sb text,
    co text,
    nt text,
    pp text,
    kc text,
    ce text,
    id integer NOT NULL
);


ALTER TABLE public.suelos_variables OWNER TO postgres;

--
-- TOC entry 377 (class 1259 OID 43428)
-- Dependencies: 8 376
-- Name: suelos_variables_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE suelos_variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.suelos_variables_id_seq OWNER TO postgres;

--
-- TOC entry 4525 (class 0 OID 0)
-- Dependencies: 377
-- Name: suelos_variables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE suelos_variables_id_seq OWNED BY suelos_variables.id;


--
-- TOC entry 378 (class 1259 OID 43430)
-- Dependencies: 279 8
-- Name: taxonomia_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE taxonomia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taxonomia_id_seq OWNER TO postgres;

--
-- TOC entry 4526 (class 0 OID 0)
-- Dependencies: 378
-- Name: taxonomia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE taxonomia_id_seq OWNED BY taxonomia.id;


--
-- TOC entry 379 (class 1259 OID 43432)
-- Dependencies: 8 295
-- Name: textura_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE textura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.textura_id_seq OWNER TO postgres;

--
-- TOC entry 4527 (class 0 OID 0)
-- Dependencies: 379
-- Name: textura_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE textura_id_seq OWNED BY textura.id;


--
-- TOC entry 380 (class 1259 OID 43434)
-- Dependencies: 8
-- Name: tipo_observacion; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE tipo_observacion (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL
);


ALTER TABLE public.tipo_observacion OWNER TO postgres;

--
-- TOC entry 381 (class 1259 OID 43437)
-- Dependencies: 8 380
-- Name: tipo_observacion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tipo_observacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tipo_observacion_id_seq OWNER TO postgres;

--
-- TOC entry 4528 (class 0 OID 0)
-- Dependencies: 381
-- Name: tipo_observacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tipo_observacion_id_seq OWNED BY tipo_observacion.id;


--
-- TOC entry 382 (class 1259 OID 43439)
-- Dependencies: 8 280
-- Name: unidad_cartografica_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE unidad_cartografica_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unidad_cartografica_id_seq OWNER TO postgres;

--
-- TOC entry 4529 (class 0 OID 0)
-- Dependencies: 382
-- Name: unidad_cartografica_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE unidad_cartografica_id_seq OWNED BY unidad_cartografica.id;


--
-- TOC entry 383 (class 1259 OID 43441)
-- Dependencies: 8
-- Name: unidad_cartografica_medicion; Type: TABLE; Schema: public; Owner: postgres; Tablespace:
--

CREATE TABLE unidad_cartografica_medicion (
    id integer NOT NULL,
    simbolo character varying(10) NOT NULL
);


ALTER TABLE public.unidad_cartografica_medicion OWNER TO postgres;

--
-- TOC entry 384 (class 1259 OID 43444)
-- Dependencies: 8 383
-- Name: unidad_cartografica_medicion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE unidad_cartografica_medicion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.unidad_cartografica_medicion_id_seq OWNER TO postgres;

--
-- TOC entry 4530 (class 0 OID 0)
-- Dependencies: 384
-- Name: unidad_cartografica_medicion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE unidad_cartografica_medicion_id_seq OWNED BY unidad_cartografica_medicion.id;


--
-- TOC entry 4355 (class 2604 OID 59072)
-- Dependencies: 541 540 541
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY amazonas ALTER COLUMN gid SET DEFAULT nextval('amazonas_gid_seq'::regclass);


--
-- TOC entry 4317 (class 2604 OID 43969)
-- Dependencies: 284 283
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY capacidad ALTER COLUMN id SET DEFAULT nextval('capacidad_id_seq'::regclass);


--
-- TOC entry 4318 (class 2604 OID 43970)
-- Dependencies: 287 286
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY clase_agrologica ALTER COLUMN id SET DEFAULT nextval('clase_agrologica_id_seq'::regclass);


--
-- TOC entry 4319 (class 2604 OID 43971)
-- Dependencies: 289 288
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY clima ALTER COLUMN id SET DEFAULT nextval('clima_id_seq'::regclass);


--
-- TOC entry 4320 (class 2604 OID 43972)
-- Dependencies: 291 290
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY color ALTER COLUMN id SET DEFAULT nextval('color_id_seq'::regclass);


--
-- TOC entry 4328 (class 2604 OID 43973)
-- Dependencies: 298 297
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY descripcion_observacion ALTER COLUMN id SET DEFAULT nextval('descripcion_observacion_id_seq'::regclass);


--
-- TOC entry 4329 (class 2604 OID 43974)
-- Dependencies: 300 299
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY descripcion_perfil ALTER COLUMN id SET DEFAULT nextval('descripcion_perfil_id_seq'::regclass);


--
-- TOC entry 4330 (class 2604 OID 43975)
-- Dependencies: 302 301
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY descriptor ALTER COLUMN id SET DEFAULT nextval('descriptor_id_seq'::regclass);


--
-- TOC entry 4284 (class 2604 OID 43976)
-- Dependencies: 303 273
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY drenaje_natural ALTER COLUMN id SET DEFAULT nextval('drenaje_natural_id_seq'::regclass);


--
-- TOC entry 4331 (class 2604 OID 43977)
-- Dependencies: 305 304
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY encharcamiento ALTER COLUMN id SET DEFAULT nextval('encharcamiento_id_seq'::regclass);


--
-- TOC entry 4322 (class 2604 OID 43978)
-- Dependencies: 306 292
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY erosion ALTER COLUMN id SET DEFAULT nextval('erosion_id_seq'::regclass);


--
-- TOC entry 4332 (class 2604 OID 43979)
-- Dependencies: 308 307
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY estructura ALTER COLUMN id SET DEFAULT nextval('estructura_id_seq'::regclass);


--
-- TOC entry 4293 (class 2604 OID 43980)
-- Dependencies: 309 274
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fase_cartografica ALTER COLUMN id SET DEFAULT nextval('fase_cartografica_id_seq'::regclass);


--
-- TOC entry 4325 (class 2604 OID 43981)
-- Dependencies: 310 293
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fertilidad ALTER COLUMN id SET DEFAULT nextval('fertilidad_id_seq'::regclass);


--
-- TOC entry 4333 (class 2604 OID 43982)
-- Dependencies: 312 311
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forma_terreno ALTER COLUMN id SET DEFAULT nextval('forma_terreno_id_seq'::regclass);


--
-- TOC entry 4334 (class 2604 OID 43983)
-- Dependencies: 314 313
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fuente ALTER COLUMN id SET DEFAULT nextval('fuente_id_seq'::regclass);


--
-- TOC entry 4356 (class 2604 OID 60439)
-- Dependencies: 546 545 546
-- Name: gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY gp_antioquia ALTER COLUMN gid SET DEFAULT nextval('gp_antioquia_gid_seq'::regclass);


--
-- TOC entry 4300 (class 2604 OID 43984)
-- Dependencies: 317 275
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY horizonte ALTER COLUMN id SET DEFAULT nextval('horizonte_id_seq'::regclass);


--
-- TOC entry 4326 (class 2604 OID 43985)
-- Dependencies: 318 294
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inundabilidad ALTER COLUMN id SET DEFAULT nextval('inundabilidad_id_seq'::regclass);


--
-- TOC entry 4335 (class 2604 OID 43986)
-- Dependencies: 320 319
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inundacion ALTER COLUMN id SET DEFAULT nextval('inundacion_id_seq'::regclass);


--
-- TOC entry 4336 (class 2604 OID 43987)
-- Dependencies: 326 325
-- Name: id_l; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY leyenda_ini_ ALTER COLUMN id_l SET DEFAULT nextval('leyenda_ini__id_l_seq'::regclass);


--
-- TOC entry 4337 (class 2604 OID 43988)
-- Dependencies: 329 328
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY limitante_profundidad ALTER COLUMN id SET DEFAULT nextval('limitante_profundidad_id_seq'::regclass);


--
-- TOC entry 4338 (class 2604 OID 43989)
-- Dependencies: 331 330
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY localizacion ALTER COLUMN id SET DEFAULT nextval('localizacion_id_seq'::regclass);


--
-- TOC entry 4339 (class 2604 OID 43990)
-- Dependencies: 333 332
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY material_parental ALTER COLUMN id SET DEFAULT nextval('material_parental_id_seq'::regclass);


--
-- TOC entry 4340 (class 2604 OID 43991)
-- Dependencies: 335 334
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY nomenclatura ALTER COLUMN id SET DEFAULT nextval('nomenclatura_id_seq'::regclass);


--
-- TOC entry 4341 (class 2604 OID 43992)
-- Dependencies: 337 336
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY observacion ALTER COLUMN id SET DEFAULT nextval('observacion_id_seq'::regclass);


--
-- TOC entry 4342 (class 2604 OID 43993)
-- Dependencies: 339 338
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY paisaje ALTER COLUMN id SET DEFAULT nextval('paisaje_id_seq'::regclass);


--
-- TOC entry 4345 (class 2604 OID 43994)
-- Dependencies: 344 343
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pedregosidad ALTER COLUMN id SET DEFAULT nextval('pedregosidad_id_seq'::regclass);


--
-- TOC entry 4302 (class 2604 OID 43995)
-- Dependencies: 345 276
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pendiente ALTER COLUMN id SET DEFAULT nextval('pendiente_id_seq'::regclass);


--
-- TOC entry 4346 (class 2604 OID 43996)
-- Dependencies: 348 346
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY perfil ALTER COLUMN id SET DEFAULT nextval('perfil_id_seq'::regclass);


--
-- TOC entry 4306 (class 2604 OID 43997)
-- Dependencies: 349 277
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY perfil_simple ALTER COLUMN id SET DEFAULT nextval('perfil_simple_id_seq'::regclass);


--
-- TOC entry 4308 (class 2604 OID 43998)
-- Dependencies: 351 278
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY profundidad_efectiva ALTER COLUMN id SET DEFAULT nextval('profundidad_efectiva_id_seq'::regclass);


--
-- TOC entry 4347 (class 2604 OID 43999)
-- Dependencies: 353 352
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY quimica ALTER COLUMN id SET DEFAULT nextval('quimica_id_seq'::regclass);


--
-- TOC entry 4348 (class 2604 OID 44000)
-- Dependencies: 355 354
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY relieve ALTER COLUMN id SET DEFAULT nextval('relieve_id_seq'::regclass);


--
-- TOC entry 4349 (class 2604 OID 44001)
-- Dependencies: 359 357
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY salinidad ALTER COLUMN id SET DEFAULT nextval('salinidad_id_seq'::regclass);


--
-- TOC entry 4350 (class 2604 OID 44002)
-- Dependencies: 363 362
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY subclase_agrologica ALTER COLUMN id SET DEFAULT nextval('subclase_agrologica_id_seq'::regclass);


--
-- TOC entry 4351 (class 2604 OID 44003)
-- Dependencies: 377 376
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY suelos_variables ALTER COLUMN id SET DEFAULT nextval('suelos_variables_id_seq'::regclass);


--
-- TOC entry 4313 (class 2604 OID 44004)
-- Dependencies: 378 279
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY taxonomia ALTER COLUMN id SET DEFAULT nextval('taxonomia_id_seq'::regclass);


--
-- TOC entry 4327 (class 2604 OID 44005)
-- Dependencies: 379 295
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY textura ALTER COLUMN id SET DEFAULT nextval('textura_id_seq'::regclass);


--
-- TOC entry 4352 (class 2604 OID 44006)
-- Dependencies: 381 380
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tipo_observacion ALTER COLUMN id SET DEFAULT nextval('tipo_observacion_id_seq'::regclass);


--
-- TOC entry 4315 (class 2604 OID 44007)
-- Dependencies: 382 280
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY unidad_cartografica ALTER COLUMN id SET DEFAULT nextval('unidad_cartografica_id_seq'::regclass);


--
-- TOC entry 4353 (class 2604 OID 44008)
-- Dependencies: 384 383
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY unidad_cartografica_medicion ALTER COLUMN id SET DEFAULT nextval('unidad_cartografica_medicion_id_seq'::regclass);


--
-- TOC entry 4457 (class 2606 OID 59077)
-- Dependencies: 541 541 4484
-- Name: amazonas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY amazonas
    ADD CONSTRAINT amazonas_pkey PRIMARY KEY (gid);


--
-- TOC entry 4378 (class 2606 OID 44066)
-- Dependencies: 283 283 4484
-- Name: capacidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY capacidad
    ADD CONSTRAINT capacidad_pkey PRIMARY KEY (id);


--
-- TOC entry 4380 (class 2606 OID 44068)
-- Dependencies: 286 286 4484
-- Name: clase_agrologica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY clase_agrologica
    ADD CONSTRAINT clase_agrologica_pkey PRIMARY KEY (id);


--
-- TOC entry 4382 (class 2606 OID 44070)
-- Dependencies: 288 288 4484
-- Name: clima_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY clima
    ADD CONSTRAINT clima_pkey PRIMARY KEY (id);


--
-- TOC entry 4384 (class 2606 OID 44072)
-- Dependencies: 290 290 4484
-- Name: color_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY color
    ADD CONSTRAINT color_pkey PRIMARY KEY (id);


--
-- TOC entry 4394 (class 2606 OID 44074)
-- Dependencies: 297 297 4484
-- Name: descripcion_observacion_numero_observacion_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY descripcion_observacion
    ADD CONSTRAINT descripcion_observacion_numero_observacion_key UNIQUE (numero_observacion);


--
-- TOC entry 4396 (class 2606 OID 44076)
-- Dependencies: 297 297 4484
-- Name: descripcion_observacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY descripcion_observacion
    ADD CONSTRAINT descripcion_observacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4400 (class 2606 OID 44078)
-- Dependencies: 301 301 4484
-- Name: descriptor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY descriptor
    ADD CONSTRAINT descriptor_pkey PRIMARY KEY (id);


--
-- TOC entry 4358 (class 2606 OID 44080)
-- Dependencies: 273 273 4484
-- Name: drenaje_natural_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY drenaje_natural
    ADD CONSTRAINT drenaje_natural_pkey PRIMARY KEY (id);


--
-- TOC entry 4402 (class 2606 OID 44082)
-- Dependencies: 304 304 4484
-- Name: encharcamiento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY encharcamiento
    ADD CONSTRAINT encharcamiento_pkey PRIMARY KEY (id);


--
-- TOC entry 4386 (class 2606 OID 44084)
-- Dependencies: 292 292 4484
-- Name: erosion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY erosion
    ADD CONSTRAINT erosion_pkey PRIMARY KEY (id);


--
-- TOC entry 4404 (class 2606 OID 44086)
-- Dependencies: 307 307 4484
-- Name: estructura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY estructura
    ADD CONSTRAINT estructura_pkey PRIMARY KEY (id);


--
-- TOC entry 4360 (class 2606 OID 43371)
-- Dependencies: 274 274 4484
-- Name: fase_cartografica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY fase_cartografica
    ADD CONSTRAINT fase_cartografica_pkey PRIMARY KEY (id);


--
-- TOC entry 4388 (class 2606 OID 44088)
-- Dependencies: 293 293 4484
-- Name: fertilidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY fertilidad
    ADD CONSTRAINT fertilidad_pkey PRIMARY KEY (id);


--
-- TOC entry 4406 (class 2606 OID 44090)
-- Dependencies: 311 311 4484
-- Name: forma_terreno_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY forma_terreno
    ADD CONSTRAINT forma_terreno_pkey PRIMARY KEY (id);


--
-- TOC entry 4408 (class 2606 OID 44092)
-- Dependencies: 313 313 4484
-- Name: fuente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY fuente
    ADD CONSTRAINT fuente_pkey PRIMARY KEY (id);


--
-- TOC entry 4460 (class 2606 OID 60444)
-- Dependencies: 546 546 4484
-- Name: gp_antioquia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY gp_antioquia
    ADD CONSTRAINT gp_antioquia_pkey PRIMARY KEY (gid);


--
-- TOC entry 4362 (class 2606 OID 44096)
-- Dependencies: 275 275 4484
-- Name: horizonte_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY horizonte
    ADD CONSTRAINT horizonte_pkey PRIMARY KEY (id);


--
-- TOC entry 4366 (class 2606 OID 44098)
-- Dependencies: 277 277 4484
-- Name: id; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY perfil_simple
    ADD CONSTRAINT id PRIMARY KEY (id);


--
-- TOC entry 4418 (class 2606 OID 44100)
-- Dependencies: 327 327 4484
-- Name: id-ley; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY leyenda_nueva
    ADD CONSTRAINT "id-ley" PRIMARY KEY (id);


--
-- TOC entry 4398 (class 2606 OID 44102)
-- Dependencies: 299 299 4484
-- Name: id_desc; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY descripcion_perfil
    ADD CONSTRAINT id_desc PRIMARY KEY (id);


--
-- TOC entry 4412 (class 2606 OID 44104)
-- Dependencies: 321 321 4484
-- Name: id_letra; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY letra_horizonte
    ADD CONSTRAINT id_letra PRIMARY KEY (id);


--
-- TOC entry 4416 (class 2606 OID 44106)
-- Dependencies: 325 325 4484
-- Name: id_ley; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY leyenda_ini_
    ADD CONSTRAINT id_ley PRIMARY KEY (id_l);


--
-- TOC entry 4446 (class 2606 OID 44108)
-- Dependencies: 360 360 4484
-- Name: id_omitida; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY unidad_omitida
    ADD CONSTRAINT id_omitida PRIMARY KEY (id);


--
-- TOC entry 4432 (class 2606 OID 44110)
-- Dependencies: 340 340 4484
-- Name: id_par; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY suelos_paramos
    ADD CONSTRAINT id_par PRIMARY KEY (id);


--
-- TOC entry 4440 (class 2606 OID 44112)
-- Dependencies: 352 352 4484
-- Name: id_quimica; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY quimica
    ADD CONSTRAINT id_quimica PRIMARY KEY (id);


--
-- TOC entry 4450 (class 2606 OID 44114)
-- Dependencies: 376 376 4484
-- Name: idsuelos; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY suelos_variables
    ADD CONSTRAINT idsuelos PRIMARY KEY (id);


--
-- TOC entry 4390 (class 2606 OID 44116)
-- Dependencies: 294 294 4484
-- Name: inundabilidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY inundabilidad
    ADD CONSTRAINT inundabilidad_pkey PRIMARY KEY (id);


--
-- TOC entry 4410 (class 2606 OID 44118)
-- Dependencies: 319 319 4484
-- Name: inundacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY inundacion
    ADD CONSTRAINT inundacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4420 (class 2606 OID 44120)
-- Dependencies: 328 328 4484
-- Name: limitante_profundidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY limitante_profundidad
    ADD CONSTRAINT limitante_profundidad_pkey PRIMARY KEY (id);


--
-- TOC entry 4422 (class 2606 OID 44122)
-- Dependencies: 330 330 4484
-- Name: localizacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY localizacion
    ADD CONSTRAINT localizacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4424 (class 2606 OID 44124)
-- Dependencies: 332 332 4484
-- Name: material_parental_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY material_parental
    ADD CONSTRAINT material_parental_pkey PRIMARY KEY (id);


--
-- TOC entry 4426 (class 2606 OID 44126)
-- Dependencies: 334 334 4484
-- Name: nomenclatura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY nomenclatura
    ADD CONSTRAINT nomenclatura_pkey PRIMARY KEY (id);


--
-- TOC entry 4428 (class 2606 OID 44128)
-- Dependencies: 336 336 4484
-- Name: observacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY observacion
    ADD CONSTRAINT observacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4430 (class 2606 OID 44130)
-- Dependencies: 338 338 4484
-- Name: paisaje_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY paisaje
    ADD CONSTRAINT paisaje_pkey PRIMARY KEY (id);


--
-- TOC entry 4436 (class 2606 OID 44132)
-- Dependencies: 343 343 4484
-- Name: pedregosidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY pedregosidad
    ADD CONSTRAINT pedregosidad_pkey PRIMARY KEY (id);


--
-- TOC entry 4364 (class 2606 OID 44134)
-- Dependencies: 276 276 4484
-- Name: pendiente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY pendiente
    ADD CONSTRAINT pendiente_pkey PRIMARY KEY (id);


--
-- TOC entry 4438 (class 2606 OID 44136)
-- Dependencies: 346 346 4484
-- Name: perfil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY perfil
    ADD CONSTRAINT perfil_pkey PRIMARY KEY (id);


--
-- TOC entry 4368 (class 2606 OID 44138)
-- Dependencies: 277 277 277 4484
-- Name: perfil_unico_por_unidad_cartografica; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY perfil_simple
    ADD CONSTRAINT perfil_unico_por_unidad_cartografica UNIQUE (codigo, id_unidad_cartografica);


--
-- TOC entry 4370 (class 2606 OID 44140)
-- Dependencies: 278 278 4484
-- Name: profundidad_efectiva_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY profundidad_efectiva
    ADD CONSTRAINT profundidad_efectiva_pkey PRIMARY KEY (id);


--
-- TOC entry 4442 (class 2606 OID 44142)
-- Dependencies: 354 354 4484
-- Name: relieve_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY relieve
    ADD CONSTRAINT relieve_pkey PRIMARY KEY (id);


--
-- TOC entry 4444 (class 2606 OID 44144)
-- Dependencies: 357 357 4484
-- Name: salinidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY salinidad
    ADD CONSTRAINT salinidad_pkey PRIMARY KEY (id);


--
-- TOC entry 4374 (class 2606 OID 44146)
-- Dependencies: 280 280 4484
-- Name: sigla; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY unidad_cartografica
    ADD CONSTRAINT sigla UNIQUE (sigla);


--
-- TOC entry 4448 (class 2606 OID 44151)
-- Dependencies: 362 362 4484
-- Name: subclase_agrologica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY subclase_agrologica
    ADD CONSTRAINT subclase_agrologica_pkey PRIMARY KEY (id);


--
-- TOC entry 4372 (class 2606 OID 44153)
-- Dependencies: 279 279 4484
-- Name: taxonomia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY taxonomia
    ADD CONSTRAINT taxonomia_pkey PRIMARY KEY (id);


--
-- TOC entry 4392 (class 2606 OID 44156)
-- Dependencies: 295 295 4484
-- Name: textura_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY textura
    ADD CONSTRAINT textura_pkey PRIMARY KEY (id);


--
-- TOC entry 4452 (class 2606 OID 44158)
-- Dependencies: 380 380 4484
-- Name: tipo_observacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY tipo_observacion
    ADD CONSTRAINT tipo_observacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4434 (class 2606 OID 44161)
-- Dependencies: 342 342 4484
-- Name: ucs_perfil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY paso_ucs_perfil
    ADD CONSTRAINT ucs_perfil_pkey PRIMARY KEY (id);


--
-- TOC entry 4454 (class 2606 OID 44163)
-- Dependencies: 383 383 4484
-- Name: unidad_cartografica_medicion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY unidad_cartografica_medicion
    ADD CONSTRAINT unidad_cartografica_medicion_pkey PRIMARY KEY (id);


--
-- TOC entry 4376 (class 2606 OID 43364)
-- Dependencies: 280 280 4484
-- Name: unidad_cartografica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY unidad_cartografica
    ADD CONSTRAINT unidad_cartografica_pkey PRIMARY KEY (id);


--
-- TOC entry 4414 (class 2606 OID 44165)
-- Dependencies: 321 321 4484
-- Name: uniqueletra; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace:
--

ALTER TABLE ONLY letra_horizonte
    ADD CONSTRAINT uniqueletra UNIQUE (letra);


--
-- TOC entry 4455 (class 1259 OID 59148)
-- Dependencies: 3615 541 4484
-- Name: amazonas_geom_gist; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX amazonas_geom_gist ON amazonas USING gist (geom);


--
-- TOC entry 4458 (class 1259 OID 61617)
-- Dependencies: 546 3615 4484
-- Name: gp_antioquia_geom_gist; Type: INDEX; Schema: public; Owner: postgres; Tablespace:
--

CREATE INDEX gp_antioquia_geom_gist ON gp_antioquia USING gist (geom);


--
-- TOC entry 4206 (class 2618 OID 43368)
-- Dependencies: 275 275 276 276 277 277 277 278 278 279 279 279 279 279 279 279 279 280 280 280 280 280 280 280 280 280 280 288 288 290 307 4376 357 357 343 343 328 328 307 295 295 294 294 293 293 292 292 290 273 273 274 274 274 274 274 274 274 274 275 275 275 275 275 275 275 275 275 275 275 275 275 275 275 275 365 4484
-- Name: _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO suelo_completo_horizontes DO INSTEAD SELECT btrim((u.estudio)::text) AS estudio, f.id, btrim((u.sigla)::text) AS sim_nuevo, btrim((u.simbolo_antiguo)::text) AS simbolo_antiguo, btrim((u.nombre)::text) AS nombre, btrim((u.localizacion)::text) AS localizacion, btrim((u.paisaje)::text) AS paisaje, btrim((c.nombre)::text) AS clima, btrim((u.mat_parental)::text) AS btrim, btrim((u.fuente)::text) AS fuente, btrim((t.nombre)::text) AS taxonomia, btrim((ps.codigo)::text) AS perfil, t.p_representacion AS p_representc, btrim((f.simbolo)::text) AS fase, btrim((pe.descripcion)::text) AS profundidad, btrim((dn.descripcion)::text) AS drenaje_natural, btrim((ft.descripcion)::text) AS fertilidad, btrim((lp.descripcion)::text) AS limitante_profundidad, btrim((pd.descripcion)::text) AS pendiente, btrim((pg.descripcion)::text) AS pedregosidad, btrim((sl.descripcion)::text) AS salinidad, btrim((e.descripcion)::text) AS erosion, btrim((i.explicacion)::text) AS inundabilidad, btrim((h.nombre)::text) AS horizonte, btrim((te.descripcion)::text) AS textura, h.profundidad_inicial AS prof_inicial, h.profundidad_final AS prof_final, btrim((et.descripcion)::text) AS estructura, btrim((cl.nombre)::text) AS color, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f, clima c, horizonte h, profundidad_efectiva pe, drenaje_natural dn, fertilidad ft, limitante_profundidad lp, pendiente pd, pedregosidad pg, salinidad sl, erosion e, inundabilidad i, textura te, estructura et, color cl WHERE ((((((((((((((((((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) AND (t.id_profundidad_efectiva = pe.id)) AND (t.id_drenaje_natural = dn.id)) AND (t.id_fertilidad = ft.id)) AND (t.id_limitante_profundidad = lp.id)) AND (f.id_pendiente = pd.id)) AND (f.id_pedregosidad = pg.id)) AND (f.id_salinidad = sl.id)) AND (f.id_erosion = e.id)) AND (f.id_inundabilidad = i.id)) AND (h.id_unidad_cartografica = ps.id_unidad_cartografica)) AND (h.id_perfil = ps.id)) AND (h.id_textura = te.id)) AND (h.id_estructura = et.id)) AND (h.id_color = cl.id)) GROUP BY f.id, u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, ps.codigo, t.p_representacion, f.simbolo, pe.descripcion, dn.descripcion, h.nombre, u.id_clima, u.fuente, u.simbolo_antiguo, c.nombre, t.nombre, ft.descripcion, lp.descripcion, pd.descripcion, pg.descripcion, sl.descripcion, e.descripcion, i.explicacion, te.descripcion, h.profundidad_inicial, h.profundidad_final, et.descripcion, cl.nombre, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al ORDER BY u.sigla, ps.codigo, h.profundidad_inicial, h.profundidad_final;


--
-- TOC entry 4207 (class 2618 OID 43375)
-- Dependencies: 280 4360 357 357 343 343 328 328 307 307 295 295 294 294 293 293 292 292 290 290 288 288 280 280 276 280 280 280 280 273 273 274 274 274 274 274 274 274 274 275 275 275 275 275 275 275 275 275 275 275 275 275 275 275 275 275 275 276 280 280 279 279 279 279 279 279 279 279 278 278 277 277 277 366 4484
-- Name: _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE "_RETURN" AS ON SELECT TO suelo_variables_fao DO INSTEAD SELECT f.id, btrim((u.sigla)::text) AS sim_nuevo, btrim((u.simbolo_antiguo)::text) AS sim_anti, btrim((u.nombre)::text) AS nombre, btrim((u.localizacion)::text) AS localizacion, btrim((u.paisaje)::text) AS paisaje, btrim((c.nombre)::text) AS clima, btrim((u.mat_parental)::text) AS mat_parental, btrim((u.fuente)::text) AS fuente, btrim((t.nombre)::text) AS taxonomia, btrim((ps.codigo)::text) AS perfil, t.p_representacion, btrim((f.simbolo)::text) AS fase, pe.descripcion AS profundidad, dn.descripcion AS drenaje_natural, ft.descripcion AS fertilidad, lp.descripcion AS limitante_profundidad, pd.descripcion AS pendiente, pg.descripcion AS pedregosidad, sl.descripcion AS salinidad, e.descripcion AS erosion, i.explicacion AS inundabilidad, h.nombre AS horizonte, te.descripcion AS textura, h.profundidad_inicial, h.profundidad_final, et.descripcion AS estructura, cl.nombre AS color, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, h.sat_al FROM unidad_cartografica u, perfil_simple ps, taxonomia t, fase_cartografica f, clima c, horizonte h, profundidad_efectiva pe, drenaje_natural dn, fertilidad ft, limitante_profundidad lp, pendiente pd, pedregosidad pg, salinidad sl, erosion e, inundabilidad i, textura te, estructura et, color cl WHERE ((((((((((((((((((u.id = f.id_unidad_cartografica) AND (t.id_perfil = ps.id)) AND (u.id = t.id_unidad_cartografica)) AND (c.id = u.id_clima)) AND (t.id_profundidad_efectiva = pe.id)) AND (t.id_drenaje_natural = dn.id)) AND (t.id_fertilidad = ft.id)) AND (t.id_limitante_profundidad = lp.id)) AND (f.id_pendiente = pd.id)) AND (f.id_pedregosidad = pg.id)) AND (f.id_salinidad = sl.id)) AND (f.id_erosion = e.id)) AND (f.id_inundabilidad = i.id)) AND (h.id_unidad_cartografica = ps.id_unidad_cartografica)) AND (h.id_perfil = ps.id)) AND (h.id_textura = te.id)) AND (h.id_estructura = et.id)) AND (h.id_color = cl.id)) GROUP BY f.id, u.id, u.sigla, u.nombre, u.paisaje, u.mat_parental, u.localizacion, h.sat_al, u.id_clima, u.fuente, u.simbolo_antiguo, c.nombre, t.nombre, ft.descripcion, lp.descripcion, pd.descripcion, pg.descripcion, sl.descripcion, e.descripcion, i.explicacion, t.p_representacion, h.profundidad_inicial, h.profundidad_final, h.ph, h.cic, h.bt, h.sb, h.co, h.nt, h.pp, h.kc, h.ce, ps.codigo, pe.descripcion, dn.descripcion, h.nombre, te.descripcion, et.descripcion, cl.nombre ORDER BY f.id, u.id;


--
-- TOC entry 4260 (class 2618 OID 52779)
-- Dependencies: 530 530 530 4484
-- Name: geometry_columns_delete; Type: RULE; Schema: public; Owner: postgres
--

--CREATE RULE geometry_columns_delete AS ON DELETE TO geometry_columns DO INSTEAD NOTHING;


--
-- TOC entry 4258 (class 2618 OID 52777)
-- Dependencies: 530 530 530 4484
-- Name: geometry_columns_insert; Type: RULE; Schema: public; Owner: postgres
--

--CREATE RULE geometry_columns_insert AS ON INSERT TO geometry_columns DO INSTEAD NOTHING;


--
-- TOC entry 4259 (class 2618 OID 52778)
-- Dependencies: 530 530 530 4484
-- Name: geometry_columns_update; Type: RULE; Schema: public; Owner: postgres
--

--CREATE RULE geometry_columns_update AS ON UPDATE TO geometry_columns DO INSTEAD NOTHING;


--
-- TOC entry 4480 (class 2606 OID 44329)
-- Dependencies: 283 280 4375 4484
-- Name: capacidad_id_unidad_cartografica_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY capacidad
    ADD CONSTRAINT capacidad_id_unidad_cartografica_fkey FOREIGN KEY (id_unidad_cartografica) REFERENCES unidad_cartografica(id);


--
-- TOC entry 4461 (class 2606 OID 44334)
-- Dependencies: 274 292 4385 4484
-- Name: fase_cartografica_id_erosion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fase_cartografica
    ADD CONSTRAINT fase_cartografica_id_erosion_fkey FOREIGN KEY (id_erosion) REFERENCES erosion(id);


--
-- TOC entry 4462 (class 2606 OID 44339)
-- Dependencies: 274 294 4389 4484
-- Name: fase_cartografica_id_inundabilidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fase_cartografica
    ADD CONSTRAINT fase_cartografica_id_inundabilidad_fkey FOREIGN KEY (id_inundabilidad) REFERENCES inundabilidad(id);


--
-- TOC entry 4463 (class 2606 OID 44344)
-- Dependencies: 274 343 4435 4484
-- Name: fase_cartografica_id_pedregosidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fase_cartografica
    ADD CONSTRAINT fase_cartografica_id_pedregosidad_fkey FOREIGN KEY (id_pedregosidad) REFERENCES pedregosidad(id);


--
-- TOC entry 4464 (class 2606 OID 44349)
-- Dependencies: 274 276 4363 4484
-- Name: fase_cartografica_id_pendiente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fase_cartografica
    ADD CONSTRAINT fase_cartografica_id_pendiente_fkey FOREIGN KEY (id_pendiente) REFERENCES pendiente(id);


--
-- TOC entry 4465 (class 2606 OID 44354)
-- Dependencies: 274 357 4443 4484
-- Name: fase_cartografica_id_salinidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fase_cartografica
    ADD CONSTRAINT fase_cartografica_id_salinidad_fkey FOREIGN KEY (id_salinidad) REFERENCES salinidad(id);


--
-- TOC entry 4466 (class 2606 OID 44359)
-- Dependencies: 274 4375 280 4484
-- Name: fase_cartografica_id_unidad_cartografica_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fase_cartografica
    ADD CONSTRAINT fase_cartografica_id_unidad_cartografica_fkey FOREIGN KEY (id_unidad_cartografica) REFERENCES unidad_cartografica(id) ON DELETE CASCADE;


--
-- TOC entry 4467 (class 2606 OID 44364)
-- Dependencies: 275 290 4383 4484
-- Name: id_color; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY horizonte
    ADD CONSTRAINT id_color FOREIGN KEY (id_color) REFERENCES color(id);


--
-- TOC entry 4468 (class 2606 OID 44369)
-- Dependencies: 4403 275 307 4484
-- Name: id_estructura; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY horizonte
    ADD CONSTRAINT id_estructura FOREIGN KEY (id_estructura) REFERENCES estructura(id);


--
-- TOC entry 4481 (class 2606 OID 44374)
-- Dependencies: 346 342 4437 4484
-- Name: id_perfil; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY paso_ucs_perfil
    ADD CONSTRAINT id_perfil FOREIGN KEY (id_perfil) REFERENCES perfil(id);


--
-- TOC entry 4469 (class 2606 OID 44379)
-- Dependencies: 277 275 4365 4484
-- Name: id_perfil; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY horizonte
    ADD CONSTRAINT id_perfil FOREIGN KEY (id_perfil) REFERENCES perfil_simple(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4473 (class 2606 OID 44387)
-- Dependencies: 279 4365 277 4484
-- Name: id_perfil; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY taxonomia
    ADD CONSTRAINT id_perfil FOREIGN KEY (id_perfil) REFERENCES perfil_simple(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4470 (class 2606 OID 44392)
-- Dependencies: 295 275 4391 4484
-- Name: id_textura; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY horizonte
    ADD CONSTRAINT id_textura FOREIGN KEY (id_textura) REFERENCES textura(id);


--
-- TOC entry 4482 (class 2606 OID 44397)
-- Dependencies: 4375 342 280 4484
-- Name: id_ucs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY paso_ucs_perfil
    ADD CONSTRAINT id_ucs FOREIGN KEY (id) REFERENCES unidad_cartografica(id);


--
-- TOC entry 4471 (class 2606 OID 44405)
-- Dependencies: 280 275 4375 4484
-- Name: id_unidad_carto; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY horizonte
    ADD CONSTRAINT id_unidad_carto FOREIGN KEY (id_unidad_cartografica) REFERENCES unidad_cartografica(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4474 (class 2606 OID 44410)
-- Dependencies: 280 279 4375 4484
-- Name: id_unidad_taxonomia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY taxonomia
    ADD CONSTRAINT id_unidad_taxonomia FOREIGN KEY (id_unidad_cartografica) REFERENCES unidad_cartografica(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4472 (class 2606 OID 44415)
-- Dependencies: 280 4375 277 4484
-- Name: perfil_simple_unidad_cartografica; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY perfil_simple
    ADD CONSTRAINT perfil_simple_unidad_cartografica FOREIGN KEY (id_unidad_cartografica) REFERENCES unidad_cartografica(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4475 (class 2606 OID 44420)
-- Dependencies: 273 279 4357 4484
-- Name: taxonomia_id_drenaje_natural_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY taxonomia
    ADD CONSTRAINT taxonomia_id_drenaje_natural_fkey FOREIGN KEY (id_drenaje_natural) REFERENCES drenaje_natural(id);


--
-- TOC entry 4476 (class 2606 OID 44426)
-- Dependencies: 279 4387 293 4484
-- Name: taxonomia_id_fertilidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY taxonomia
    ADD CONSTRAINT taxonomia_id_fertilidad_fkey FOREIGN KEY (id_fertilidad) REFERENCES fertilidad(id);


--
-- TOC entry 4477 (class 2606 OID 44431)
-- Dependencies: 4419 279 328 4484
-- Name: taxonomia_id_limitante_profundidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY taxonomia
    ADD CONSTRAINT taxonomia_id_limitante_profundidad_fkey FOREIGN KEY (id_limitante_profundidad) REFERENCES limitante_profundidad(id);


--
-- TOC entry 4478 (class 2606 OID 44436)
-- Dependencies: 278 279 4369 4484
-- Name: taxonomia_id_profundidad_efectiva_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY taxonomia
    ADD CONSTRAINT taxonomia_id_profundidad_efectiva_fkey FOREIGN KEY (id_profundidad_efectiva) REFERENCES profundidad_efectiva(id);


--
-- TOC entry 4479 (class 2606 OID 44441)
-- Dependencies: 288 280 4381 4484
-- Name: unidad_cartografica_id_clima_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY unidad_cartografica
    ADD CONSTRAINT unidad_cartografica_id_clima_fkey FOREIGN KEY (id_clima) REFERENCES clima(id);


--
-- TOC entry 4488 (class 0 OID 0)
-- Dependencies: 8
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2019-11-29 15:21:20

--
-- PostgreSQL database dump complete
--

