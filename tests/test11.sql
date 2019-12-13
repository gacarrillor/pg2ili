CREATE TABLE c_r_2_2_1.construccion (
    t_id bigint DEFAULT nextval('c_r_2_2_1.t_ili2db_seq'::regclass) NOT NULL,
    t_ili_tid character varying(200),
    avaluo1 numeric(7,2) NOT NULL,
    avaluo2 numeric(7, 2),
    avaluo3 numeric(5) NOT NULL,
    avaluo4 numeric NOT NULL,
    tipo bigint,
    comienzo_vida_util_version timestamp without time zone NOT NULL,
    fin_vida_util_version timestamp without time zone,
    CONSTRAINT construccion_avaluo_construccion_check CHECK (((avaluo_construccion >= 0.0) AND (avaluo_construccion <= '999999999999999'::numeric)))
);