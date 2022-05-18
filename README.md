# Binance import historical data
Download and import historical, cryptocurrency related, binance data from [https://data.binance.vision](https://data.binance.vision) into a PostgreSQL database.

⚠️ ⚠️  Supports only [spot](https://data.binance.vision/?prefix=data/spot/monthly/) data ⚠️ ⚠️


1)[Installation](#Installation)

2)[Usage](#Usage)


## Installation

Clone the repository
```bash
$ git clone git@github.com:lbkolev/binance_import_historical_data.git
```

If you don't have docker, install it as described [here](https://docs.docker.com/engine/install/).

There are two ways to get the docker image: Build it yourself or pull it from [here](https://hub.docker.com/repository/docker/lbkolev/binance_import_historical_data).

Build it yourself:
```bash
$ cd binance_import_historical_data
$ docker build lbkolev/binance_import_historical_data ./
```

Pull an already built one:
```bash
$ docker pull lbkolev/binance_import_historical_data:latest
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

## Usage
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
