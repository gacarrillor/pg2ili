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
    role_a bigint
);


ALTER TABLE _1_1_01.b OWNER TO postgres;


ALTER TABLE ONLY _1_1_01.b
    ADD CONSTRAINT b_role_a_fkey FOREIGN KEY (role_a) REFERENCES _1_1_01.a(t_id) DEFERRABLE INITIALLY DEFERRED;
