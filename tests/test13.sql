--

CREATE TABLE clima (
    id integer NOT NULL,
    nombre character(100) NOT NULL,
    geom public.geometry(MultiPolygonZ,4326) NOT NULL
);

