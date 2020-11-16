--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.0
-- Dumped by pg_dump version 9.5.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: equipment; Type: TABLE; Schema: public; Owner: adam9500
--

CREATE TABLE equipment (
    id uuid NOT NULL,
    crit_slots integer NOT NULL,
    damage character varying(255),
    heat integer NOT NULL,
    long_range integer NOT NULL,
    medium_range integer NOT NULL,
    min_range integer NOT NULL,
    name character varying(255),
    short_range integer NOT NULL,
    tech character varying(255),
    tonnage double precision NOT NULL
);


ALTER TABLE equipment OWNER TO adam9500;

--
-- Name: equipment_slang; Type: TABLE; Schema: public; Owner: adam9500
--

CREATE TABLE equipment_slang (
    id uuid NOT NULL,
    slang character varying(255) NOT NULL,
    equipment_id uuid
);


ALTER TABLE equipment_slang OWNER TO adam9500;

--
-- Name: unit; Type: TABLE; Schema: public; Owner: adam9500
--

CREATE TABLE unit (
    dtype character varying(31) NOT NULL,
    id uuid NOT NULL,
    designation character varying(255),
    era character varying(255),
    bonus_jump integer NOT NULL,
    jump integer NOT NULL,
    potential_run integer NOT NULL,
    potential_walk integer NOT NULL,
    run integer NOT NULL,
    walk integer NOT NULL,
    name character varying(255),
    omni boolean NOT NULL,
    rules_level integer NOT NULL,
    tech character varying(255),
    weight integer NOT NULL,
    weight_class character varying(255),
    ejection character varying(255),
    engine character varying(255),
    heatsink_quantity integer,
    tech_type integer,
    type integer,
    locomotion character varying(255),
    myomer character varying(255),
    structure character varying(255)
);


ALTER TABLE unit OWNER TO adam9500;

--
-- Name: unit_equipment; Type: TABLE; Schema: public; Owner: adam9500
--

CREATE TABLE unit_equipment (
    id uuid NOT NULL,
    location character varying(255),
    omni_pod boolean NOT NULL,
    rear_facing boolean NOT NULL,
    tonnage double precision NOT NULL,
    turret_equipped boolean NOT NULL,
    equipment_id uuid
);


ALTER TABLE unit_equipment OWNER TO adam9500;

--
-- Name: unit_mech_equipment; Type: TABLE; Schema: public; Owner: adam9500
--

CREATE TABLE unit_mech_equipment (
    unit_id uuid NOT NULL,
    mech_equipment_id uuid NOT NULL
);


ALTER TABLE unit_mech_equipment OWNER TO adam9500;

--
-- Name: equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: adam9500
--

ALTER TABLE ONLY equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (id);


--
-- Name: equipment_slang_pkey; Type: CONSTRAINT; Schema: public; Owner: adam9500
--

ALTER TABLE ONLY equipment_slang
    ADD CONSTRAINT equipment_slang_pkey PRIMARY KEY (id);




--
-- Name: uk_89umw8ua53wlpvswm50m9go5i; Type: CONSTRAINT; Schema: public; Owner: adam9500
--

ALTER TABLE ONLY unit_mech_equipment
    ADD CONSTRAINT uk_89umw8ua53wlpvswm50m9go5i UNIQUE (mech_equipment_id);


--
-- Name: unit_equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: adam9500
--

ALTER TABLE ONLY unit_equipment
    ADD CONSTRAINT unit_equipment_pkey PRIMARY KEY (id);


--
-- Name: unit_pkey; Type: CONSTRAINT; Schema: public; Owner: adam9500
--

ALTER TABLE ONLY unit
    ADD CONSTRAINT unit_pkey PRIMARY KEY (id);


--
-- Name: fk5e1jg1gx7db73v91hhjf7egcb; Type: FK CONSTRAINT; Schema: public; Owner: adam9500
--

ALTER TABLE ONLY unit_mech_equipment
    ADD CONSTRAINT fk5e1jg1gx7db73v91hhjf7egcb FOREIGN KEY (unit_id) REFERENCES unit(id);


--
-- Name: fkb682ludyjwk3pi53d00o7gfrv; Type: FK CONSTRAINT; Schema: public; Owner: adam9500
--

ALTER TABLE ONLY unit_equipment
    ADD CONSTRAINT fkb682ludyjwk3pi53d00o7gfrv FOREIGN KEY (equipment_id) REFERENCES equipment(id);


--
-- Name: fkj61ca9hrr6hmgd50g1g1t5e46; Type: FK CONSTRAINT; Schema: public; Owner: adam9500
--

ALTER TABLE ONLY equipment_slang
    ADD CONSTRAINT fkj61ca9hrr6hmgd50g1g1t5e46 FOREIGN KEY (equipment_id) REFERENCES equipment(id);


--
-- Name: fkoopktr71p46fydfio2mi2qo1e; Type: FK CONSTRAINT; Schema: public; Owner: adam9500
--

ALTER TABLE ONLY unit_mech_equipment
    ADD CONSTRAINT fkoopktr71p46fydfio2mi2qo1e FOREIGN KEY (mech_equipment_id) REFERENCES unit_equipment(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

