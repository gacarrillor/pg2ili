CREATE TABLE a (
    id integer NOT NULL,
    any_value numeric(10, 2)
);

CREATE TABLE b (
    id bigint NOT NULL,
    polygon_id integer NOT NULL
);

CREATE TABLE polygons (
    id integer NOT NULL,
    geom geometry(MultiPolygonZ,4326) NOT NULL
);

CREATE TABLE intermediate_table (
    id integer NOT NULL,
    role_a integer,
    role_b integer,
    name character varying(12)
);

ALTER TABLE ONLY public.a
    ADD CONSTRAINT a_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.b
    ADD CONSTRAINT b_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.polygons
    ADD CONSTRAINT polygons_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.intermediate_table
    ADD CONSTRAINT intermediate_table_pkey PRIMARY KEY (id);

ALTER TABLE ONLY b
    ADD CONSTRAINT polygon_id_b_unique UNIQUE (polygon_id);

ALTER TABLE ONLY b
    ADD CONSTRAINT b_polygon_id_fkey FOREIGN KEY (polygon_id) REFERENCES public.polygons(id);

ALTER TABLE ONLY public.intermediate_table
    ADD CONSTRAINT intermediate_table_role_a_fkey FOREIGN KEY (role_a) REFERENCES public.a(id);

ALTER TABLE ONLY public.intermediate_table
    ADD CONSTRAINT intermediate_table_role_b_fkey FOREIGN KEY (role_b) REFERENCES public.b(id);
--
-- PostgreSQL database dump complete
--