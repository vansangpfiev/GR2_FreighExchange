--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

--
-- Name: check_category(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_category() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE category_id1 int;
DECLARE category_id2 int;
BEGIN
	category_id1 = (SELECT v.category_id
	FROM vehicle AS v 
	INNER JOIN trip AS t
	ON v.vehicle_id = t.vehicle_id
	WHERE t.trip_id = NEW.trip_id);

	category_id2 = (SELECT ab.category_id
	FROM abstract_trip AS ab
	INNER JOIN trip AS t
	ON ab.ab_trip_id = t.ab_trip_id
	WHERE t.trip_id = NEW.trip_id);

	IF(category_id1 <> category_id2) THEN
		 RAISE EXCEPTION 'trip has different categories %, %', category_id1, category_id2;
	END IF;
	RETURN NEW;
END;
$$;


--
-- Name: check_point(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_point() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE count1 int;

DECLARE point1 int;

BEGIN
	IF(NEW.sequent > 1) THEN
		count1 = NEW.sequent - 1;
	
		point1 = (SELECT ab.end_point
		FROM abstract_trip AS ab 
		INNER JOIN trip AS t
		ON ab.ab_trip_id = t.ab_trip_id
		WHERE t.sequent = count1 AND t.schedule = NEW.schedule);

		IF(point1 <> NEW.start_point) THEN
			RAISE EXCEPTION 'sequence is not right';
		END IF;
		RETURN NEW;
	END IF;
	RETURN NEW;
END 
$$;


--
-- Name: estimate_time(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION estimate_time() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE sum_time time;
BEGIN
	sum_time = (SELECT SUM(ab.duration) 
	FROM abstract_trip AS ab 
	INNER JOIN trip AS t
	ON t.ab_trip_id = ab.ab_trip_id
	WHERE t.trip_id = NEW.trip_id);

	UPDATE schedule SET estimate_time = sum_time 
	WHERE schedule_id = NEW.schedule_id;
	RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: abstract_trip; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE abstract_trip (
    ab_trip_id integer NOT NULL,
    category_id integer,
    start_point integer,
    end_point integer,
    duration time without time zone
);


--
-- Name: abstract_trip_ab_trip_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE abstract_trip_ab_trip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: abstract_trip_ab_trip_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE abstract_trip_ab_trip_id_seq OWNED BY abstract_trip.ab_trip_id;


--
-- Name: customer; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE customer (
    customer_id integer NOT NULL,
    name character varying(60),
    address character varying(60),
    postcode character(10),
    email character varying(60),
    user_id integer,
    tel character varying(20)
);


--
-- Name: customer_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE customer_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE customer_customer_id_seq OWNED BY customer.customer_id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE invoices (
    invoice_id integer NOT NULL,
    supplier_id integer,
    vehicle_id integer,
    schedule_id integer,
    request_id integer,
    offer_price real,
    status character varying(15),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    message character varying(500)
);


--
-- Name: invoices_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invoices_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_invoice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invoices_invoice_id_seq OWNED BY invoices.invoice_id;


--
-- Name: location; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE location (
    location_id integer NOT NULL,
    radius real,
    location_type smallint,
    country character varying(30),
    city character varying(30),
    street character varying(30),
    address character varying(60),
    point geometry(Point,4269)
);


--
-- Name: location_location_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE location_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: location_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE location_location_id_seq OWNED BY location.location_id;


--
-- Name: properties; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE properties (
    property_id integer NOT NULL,
    name character varying(60),
    unit character(5)
);


--
-- Name: request; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE request (
    request_id integer NOT NULL,
    customer_id integer,
    weight real,
    goods_type smallint,
    height real,
    length real,
    capacity real,
    other_description character varying(60),
    start_point bigint,
    end_point bigint,
    status character varying(15),
    category_id integer,
    "time" timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    start_point_lat numeric,
    start_point_long numeric,
    end_point_lat numeric,
    end_point_long numeric
);


--
-- Name: request_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: request_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE request_request_id_seq OWNED BY request.request_id;


--
-- Name: schedule; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schedule (
    schedule_id integer NOT NULL,
    estimate_time time without time zone,
    request_id integer
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: supplier; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE supplier (
    supplier_id integer NOT NULL,
    name character varying(60),
    address character varying(60),
    tel bigint,
    email character varying(60),
    user_id integer
);


--
-- Name: supplier_s_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE supplier_s_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supplier_s_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE supplier_s_id_seq OWNED BY supplier.supplier_id;


--
-- Name: trip; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trip (
    trip_id bigint NOT NULL,
    vehicle_id character varying(30) NOT NULL,
    ab_trip_id bigint,
    schedule_id integer,
    sequent smallint
);


--
-- Name: trip_trip_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trip_trip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trip_trip_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trip_trip_id_seq OWNED BY trip.trip_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    role character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: v_category_properties; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE v_category_properties (
    property_id integer NOT NULL,
    category_id integer NOT NULL,
    value real
);


--
-- Name: vehicle; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vehicle (
    vehicle_id integer NOT NULL,
    vehicle_number character varying(30) NOT NULL,
    cost_per_km real,
    point geometry(Point,4269),
    category_id bigint,
    s_id integer,
    available boolean,
    image character varying(60)
);


--
-- Name: vehicle_category; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vehicle_category (
    id integer NOT NULL,
    name character varying(60),
    description character varying(60),
    weight real,
    height real,
    length real,
    capacity real
);


--
-- Name: vehicle_category_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vehicle_category_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicle_category_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vehicle_category_category_id_seq OWNED BY vehicle_category.id;


--
-- Name: vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vehicle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vehicle_id_seq OWNED BY vehicle.vehicle_id;


--
-- Name: ab_trip_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY abstract_trip ALTER COLUMN ab_trip_id SET DEFAULT nextval('abstract_trip_ab_trip_id_seq'::regclass);


--
-- Name: customer_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY customer ALTER COLUMN customer_id SET DEFAULT nextval('customer_customer_id_seq'::regclass);


--
-- Name: invoice_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invoices ALTER COLUMN invoice_id SET DEFAULT nextval('invoices_invoice_id_seq'::regclass);


--
-- Name: location_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY location ALTER COLUMN location_id SET DEFAULT nextval('location_location_id_seq'::regclass);


--
-- Name: request_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY request ALTER COLUMN request_id SET DEFAULT nextval('request_request_id_seq'::regclass);


--
-- Name: supplier_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY supplier ALTER COLUMN supplier_id SET DEFAULT nextval('supplier_s_id_seq'::regclass);


--
-- Name: trip_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trip ALTER COLUMN trip_id SET DEFAULT nextval('trip_trip_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: vehicle_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle ALTER COLUMN vehicle_id SET DEFAULT nextval('vehicle_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle_category ALTER COLUMN id SET DEFAULT nextval('vehicle_category_category_id_seq'::regclass);


--
-- Name: abstract_trip_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY abstract_trip
    ADD CONSTRAINT abstract_trip_pkey PRIMARY KEY (ab_trip_id);


--
-- Name: customer_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- Name: invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoice_pkey PRIMARY KEY (invoice_id);


--
-- Name: location_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY location
    ADD CONSTRAINT location_pkey PRIMARY KEY (location_id);


--
-- Name: properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (property_id);


--
-- Name: request_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY request
    ADD CONSTRAINT request_pkey PRIMARY KEY (request_id);


--
-- Name: schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (schedule_id);


--
-- Name: supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (supplier_id);


--
-- Name: trip_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trip
    ADD CONSTRAINT trip_pkey PRIMARY KEY (trip_id, vehicle_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: v_category_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY v_category_properties
    ADD CONSTRAINT v_category_properties_pkey PRIMARY KEY (property_id, category_id);


--
-- Name: vehicle_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vehicle_category
    ADD CONSTRAINT vehicle_category_pkey PRIMARY KEY (id);


--
-- Name: vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vehicle
    ADD CONSTRAINT vehicle_pkey PRIMARY KEY (vehicle_id);


--
-- Name: vehicle_vehicle_number_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vehicle
    ADD CONSTRAINT vehicle_vehicle_number_key UNIQUE (vehicle_number);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: check_category; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_category AFTER INSERT OR UPDATE ON trip FOR EACH ROW EXECUTE PROCEDURE check_category();


--
-- Name: check_point; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_point BEFORE INSERT OR UPDATE ON trip FOR EACH ROW EXECUTE PROCEDURE check_point();


--
-- Name: estimate_time; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER estimate_time AFTER INSERT OR DELETE OR UPDATE ON trip FOR EACH ROW EXECUTE PROCEDURE estimate_time();


--
-- Name: abstract_trip_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY abstract_trip
    ADD CONSTRAINT abstract_trip_category_id_fkey FOREIGN KEY (category_id) REFERENCES vehicle_category(id);


--
-- Name: abstract_trip_end_point_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY abstract_trip
    ADD CONSTRAINT abstract_trip_end_point_fkey FOREIGN KEY (end_point) REFERENCES location(location_id);


--
-- Name: abstract_trip_start_point_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY abstract_trip
    ADD CONSTRAINT abstract_trip_start_point_fkey FOREIGN KEY (start_point) REFERENCES location(location_id);


--
-- Name: invoice_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoice_request_id_fkey FOREIGN KEY (request_id) REFERENCES request(request_id);


--
-- Name: invoice_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoice_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES schedule(schedule_id);


--
-- Name: invoice_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoice_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id);


--
-- Name: invoice_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoice_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id);


--
-- Name: request_cus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request
    ADD CONSTRAINT request_cus_id_fkey FOREIGN KEY (customer_id) REFERENCES customer(customer_id);


--
-- Name: schedule_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT schedule_request_id_fkey FOREIGN KEY (request_id) REFERENCES request(request_id);


--
-- Name: trip_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trip
    ADD CONSTRAINT trip_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES schedule(schedule_id);


--
-- Name: v_category_properties_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY v_category_properties
    ADD CONSTRAINT v_category_properties_property_id_fkey FOREIGN KEY (property_id) REFERENCES properties(property_id);


--
-- Name: v_category_properties_v_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY v_category_properties
    ADD CONSTRAINT v_category_properties_v_category_id_fkey FOREIGN KEY (category_id) REFERENCES vehicle_category(id);


--
-- Name: vehicle_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle
    ADD CONSTRAINT vehicle_category_id_fkey FOREIGN KEY (category_id) REFERENCES vehicle_category(id);


--
-- Name: vehicle_s_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle
    ADD CONSTRAINT vehicle_s_id_fkey FOREIGN KEY (s_id) REFERENCES supplier(supplier_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20151105023430');

INSERT INTO schema_migrations (version) VALUES ('20151105023751');

INSERT INTO schema_migrations (version) VALUES ('20151105024928');

INSERT INTO schema_migrations (version) VALUES ('20151105025317');

