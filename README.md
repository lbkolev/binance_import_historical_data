# Binance import historical data
Automatically download and import historical, cryptocurrency related, binance data from [https://data.binance.vision](https://data.binance.vision) into a PostgreSQL database.
Details about the offered data can be found [here](https://github.com/binance/binance-public-data/)).

⚠️ ⚠️  Supports only [spot](https://data.binance.vision/?prefix=data/spot/monthly/). ⚠️ ⚠️


1)[Installation](#Installation)  
2)[Usage](#Usage)  
3)[Examples](#Examples)  
4)[Database schema architecture](#DBExplained)  
5)[Troubleshooting](#Troubleshooting)  


## Installation

Clone the repository
```bash
$ git clone git@github.com:lbkolev/binance_import_historical_data.git
```

If you don't have docker, install it as described [here](https://docs.docker.com/engine/install/).

There are two ways to get the docker image: Build it yourself or pull it from [here](https://hub.docker.com/repository/docker/lbkolev/binance_import_historical_data).


Pull an already built one:
```bash
$ docker pull lbkolev/binance_import_historical_data:latest
```

or Build it yourself:
```bash
$ cd binance_import_historical_data
$ docker build ./
```

Setup an instance running at port 5432. **Don't forget to replace *password* with an actual password.**
```bash
$ docker run -d --name 'binance_instance1' -p 5432:5432 -e POSTGRES_PASSWORD=<password> lbkolev/binance_import_historical_data:latest
```

The postgresql instance we just ran has built-in database and user named *binance*.
The following details should all be known by now:  
*Hostname*  - Most likely localhost  
*Port*      - The one we ran the instance with, in this case 5432  
*Database*  - Defaults to binance  
*User*      - Defaults to binance  
*Password*  - The one you just setup with POSTGRES_PASSWORD=  


Populate the first row of ~/.pgpass with the hostname,port,database,user and password of the running instance, as this is what the script uses to connect to the database.
The [formatting](https://www.postgresql.org/docs/current/libpq-pgpass.html) should be *hostname:port:database:username:password*

You should be able to connect to the database now:
```bash
$ psql --host=localhost --username=binance
binance=#
```

## Usage
Only ./import.sh should be called directly:
```
$ ./import.sh
No arguments provided.
Usage: ./import.sh --pair <pair> [TYPE] [OPTIONAL] | [ -h | --help ]
    --pair <pair>                                                             The pair we get the data for. BTCUSDT, AAVEUST, ETHBTC etc.
TYPE                                                                          Specify only one of --klines --trades and --aggtrades
    --klines <interval>                                                       The interval offered by binance. Choose between 1m|3m|5m|15m|30m|1h|2h|4h|6h|8h|12h|1d|3d|1w|1mo.
OR
    --trades                                                                  Download old market trades for the specified pair.
OR
    --aggtrades                                                               Download old aggregated trades for the specified pair.
[OPTIONAL]
    --years  <all | start_year-end_year | year>                               The period of year(s) to download data for.  Defaults to 'all'. I.e. from when it is listed on the exchange until now.
    --months <all | start_month-end_month | month>                            The period of month(s) to download data for. Defaults to 'all'. I.e. for every month of the year.

Examples:
import.sh --help                                                              Prints this.
import.sh --pair AAVEUST --interval 1m                                        Downloads all 1 minute spot kline data for pair AAVEUST for every month of every year since the listing of the pair.
import.sh --pair ETHUSDT --interval 30m --years all --months 3                Downloads all 30 minute spot kline data for pair ETHUSDT only for month march for every year since the listing of the pair.
import.sh --pair DOGEUSDC --interval 1mo --years 2020-2021 --months 3-6       Downloads all 1 month spot kline data for pair DOGEUSDC for the years 2020 and 2021, only for months March,April,May,June. If the pair wasn't listed in this period, we do nuthin.
import.sh --aggtrades --pair 1INCHUPUSDT --years 2021                         Downloads all aggregate trades for pair 1INCHUPUSDT for the year 2021.
import.sh --trades --pair AGLDBTC                                             Downloads all historical trades for pair AGLDBTC, since its listing.
```

##Examples
1. Import the 4 hour klines data for the pair ETHUSDT for the period of 2021-2022:
```bash
$ ./import.sh --klines 4h --pair ETHUSDT --years 2021
```
[![That's how it should look]()](https://streamable.com/6mm08t)

2. Import all the trades that have happened for pair DOGEUSDT only for March of 2022.
```bash
$ ./import --trades --pair dogeusdt --years 2022 --months 3
```

## Database schema architecture
Details about the public data can be found [here](https://github.com/binance/binance-public-data/).
The Database name as well as the username used to connect are named 'binance'.  
Every pair is inserted inside the 'pairs' table, which is from then on used as a foreign key for all the data about this pair.
```
binance=# \d pairs
                                   Table "public.pairs"
 Column |         Type          | Collation | Nullable |              Default
--------+-----------------------+-----------+----------+-----------------------------------
 id     | integer               |           | not null | nextval('pairs_id_seq'::regclass)
 pair   | character varying(30) |           | not null |
Indexes:
    "pairs_pkey" PRIMARY KEY, btree (id)
    "pairs_pair_key" UNIQUE CONSTRAINT, btree (pair)
Referenced by:
    TABLE "aggtrades" CONSTRAINT "aggtrades_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_12h" CONSTRAINT "kl_12h_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_15m" CONSTRAINT "kl_15m_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_1d" CONSTRAINT "kl_1d_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_1h" CONSTRAINT "kl_1h_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_1m" CONSTRAINT "kl_1m_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_1mo" CONSTRAINT "kl_1mo_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_1w" CONSTRAINT "kl_1w_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_2h" CONSTRAINT "kl_2h_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_30m" CONSTRAINT "kl_30m_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_3d" CONSTRAINT "kl_3d_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_3m" CONSTRAINT "kl_3m_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_4h" CONSTRAINT "kl_4h_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_5m" CONSTRAINT "kl_5m_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_6h" CONSTRAINT "kl_6h_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "kl_8h" CONSTRAINT "kl_8h_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
    TABLE "trades" CONSTRAINT "trades_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
```
There's a kline table for each time interval - 1m|3m|5m|15m|30m|1h|2h|4h|6h|8h|12h|1d|3d|1w|1mo. They all reference a pair and hold the same information - timestamp of kline, open, close, high and low prices for the interval, as well as the volume and the amount of trades done.
```
binance=# \d kl_1h;
                                 Table "public.kl_1h"
  Column  |      Type      | Collation | Nullable |              Default
----------+----------------+-----------+----------+-----------------------------------
 id       | bigint         |           | not null | nextval('kl_1h_id_seq'::regclass)
 pair_id  | integer        |           |          |
 ts       | bigint         |           |          |
 open     | numeric(20,8)  |           |          |
 high     | numeric(20,8)  |           |          |
 low      | numeric(20,8)  |           |          |
 close    | numeric(20,8)  |           |          |
 volume   | numeric(30,10) |           |          |
 close_ts | bigint         |           |          |
 qavol    | numeric(20,8)  |           |          |
 trades   | bigint         |           |          |
 tbavol   | numeric(20,8)  |           |          |
 tqavol   | numeric(20,8)  |           |          |
Indexes:
    "kl_1h_pkey" PRIMARY KEY, btree (id)
    "kl_1h_ts" btree (ts)
Foreign-key constraints:
    "kl_1h_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
Triggers:
    _forbid_double_insert_1h BEFORE INSERT ON kl_1h FOR EACH ROW EXECUTE FUNCTION forbid_double_insert()
```

There are also two tables holding all of the trading and aggtrading information for pair with *pair_id*.

Trading table schema:
```
binance=# \d trades
                                  Table "public.trades"
    Column    |     Type      | Collation | Nullable |              Default
--------------+---------------+-----------+----------+------------------------------------
 id           | bigint        |           | not null | nextval('trades_id_seq'::regclass)
 pair_id      | integer       |           |          |
 trade_id     | bigint        |           |          |
 ts           | bigint        |           |          |
 price        | numeric(20,8) |           |          |
 bqty         | numeric(20,8) |           |          |
 qqty         | numeric(20,8) |           |          |
 isbuyermaker | boolean       |           |          |
 isbestmatch  | boolean       |           |          |
Indexes:
    "trades_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "trades_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
```

Aggtrades table schema:
```
binance=# \d aggtrades
                                   Table "public.aggtrades"
     Column     |     Type      | Collation | Nullable |                Default
----------------+---------------+-----------+----------+---------------------------------------
 id             | bigint        |           | not null | nextval('aggtrades_id_seq'::regclass)
 pair_id        | integer       |           |          |
 trade_id       | bigint        |           |          |
 first_trade_id | bigint        |           |          |
 last_trade_id  | bigint        |           |          |
 ts             | bigint        |           |          |
 price          | numeric(20,8) |           |          |
 quantity       | numeric(20,8) |           |          |
 maker          | boolean       |           |          |
 isbestmatch    | boolean       |           |          |
Indexes:
    "aggtrades_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "aggtrades_pair_id_fkey" FOREIGN KEY (pair_id) REFERENCES pairs(id)
```

## Troubleshooting
For every fetch the script writes to log file located at binance_import_historical_data/log/ directory. 
