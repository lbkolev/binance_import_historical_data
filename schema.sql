--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1 (Debian 14.1-1.pgdg110+1)
-- Dumped by pg_dump version 14.2

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
-- Name: _call(integer); Type: FUNCTION; Schema: public; Owner: binance
--

CREATE FUNCTION public._call(_pair_id integer) RETURNS TABLE(_pair character varying, _interval text, _count bigint)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        _pair_name VARCHAR;
    BEGIN
        SELECT pair INTO _pair_name FROM pairs WHERE id = _pair_id;

        IF ( _pair_name IS NULL) THEN
            RAISE EXCEPTION 'No pair with id %  ... Aborting!', _pair_id;
        END IF;


        RETURN QUERY
        SELECT _pair_name AS _pair, '3m'  AS _interval , COUNT(*)::BIGINT as _count  FROM kl_3m  WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '5m'  AS _interval , COUNT(*)::BIGINT as _count  FROM kl_5m  WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '15m' AS _inverval , COUNT(*)::BIGINT as _count  FROM kl_15m WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '30m' AS _interval , COUNT(*)::BIGINT as _count  FROM kl_30m WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '1h'  AS _interval , COUNT(*)::BIGINT as _count  FROM kl_1h  WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '2h'  AS _interval , COUNT(*)::BIGINT as _count  FROM kl_2h  WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '4h'  AS _interval , COUNT(*)::BIGINT as _count  FROM kl_4h  WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '6h'  AS _interval , COUNT(*)::BIGINT as _count  FROM kl_6h  WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '8h'  AS _interval , COUNT(*)::BIGINT as _count  FROM kl_8h  WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '12h' AS _interval , COUNT(*)::BIGINT as _count  FROM kl_12h WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '1d'  AS _interval , COUNT(*)::BIGINT as _count  FROM kl_1d  WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '3d'  AS _interval , COUNT(*)::BIGINT as _count  FROM kl_3d  WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '1w'  AS _interval , COUNT(*)::BIGINT as _count  FROM kl_1w  WHERE pair_id = _pair_id UNION
        SELECT _pair_name AS _pair, '1mo' AS _interval , COUNT(*)::BIGINT as _count  FROM kl_1mo WHERE pair_id = _pair_id
        ORDER BY _count DESC;
    END;
$$;


ALTER FUNCTION public._call(_pair_id integer) OWNER TO binance;

--
-- Name: dont_delete_pairs(); Type: FUNCTION; Schema: public; Owner: binance
--

CREATE FUNCTION public.dont_delete_pairs() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            RAISE EXCEPTION 'PAIR DELETION IS FORBIDDEN.';
        END IF;
    END
$$;


ALTER FUNCTION public.dont_delete_pairs() OWNER TO binance;

--
-- Name: forbid_double_insert(); Type: FUNCTION; Schema: public; Owner: binance
--

CREATE FUNCTION public.forbid_double_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
        pid     BIGINT;
        _table  TEXT := TG_TABLE_NAME;
        _new_pair_id INT := NEW.pair_id;
        _new_ts BIGINT := NEW.ts;
    BEGIN

        -- EXECUTE 'SELECT id INTO pid FROM ' || _table || ' WHERE pair_id = ' || _new_pair_id || ' AND ts = ' || _new_ts;
        EXECUTE 'SELECT id FROM ' || _table || ' WHERE pair_id = ' || _new_pair_id || ' AND ts = ' || _new_ts INTO pid;

        IF (pid IS NULL) THEN
            RETURN NEW;
        ELSE
            RAISE EXCEPTION 'Detected an attempt to insert an already inserted row.. ABORTING!';
        END IF;
    END;
$$;


ALTER FUNCTION public.forbid_double_insert() OWNER TO binance;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aggtrades; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.aggtrades (
    id bigint NOT NULL,
    pair_id integer,
    trade_id bigint,
    first_trade_id bigint,
    last_trade_id bigint,
    ts bigint,
    price numeric(20,8),
    quantity numeric(20,8),
    maker boolean,
    isbestmatch boolean
);


ALTER TABLE public.aggtrades OWNER TO binance;

