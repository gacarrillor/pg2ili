--
-- PostgreSQL database dump
--

-- Dumped from database version 10.9 (Ubuntu 10.9-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.9 (Ubuntu 10.9-0ubuntu0.18.04.1)

-- Started on 2019-12-07 21:53:34 -05

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

--
-- TOC entry 8 (class 2615 OID 314660)
-- Name: _1_1_01; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA _1_1_01;


ALTER SCHEMA _1_1_01 OWNER TO postgres;

--
-- TOC entry 572 (class 1259 OID 314661)
-- Name: t_ili2db_seq; Type: SEQUENCE; Schema: _1_1_01; Owner: postgres
--

CREATE SEQUENCE _1_1_01.t_ili2db_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE _1_1_01.t_ili2db_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 573 (class 1259 OID 314663)
-- Name: a; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.a (
    t_id bigint DEFAULT nextval('_1_1_01.t_ili2db_seq'::regclass) NOT NULL,
    t_ili_tid character varying(200)
);


ALTER TABLE _1_1_01.a OWNER TO postgres;

--
-- TOC entry 574 (class 1259 OID 314669)
-- Name: b; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.b (
    t_id bigint DEFAULT nextval('_1_1_01.t_ili2db_seq'::regclass) NOT NULL,
    t_ili_tid character varying(200),
    role_a bigint NOT NULL
);


ALTER TABLE _1_1_01.b OWNER TO postgres;

--
-- TOC entry 582 (class 1259 OID 314728)
-- Name: t_ili2db_attrname; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.t_ili2db_attrname (
    iliname character varying(1024) NOT NULL,
    sqlname character varying(1024) NOT NULL,
    colowner character varying(1024) NOT NULL,
    target character varying(1024)
);


ALTER TABLE _1_1_01.t_ili2db_attrname OWNER TO postgres;

--
-- TOC entry 575 (class 1259 OID 314676)
-- Name: t_ili2db_basket; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.t_ili2db_basket (
    t_id bigint NOT NULL,
    dataset bigint,
    topic character varying(200) NOT NULL,
    t_ili_tid character varying(200),
    attachmentkey character varying(200) NOT NULL,
    domains character varying(1024)
);


ALTER TABLE _1_1_01.t_ili2db_basket OWNER TO postgres;

--
-- TOC entry 581 (class 1259 OID 314720)
-- Name: t_ili2db_classname; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.t_ili2db_classname (
    iliname character varying(1024) NOT NULL,
    sqlname character varying(1024) NOT NULL
);


ALTER TABLE _1_1_01.t_ili2db_classname OWNER TO postgres;

--
-- TOC entry 583 (class 1259 OID 314736)
-- Name: t_ili2db_column_prop; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.t_ili2db_column_prop (
    tablename character varying(255) NOT NULL,
    subtype character varying(255),
    columnname character varying(255) NOT NULL,
    tag character varying(1024) NOT NULL,
    setting character varying(1024) NOT NULL
);


ALTER TABLE _1_1_01.t_ili2db_column_prop OWNER TO postgres;

--
-- TOC entry 576 (class 1259 OID 314685)
-- Name: t_ili2db_dataset; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.t_ili2db_dataset (
    t_id bigint NOT NULL,
    datasetname character varying(200)
);


ALTER TABLE _1_1_01.t_ili2db_dataset OWNER TO postgres;

--
-- TOC entry 577 (class 1259 OID 314690)
-- Name: t_ili2db_inheritance; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.t_ili2db_inheritance (
    thisclass character varying(1024) NOT NULL,
    baseclass character varying(1024)
);


ALTER TABLE _1_1_01.t_ili2db_inheritance OWNER TO postgres;

--
-- TOC entry 585 (class 1259 OID 314748)
-- Name: t_ili2db_meta_attrs; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.t_ili2db_meta_attrs (
    ilielement character varying(255) NOT NULL,
    attr_name character varying(1024) NOT NULL,
    attr_value character varying(1024) NOT NULL
);


ALTER TABLE _1_1_01.t_ili2db_meta_attrs OWNER TO postgres;

--
-- TOC entry 580 (class 1259 OID 314712)
-- Name: t_ili2db_model; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.t_ili2db_model (
    filename character varying(250) NOT NULL,
    iliversion character varying(3) NOT NULL,
    modelname text NOT NULL,
    content text NOT NULL,
    importdate timestamp without time zone NOT NULL
);


ALTER TABLE _1_1_01.t_ili2db_model OWNER TO postgres;

--
-- TOC entry 578 (class 1259 OID 314698)
-- Name: t_ili2db_settings; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.t_ili2db_settings (
    tag character varying(60) NOT NULL,
    setting character varying(1024)
);


ALTER TABLE _1_1_01.t_ili2db_settings OWNER TO postgres;

--
-- TOC entry 584 (class 1259 OID 314742)
-- Name: t_ili2db_table_prop; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.t_ili2db_table_prop (
    tablename character varying(255) NOT NULL,
    tag character varying(1024) NOT NULL,
    setting character varying(1024) NOT NULL
);


ALTER TABLE _1_1_01.t_ili2db_table_prop OWNER TO postgres;

--
-- TOC entry 579 (class 1259 OID 314706)
-- Name: t_ili2db_trafo; Type: TABLE; Schema: _1_1_01; Owner: postgres
--

CREATE TABLE _1_1_01.t_ili2db_trafo (
    iliname character varying(1024) NOT NULL,
    tag character varying(1024) NOT NULL,
    setting character varying(1024) NOT NULL
);


ALTER TABLE _1_1_01.t_ili2db_trafo OWNER TO postgres;

--
-- TOC entry 5697 (class 0 OID 314663)
-- Dependencies: 573
-- Data for Name: a; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.a (t_id, t_ili_tid) FROM stdin;
1	\N
3	\N
\.


--
-- TOC entry 5698 (class 0 OID 314669)
-- Dependencies: 574
-- Data for Name: b; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.b (t_id, t_ili_tid, role_a) FROM stdin;
2	\N	1
4	\N	1
\.


--
-- TOC entry 5706 (class 0 OID 314728)
-- Dependencies: 582
-- Data for Name: t_ili2db_attrname; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.t_ili2db_attrname (iliname, sqlname, colowner, target) FROM stdin;
ModelDef4.TopicDef5.uno_uno.role_a	role_a	b	a
\.


--
-- TOC entry 5699 (class 0 OID 314676)
-- Dependencies: 575
-- Data for Name: t_ili2db_basket; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.t_ili2db_basket (t_id, dataset, topic, t_ili_tid, attachmentkey, domains) FROM stdin;
\.


--
-- TOC entry 5705 (class 0 OID 314720)
-- Dependencies: 581
-- Data for Name: t_ili2db_classname; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.t_ili2db_classname (iliname, sqlname) FROM stdin;
ModelDef4.TopicDef5.A	a
ModelDef4.TopicDef5.B	b
ModelDef4.TopicDef5.uno_uno	uno_uno
\.


--
-- TOC entry 5707 (class 0 OID 314736)
-- Dependencies: 583
-- Data for Name: t_ili2db_column_prop; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.t_ili2db_column_prop (tablename, subtype, columnname, tag, setting) FROM stdin;
b	\N	role_a	ch.ehi.ili2db.foreignKey	a
\.


--
-- TOC entry 5700 (class 0 OID 314685)
-- Dependencies: 576
-- Data for Name: t_ili2db_dataset; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.t_ili2db_dataset (t_id, datasetname) FROM stdin;
\.


--
-- TOC entry 5701 (class 0 OID 314690)
-- Dependencies: 577
-- Data for Name: t_ili2db_inheritance; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.t_ili2db_inheritance (thisclass, baseclass) FROM stdin;
ModelDef4.TopicDef5.A	\N
ModelDef4.TopicDef5.B	\N
ModelDef4.TopicDef5.uno_uno	\N
\.


--
-- TOC entry 5709 (class 0 OID 314748)
-- Dependencies: 585
-- Data for Name: t_ili2db_meta_attrs; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.t_ili2db_meta_attrs (ilielement, attr_name, attr_value) FROM stdin;
\.


--
-- TOC entry 5704 (class 0 OID 314712)
-- Dependencies: 580
-- Data for Name: t_ili2db_model; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.t_ili2db_model (filename, iliversion, modelname, content, importdate) FROM stdin;
INTERLIS2Def3.ili	2.3	ModelDef4	INTERLIS 2.3;\n\nMODEL ModelDef4 (en)\nAT "mailto:germap@localhost"\nVERSION "2019-12-07"  =\n\n  TOPIC TopicDef5 =\n\n    CLASS A =\n    END A;\n\n    CLASS B =\n    END B;\n\n    ASSOCIATION uno_uno =\n      role_a -- {1} A;\n      role_b -- {1} B;\n    END uno_uno;\n\n  END TopicDef5;\n\nEND ModelDef4.\n	2019-12-07 21:50:58.402
\.


--
-- TOC entry 5702 (class 0 OID 314698)
-- Dependencies: 578
-- Data for Name: t_ili2db_settings; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.t_ili2db_settings (tag, setting) FROM stdin;
ch.ehi.ili2db.createMetaInfo	True
ch.ehi.ili2db.beautifyEnumDispName	underscore
ch.ehi.ili2db.arrayTrafo	coalesce
ch.ehi.ili2db.localisedTrafo	expand
ch.ehi.ili2db.numericCheckConstraints	create
ch.ehi.ili2db.sender	ili2pg-4.3.2-70c2c19de9928155e48437dedb68f5eef82896a7
ch.ehi.ili2db.createForeignKey	yes
ch.ehi.sqlgen.createGeomIndex	True
ch.ehi.ili2db.defaultSrsAuthority	EPSG
ch.ehi.ili2db.defaultSrsCode	3116
ch.ehi.ili2db.uuidDefaultValue	uuid_generate_v4()
ch.ehi.ili2db.StrokeArcs	enable
ch.ehi.ili2db.multiLineTrafo	coalesce
ch.interlis.ili2c.ilidirs	/docs/tr/stgeo/agrología/modelo_cvc;/docs/dev/LADM_COL-ladmcol2_9_6/Ordenamiento_Territorial;/docs/dev/LADM_COL-ladmcol2_9_6/Sistema_Parques_Nacionales_Naturales;/docs/dev/LADM_COL-ladmcol2_9_6/Catastro_Multiproposito/Operacion;/docs/dev/LADM_COL-ladmcol2_9_6/ISO;/docs/dev/LADM_COL-ladmcol2_9_6/Condicion_Amenaza_Riesgo;/docs/dev/LADM_COL-ladmcol2_9_6/tools;/docs/dev/LADM_COL-ladmcol2_9_6/Reservas_Ley_Segunda;/docs/dev/LADM_COL2/Ordenamiento_Territorial;/docs/dev/LADM_COL2/Sistema_Parques_Nacionales_Naturales;/docs/dev/LADM_COL2/Catastro_Multiproposito;/docs/dev/LADM_COL2/Catastro_Multiproposito/legacy;/docs/dev/LADM_COL2/Catastro_Multiproposito/Util;/docs/dev/LADM_COL2/ISO;/docs/dev/LADM_COL2/Condicion_Amenaza_Riesgo;/docs/dev/LADM_COL2/tools;/docs/tr/ai/productos/foss4g2019/workshop/models;/docs/tr/ai/productos/claeis_role_name_M_M;/docs/dev/AppendFeaturesToLayer/
ch.ehi.ili2db.TidHandling	property
ch.ehi.ili2db.createForeignKeyIndex	yes
ch.ehi.ili2db.jsonTrafo	coalesce
ch.ehi.ili2db.createEnumDefs	multiTableWithId
ch.ehi.ili2db.uniqueConstraints	create
ch.ehi.ili2db.maxSqlNameLength	60
ch.ehi.ili2db.inheritanceTrafo	smart2
ch.ehi.ili2db.catalogueRefTrafo	coalesce
ch.ehi.ili2db.multiPointTrafo	coalesce
ch.ehi.ili2db.multiSurfaceTrafo	coalesce
ch.ehi.ili2db.multilingualTrafo	expand
\.


--
-- TOC entry 5708 (class 0 OID 314742)
-- Dependencies: 584
-- Data for Name: t_ili2db_table_prop; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.t_ili2db_table_prop (tablename, tag, setting) FROM stdin;
a	ch.ehi.ili2db.tableKind	CLASS
b	ch.ehi.ili2db.tableKind	CLASS
\.


--
-- TOC entry 5703 (class 0 OID 314706)
-- Dependencies: 579
-- Data for Name: t_ili2db_trafo; Type: TABLE DATA; Schema: _1_1_01; Owner: postgres
--

COPY _1_1_01.t_ili2db_trafo (iliname, tag, setting) FROM stdin;
ModelDef4.TopicDef5.A	ch.ehi.ili2db.inheritance	newAndSubClass
ModelDef4.TopicDef5.B	ch.ehi.ili2db.inheritance	newAndSubClass
ModelDef4.TopicDef5.uno_uno	ch.ehi.ili2db.inheritance	embedded
\.


--
-- TOC entry 5715 (class 0 OID 0)
-- Dependencies: 572
-- Name: t_ili2db_seq; Type: SEQUENCE SET; Schema: _1_1_01; Owner: postgres
--

SELECT pg_catalog.setval('_1_1_01.t_ili2db_seq', 4, true);


--
-- TOC entry 5544 (class 2606 OID 314668)
-- Name: a a_pkey; Type: CONSTRAINT; Schema: _1_1_01; Owner: postgres
--

ALTER TABLE ONLY _1_1_01.a
    ADD CONSTRAINT a_pkey PRIMARY KEY (t_id);


--
-- TOC entry 5546 (class 2606 OID 314674)
-- Name: b b_pkey; Type: CONSTRAINT; Schema: _1_1_01; Owner: postgres
--

ALTER TABLE ONLY _1_1_01.b
    ADD CONSTRAINT b_pkey PRIMARY KEY (t_id);


--
-- TOC entry 5564 (class 2606 OID 314735)
-- Name: t_ili2db_attrname t_ili2db_attrname_pkey; Type: CONSTRAINT; Schema: _1_1_01; Owner: postgres
--

ALTER TABLE ONLY _1_1_01.t_ili2db_attrname
    ADD CONSTRAINT t_ili2db_attrname_pkey PRIMARY KEY (sqlname, colowner);


--
-- TOC entry 5550 (class 2606 OID 314683)
-- Name: t_ili2db_basket t_ili2db_basket_pkey; Type: CONSTRAINT; Schema: _1_1_01; Owner: postgres
--

ALTER TABLE ONLY _1_1_01.t_ili2db_basket
    ADD CONSTRAINT t_ili2db_basket_pkey PRIMARY KEY (t_id);


--
-- TOC entry 5562 (class 2606 OID 314727)
-- Name: t_ili2db_classname t_ili2db_classname_pkey; Type: CONSTRAINT; Schema: _1_1_01; Owner: postgres
--

ALTER TABLE ONLY _1_1_01.t_ili2db_classname
    ADD CONSTRAINT t_ili2db_classname_pkey PRIMARY KEY (iliname);


--
-- TOC entry 5553 (class 2606 OID 314689)
-- Name: t_ili2db_dataset t_ili2db_dataset_pkey; Type: CONSTRAINT; Schema: _1_1_01; Owner: postgres
--

ALTER TABLE ONLY _1_1_01.t_ili2db_dataset
    ADD CONSTRAINT t_ili2db_dataset_pkey PRIMARY KEY (t_id);


--
-- TOC entry 5555 (class 2606 OID 314697)
-- Name: t_ili2db_inheritance t_ili2db_inheritance_pkey; Type: CONSTRAINT; Schema: _1_1_01; Owner: postgres
--

ALTER TABLE ONLY _1_1_01.t_ili2db_inheritance
    ADD CONSTRAINT t_ili2db_inheritance_pkey PRIMARY KEY (thisclass);


--
-- TOC entry 5560 (class 2606 OID 314719)
-- Name: t_ili2db_model t_ili2db_model_pkey; Type: CONSTRAINT; Schema: _1_1_01; Owner: postgres
--

ALTER TABLE ONLY _1_1_01.t_ili2db_model
    ADD CONSTRAINT t_ili2db_model_pkey PRIMARY KEY (iliversion, modelname);


--
-- TOC entry 5557 (class 2606 OID 314705)
-- Name: t_ili2db_settings t_ili2db_settings_pkey; Type: CONSTRAINT; Schema: _1_1_01; Owner: postgres
--

ALTER TABLE ONLY _1_1_01.t_ili2db_settings
    ADD CONSTRAINT t_ili2db_settings_pkey PRIMARY KEY (tag);


--
-- TOC entry 5547 (class 1259 OID 314675)
-- Name: b_role_a_idx; Type: INDEX; Schema: _1_1_01; Owner: postgres
--

CREATE INDEX b_role_a_idx ON _1_1_01.b USING btree (role_a);


--
-- TOC entry 5565 (class 1259 OID 314766)
-- Name: t_ili2db_attrname_sqlname_colowner_key; Type: INDEX; Schema: _1_1_01; Owner: postgres
--

CREATE UNIQUE INDEX t_ili2db_attrname_sqlname_colowner_key ON _1_1_01.t_ili2db_attrname USING btree (sqlname, colowner);


--
-- TOC entry 5548 (class 1259 OID 314684)
-- Name: t_ili2db_basket_dataset_idx; Type: INDEX; Schema: _1_1_01; Owner: postgres
--

CREATE INDEX t_ili2db_basket_dataset_idx ON _1_1_01.t_ili2db_basket USING btree (dataset);


--
-- TOC entry 5551 (class 1259 OID 314764)
-- Name: t_ili2db_dataset_datasetname_key; Type: INDEX; Schema: _1_1_01; Owner: postgres
--

CREATE UNIQUE INDEX t_ili2db_dataset_datasetname_key ON _1_1_01.t_ili2db_dataset USING btree (datasetname);


--
-- TOC entry 5558 (class 1259 OID 314765)
-- Name: t_ili2db_model_iliversion_modelname_key; Type: INDEX; Schema: _1_1_01; Owner: postgres
--

CREATE UNIQUE INDEX t_ili2db_model_iliversion_modelname_key ON _1_1_01.t_ili2db_model USING btree (iliversion, modelname);


--
-- TOC entry 5566 (class 2606 OID 314754)
-- Name: b b_role_a_fkey; Type: FK CONSTRAINT; Schema: _1_1_01; Owner: postgres
--

ALTER TABLE ONLY _1_1_01.b
    ADD CONSTRAINT b_role_a_fkey UNIQUE (role_a);

ALTER TABLE ONLY _1_1_01.b
    ADD CONSTRAINT b_role_a_fkey FOREIGN KEY (role_a) REFERENCES _1_1_01.a(t_id) DEFERRABLE INITIALLY DEFERRED;


--
-- TOC entry 5567 (class 2606 OID 314759)
-- Name: t_ili2db_basket t_ili2db_basket_dataset_fkey; Type: FK CONSTRAINT; Schema: _1_1_01; Owner: postgres
--

ALTER TABLE ONLY _1_1_01.t_ili2db_basket
    ADD CONSTRAINT t_ili2db_basket_dataset_fkey FOREIGN KEY (dataset) REFERENCES _1_1_01.t_ili2db_dataset(t_id) DEFERRABLE INITIALLY DEFERRED;


-- Completed on 2019-12-07 21:53:34 -05

--
-- PostgreSQL database dump complete
--
