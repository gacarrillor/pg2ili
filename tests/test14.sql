
CREATE TABLE qgep_od.drainage_system (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'drainage_system'::text) NOT NULL,
    kind integer,
    perimeter_geometry public.geometry(CurvePolygon,2056)
);

CREATE TABLE qgep_sys.value_list_base (
    code integer NOT NULL,
    vsacode integer NOT NULL,
    value_en character varying(50),
    value_de character varying(50),
    value_fr character varying(50),
    value_it character varying(60),
    value_ro character varying(50),
    abbr_en character varying(3),
    abbr_de character varying(3),
    abbr_fr character varying(3),
    abbr_it character varying(3),
    abbr_ro character varying(3),
    active boolean
);

CREATE TABLE qgep_vl.drainage_system_kind (
)
INHERITS (qgep_sys.value_list_base);

CREATE TABLE qgep_vl.drainage_system_kind2 (
    active integer NOT NULL
)
INHERITS (qgep_sys.value_list_base);

CREATE TABLE simple (
    id integer NOT NULL
)

CREATE TABLE qgep_od.zone (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'zone'::text) NOT NULL,
    identifier character varying(20),
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16)
);


--ALTER TABLE ONLY qgep_sys.value_list_base
--    ADD CONSTRAINT any_pkey PRIMARY KEY (code);

ALTER TABLE ONLY qgep_sys.value_list_base
    ADD CONSTRAINT any_name UNIQUE (code, vsacode);

ALTER TABLE ONLY qgep_vl.drainage_system_kind2 ADD CONSTRAINT any_name2 UNIQUE (active);

ALTER TABLE ONLY qgep_sys.value_list_base
    ADD CONSTRAINT fkey_vl_any FOREIGN KEY (vsacode) REFERENCES simple(id) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE ONLY qgep_od.drainage_system
    ADD CONSTRAINT fkey_vl_drainage_system_kind FOREIGN KEY (kind) REFERENCES qgep_vl.drainage_system_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE ONLY qgep_od.drainage_system
    ADD CONSTRAINT oorel_od_drainage_system_zone FOREIGN KEY (obj_id) REFERENCES qgep_od.zone(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;