--
-- Name: COLUMN aggtrades.maker; Type: COMMENT; Schema: public; Owner: binance
--

COMMENT ON COLUMN public.aggtrades.maker IS 'Was the buyer the maker';


--
-- Name: COLUMN aggtrades.isbestmatch; Type: COMMENT; Schema: public; Owner: binance
--

COMMENT ON COLUMN public.aggtrades.isbestmatch IS 'Was the trade the best price match';


--
-- Name: aggtrades_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.aggtrades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggtrades_id_seq OWNER TO binance;

--
-- Name: aggtrades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.aggtrades_id_seq OWNED BY public.aggtrades.id;


--
-- Name: kl_12h; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_12h (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_12h OWNER TO binance;

--
-- Name: kl_12h_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_12h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_12h_id_seq OWNER TO binance;

--
-- Name: kl_12h_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_12h_id_seq OWNED BY public.kl_12h.id;


--
-- Name: kl_15m; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_15m (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_15m OWNER TO binance;

--
-- Name: kl_15m_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_15m_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_15m_id_seq OWNER TO binance;

--
-- Name: kl_15m_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_15m_id_seq OWNED BY public.kl_15m.id;


--
-- Name: kl_1d; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_1d (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_1d OWNER TO binance;

--
-- Name: kl_1d_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_1d_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_1d_id_seq OWNER TO binance;

--
-- Name: kl_1d_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_1d_id_seq OWNED BY public.kl_1d.id;


--
-- Name: kl_1h; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_1h (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_1h OWNER TO binance;

--
-- Name: kl_1h_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_1h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_1h_id_seq OWNER TO binance;

--
-- Name: kl_1h_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_1h_id_seq OWNED BY public.kl_1h.id;


--
-- Name: kl_1m; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_1m (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_1m OWNER TO binance;

--
-- Name: kl_1m_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_1m_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_1m_id_seq OWNER TO binance;

--
-- Name: kl_1m_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_1m_id_seq OWNED BY public.kl_1m.id;


--
-- Name: kl_1mo; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_1mo (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_1mo OWNER TO binance;

--
-- Name: kl_1mo_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_1mo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_1mo_id_seq OWNER TO binance;

--
-- Name: kl_1mo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_1mo_id_seq OWNED BY public.kl_1mo.id;


--
-- Name: kl_1w; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_1w (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_1w OWNER TO binance;

--
-- Name: kl_1w_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_1w_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_1w_id_seq OWNER TO binance;

--
-- Name: kl_1w_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_1w_id_seq OWNED BY public.kl_1w.id;


--
-- Name: kl_2h; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_2h (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_2h OWNER TO binance;

--
-- Name: kl_2h_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_2h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_2h_id_seq OWNER TO binance;

--
-- Name: kl_2h_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_2h_id_seq OWNED BY public.kl_2h.id;


--
-- Name: kl_30m; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_30m (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_30m OWNER TO binance;

--
-- Name: kl_30m_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_30m_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_30m_id_seq OWNER TO binance;

--
-- Name: kl_30m_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_30m_id_seq OWNED BY public.kl_30m.id;


--
-- Name: kl_3d; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_3d (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_3d OWNER TO binance;

--
-- Name: kl_3d_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_3d_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_3d_id_seq OWNER TO binance;

--
-- Name: kl_3d_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_3d_id_seq OWNED BY public.kl_3d.id;


--
-- Name: kl_3m; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_3m (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_3m OWNER TO binance;

--
-- Name: kl_3m_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_3m_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_3m_id_seq OWNER TO binance;

--
-- Name: kl_3m_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_3m_id_seq OWNED BY public.kl_3m.id;


--
-- Name: kl_4h; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_4h (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_4h OWNER TO binance;

--
-- Name: kl_4h_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_4h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_4h_id_seq OWNER TO binance;

--
-- Name: kl_4h_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_4h_id_seq OWNED BY public.kl_4h.id;


--
-- Name: kl_5m; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_5m (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_5m OWNER TO binance;

--
-- Name: kl_5m_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_5m_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_5m_id_seq OWNER TO binance;

--
-- Name: kl_5m_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_5m_id_seq OWNED BY public.kl_5m.id;


--
-- Name: kl_6h; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_6h (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_6h OWNER TO binance;

--
-- Name: kl_6h_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_6h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_6h_id_seq OWNER TO binance;

--
-- Name: kl_6h_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_6h_id_seq OWNED BY public.kl_6h.id;


--
-- Name: kl_8h; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.kl_8h (
    id bigint NOT NULL,
    pair_id integer,
    ts bigint,
    open numeric(20,8),
    high numeric(20,8),
    low numeric(20,8),
    close numeric(20,8),
    volume numeric(30,10),
    close_ts bigint,
    qavol numeric(20,8),
    trades bigint,
    tbavol numeric(20,8),
    tqavol numeric(20,8)
);


ALTER TABLE public.kl_8h OWNER TO binance;

--
-- Name: kl_8h_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.kl_8h_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kl_8h_id_seq OWNER TO binance;

--
-- Name: kl_8h_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.kl_8h_id_seq OWNED BY public.kl_8h.id;


--
-- Name: pairs; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.pairs (
    id integer NOT NULL,
    pair character varying(30) NOT NULL
);


ALTER TABLE public.pairs OWNER TO binance;

--
-- Name: pairs_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.pairs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pairs_id_seq OWNER TO binance;

--
-- Name: pairs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.pairs_id_seq OWNED BY public.pairs.id;


--
-- Name: trades; Type: TABLE; Schema: public; Owner: binance
--

CREATE TABLE public.trades (
    id bigint NOT NULL,
    pair_id integer,
    trade_id bigint,
    ts bigint,
    price numeric(20,8),
    bqty numeric(20,8),
    qqty numeric(20,8),
    isbuyermaker boolean,
    isbestmatch boolean
);


ALTER TABLE public.trades OWNER TO binance;

--
-- Name: trades_id_seq; Type: SEQUENCE; Schema: public; Owner: binance
--

CREATE SEQUENCE public.trades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trades_id_seq OWNER TO binance;

--
-- Name: trades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: binance
--

ALTER SEQUENCE public.trades_id_seq OWNED BY public.trades.id;


--
-- Name: aggtrades id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.aggtrades ALTER COLUMN id SET DEFAULT nextval('public.aggtrades_id_seq'::regclass);


--
-- Name: kl_12h id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_12h ALTER COLUMN id SET DEFAULT nextval('public.kl_12h_id_seq'::regclass);


--
-- Name: kl_15m id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_15m ALTER COLUMN id SET DEFAULT nextval('public.kl_15m_id_seq'::regclass);


--
-- Name: kl_1d id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1d ALTER COLUMN id SET DEFAULT nextval('public.kl_1d_id_seq'::regclass);


--
-- Name: kl_1h id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1h ALTER COLUMN id SET DEFAULT nextval('public.kl_1h_id_seq'::regclass);


--
-- Name: kl_1m id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1m ALTER COLUMN id SET DEFAULT nextval('public.kl_1m_id_seq'::regclass);


--
-- Name: kl_1mo id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1mo ALTER COLUMN id SET DEFAULT nextval('public.kl_1mo_id_seq'::regclass);


--
-- Name: kl_1w id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1w ALTER COLUMN id SET DEFAULT nextval('public.kl_1w_id_seq'::regclass);


--
-- Name: kl_2h id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_2h ALTER COLUMN id SET DEFAULT nextval('public.kl_2h_id_seq'::regclass);


--
-- Name: kl_30m id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_30m ALTER COLUMN id SET DEFAULT nextval('public.kl_30m_id_seq'::regclass);


--
-- Name: kl_3d id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_3d ALTER COLUMN id SET DEFAULT nextval('public.kl_3d_id_seq'::regclass);


--
-- Name: kl_3m id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_3m ALTER COLUMN id SET DEFAULT nextval('public.kl_3m_id_seq'::regclass);


--
-- Name: kl_4h id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_4h ALTER COLUMN id SET DEFAULT nextval('public.kl_4h_id_seq'::regclass);


--
-- Name: kl_5m id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_5m ALTER COLUMN id SET DEFAULT nextval('public.kl_5m_id_seq'::regclass);


--
-- Name: kl_6h id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_6h ALTER COLUMN id SET DEFAULT nextval('public.kl_6h_id_seq'::regclass);


--
-- Name: kl_8h id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_8h ALTER COLUMN id SET DEFAULT nextval('public.kl_8h_id_seq'::regclass);


--
-- Name: pairs id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.pairs ALTER COLUMN id SET DEFAULT nextval('public.pairs_id_seq'::regclass);


--
-- Name: trades id; Type: DEFAULT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.trades ALTER COLUMN id SET DEFAULT nextval('public.trades_id_seq'::regclass);


--
-- Name: aggtrades aggtrades_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.aggtrades
    ADD CONSTRAINT aggtrades_pkey PRIMARY KEY (id);


--
-- Name: kl_12h kl_12h_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_12h
    ADD CONSTRAINT kl_12h_pkey PRIMARY KEY (id);


--
-- Name: kl_15m kl_15m_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_15m
    ADD CONSTRAINT kl_15m_pkey PRIMARY KEY (id);


--
-- Name: kl_1d kl_1d_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1d
    ADD CONSTRAINT kl_1d_pkey PRIMARY KEY (id);


--
-- Name: kl_1h kl_1h_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1h
    ADD CONSTRAINT kl_1h_pkey PRIMARY KEY (id);


--
-- Name: kl_1m kl_1m_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1m
    ADD CONSTRAINT kl_1m_pkey PRIMARY KEY (id);


--
-- Name: kl_1mo kl_1mo_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1mo
    ADD CONSTRAINT kl_1mo_pkey PRIMARY KEY (id);


--
-- Name: kl_1w kl_1w_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1w
    ADD CONSTRAINT kl_1w_pkey PRIMARY KEY (id);


--
-- Name: kl_2h kl_2h_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_2h
    ADD CONSTRAINT kl_2h_pkey PRIMARY KEY (id);


--
-- Name: kl_30m kl_30m_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_30m
    ADD CONSTRAINT kl_30m_pkey PRIMARY KEY (id);


--
-- Name: kl_3d kl_3d_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_3d
    ADD CONSTRAINT kl_3d_pkey PRIMARY KEY (id);


--
-- Name: kl_3m kl_3m_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_3m
    ADD CONSTRAINT kl_3m_pkey PRIMARY KEY (id);


--
-- Name: kl_4h kl_4h_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_4h
    ADD CONSTRAINT kl_4h_pkey PRIMARY KEY (id);


--
-- Name: kl_5m kl_5m_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_5m
    ADD CONSTRAINT kl_5m_pkey PRIMARY KEY (id);


--
-- Name: kl_6h kl_6h_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_6h
    ADD CONSTRAINT kl_6h_pkey PRIMARY KEY (id);


--
-- Name: kl_8h kl_8h_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_8h
    ADD CONSTRAINT kl_8h_pkey PRIMARY KEY (id);


--
-- Name: pairs pairs_pair_key; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.pairs
    ADD CONSTRAINT pairs_pair_key UNIQUE (pair);


--
-- Name: pairs pairs_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.pairs
    ADD CONSTRAINT pairs_pkey PRIMARY KEY (id);


--
-- Name: trades trades_pkey; Type: CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.trades
    ADD CONSTRAINT trades_pkey PRIMARY KEY (id);


--
-- Name: kl_12h_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_12h_ts ON public.kl_12h USING btree (ts);


--
-- Name: kl_15m_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_15m_ts ON public.kl_15m USING btree (ts);


--
-- Name: kl_1d_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_1d_ts ON public.kl_1d USING btree (ts);


--
-- Name: kl_1h_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_1h_ts ON public.kl_1h USING btree (ts);


--
-- Name: kl_1m_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_1m_ts ON public.kl_1m USING btree (ts);


--
-- Name: kl_1mo_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_1mo_ts ON public.kl_1mo USING btree (ts);


--
-- Name: kl_1w_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_1w_ts ON public.kl_1w USING btree (ts);


--
-- Name: kl_2h_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_2h_ts ON public.kl_2h USING btree (ts);


--
-- Name: kl_30m_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_30m_ts ON public.kl_30m USING btree (ts);


--
-- Name: kl_3d_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_3d_ts ON public.kl_3d USING btree (ts);


--
-- Name: kl_3m_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_3m_ts ON public.kl_3m USING btree (ts);


--
-- Name: kl_4h_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_4h_ts ON public.kl_4h USING btree (ts);


--
-- Name: kl_5m_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_5m_ts ON public.kl_5m USING btree (ts);


--
-- Name: kl_6h_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_6h_ts ON public.kl_6h USING btree (ts);


--
-- Name: kl_8h_ts; Type: INDEX; Schema: public; Owner: binance
--

CREATE INDEX kl_8h_ts ON public.kl_8h USING btree (ts);


--
-- Name: kl_12h _forbid_double_insert_12h; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_12h BEFORE INSERT ON public.kl_12h FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_15m _forbid_double_insert_15m; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_15m BEFORE INSERT ON public.kl_15m FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_1d _forbid_double_insert_1d; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_1d BEFORE INSERT ON public.kl_1d FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_1h _forbid_double_insert_1h; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_1h BEFORE INSERT ON public.kl_1h FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_1m _forbid_double_insert_1m; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_1m BEFORE INSERT ON public.kl_1m FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_1mo _forbid_double_insert_1mo; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_1mo BEFORE INSERT ON public.kl_1mo FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_1w _forbid_double_insert_1w; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_1w BEFORE INSERT ON public.kl_1w FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_2h _forbid_double_insert_2h; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_2h BEFORE INSERT ON public.kl_2h FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_2h _forbid_double_insert_30d; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_30d BEFORE INSERT ON public.kl_2h FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_30m _forbid_double_insert_30m; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_30m BEFORE INSERT ON public.kl_30m FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_3d _forbid_double_insert_3d; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_3d BEFORE INSERT ON public.kl_3d FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_3m _forbid_double_insert_3m; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_3m BEFORE INSERT ON public.kl_3m FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_4h _forbid_double_insert_4h; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_4h BEFORE INSERT ON public.kl_4h FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_5m _forbid_double_insert_5m; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_5m BEFORE INSERT ON public.kl_5m FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_6h _forbid_double_insert_6h; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_6h BEFORE INSERT ON public.kl_6h FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: kl_8h _forbid_double_insert_8h; Type: TRIGGER; Schema: public; Owner: binance
--

CREATE TRIGGER _forbid_double_insert_8h BEFORE INSERT ON public.kl_8h FOR EACH ROW EXECUTE FUNCTION public.forbid_double_insert();


--
-- Name: aggtrades aggtrades_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.aggtrades
    ADD CONSTRAINT aggtrades_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_12h kl_12h_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_12h
    ADD CONSTRAINT kl_12h_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_15m kl_15m_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_15m
    ADD CONSTRAINT kl_15m_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_1d kl_1d_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1d
    ADD CONSTRAINT kl_1d_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_1h kl_1h_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1h
    ADD CONSTRAINT kl_1h_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_1m kl_1m_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1m
    ADD CONSTRAINT kl_1m_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_1mo kl_1mo_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1mo
    ADD CONSTRAINT kl_1mo_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_1w kl_1w_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_1w
    ADD CONSTRAINT kl_1w_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_2h kl_2h_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_2h
    ADD CONSTRAINT kl_2h_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_30m kl_30m_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_30m
    ADD CONSTRAINT kl_30m_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_3d kl_3d_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_3d
    ADD CONSTRAINT kl_3d_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_3m kl_3m_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_3m
    ADD CONSTRAINT kl_3m_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_4h kl_4h_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_4h
    ADD CONSTRAINT kl_4h_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_5m kl_5m_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_5m
    ADD CONSTRAINT kl_5m_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_6h kl_6h_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_6h
    ADD CONSTRAINT kl_6h_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: kl_8h kl_8h_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.kl_8h
    ADD CONSTRAINT kl_8h_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- Name: trades trades_pair_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: binance
--

ALTER TABLE ONLY public.trades
    ADD CONSTRAINT trades_pair_id_fkey FOREIGN KEY (pair_id) REFERENCES public.pairs(id);


--
-- PostgreSQL database dump complete
--

