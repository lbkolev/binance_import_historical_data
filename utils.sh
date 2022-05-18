# --------- colors --------- #
cok='\033[32m'               #
cerr='\033[31m'              #
cneutral='\033[01;36m'       #
cdef='\033[0m'               #
# -------------------------- #

function parse_args () {

    if [[ $# -eq 0 ]];then 
        echo -e "No arguments provided." && usage 0
    fi
    
    #default values
    years="2017-$(date '+%Y')"
    months="1-12"

    while [ $# -gt 0 ];do
        case "$1" in
            --pair)
                pair="${2^^}" # makes it uppercase
                shift 2
                ;;
 
            --klines)
                [[ -z $dtype ]] || { echo "Can't specify type more than once." && usage 1; }
                dtype="klines"
                validate_arg_klines $2
                klines="$2"
                shift 2
                ;;

            --trades)
                [[ -z $dtype ]] || { echo "Can't specify type more than once." && usage 1; }
                dtype="trades"
                shift 1
                ;;

            --aggtrades)
                [[ -z $dtype ]] || { echo "Can't specify type more than once." && usage 1; }
                dtype="aggTrades"
                aggtrades=true
                shift 1
                ;;
            
            --years)
                years="$2"
                shift 2
                ;;

            --months)
                months="$2"
                shift 2
                ;;

            --help|-h)
                usage 1
                ;;

            *)
                echo >&2 "Invalid option: $1"
                usage 1
                ;;
        esac
    done
}

function validate_arg_pair() {
    pair="$1"
    valid_pairs_file=$(echo "$(dirname $0)/pairs.txt")

    [[ -n "$pair" ]] || {
        echo -e "No pair provided. Aborting.\n" && usage 1
    }

    if [[ -z $(grep -iw $pair $valid_pairs_file)  ]];then
        echo -e "${cerr}Invalid pair.${cdef}" && usage 1
    fi
}


function validate_arg_type() {
    dtype=$1

    # will be empty if --klines isn't specified.
    klines=$2

    if [[ -z $dtype ]] || [[ ! "$dtype" =~ ^(klines|trades|aggTrades) ]];then
        echo 'Invalid type.' && usage 1
    fi


}

function validate_arg_klines() {
    klines="$1"

    if [[ -z $klines ]] || ! [[ "$klines" =~ ^(1m|3m|5m|15m|30m|1h|2h|4h|6h|8h|12h|1d|3d|1w|1mo)$  ]];then
        echo -e "Invalid klines interval provided. Aborting.\n" && usage 1
    fi
}

function validate_arg_years() {
    years="$1"
    if [[ -z $years ]] || [[ "$years" == "all" ]];then
        start_year="2017";
        end_year="$(date '+%Y')";
    else
        if [[ $(grep -o '-' <<< $years | grep -c .) -eq 1 ]];then
            start_year=$(awk -F '-' '{print $1}' <<< $years)
            end_year=$(awk -F '-' '{print $2}' <<< $years)
        else
            start_year=$years
            end_year=$years
        fi

        if ! [[ "$start_year" =~ ^[0-9]+$ ]] || ! [[ "$end_year" =~ ^[0-9]+$ ]];then
            echo -e "Invalid --years provided. Accepted formats are 'all', '<year>' or '<start_year>-<end_year>'." && usage 1
        elif [[ "$start_year" -gt $(date '+%Y') ]] || [[ "$end_year" -gt $(date '+%Y') ]];then
            echo -e "Years can't be higher than current year." && usage 1
        elif [[ "$start_year" -gt "$end_year" ]];then
            echo -e "Start year can't be higher than end year." && usage 1
        elif [[ "$start_year" -lt 2017 ]];then
            echo -e "Binance opened in 2017, start year can't be smaller than 2017." && usage 1
        fi
    fi
}

function validate_arg_months() {
    months="$1"
    if [[ -z $months ]] || [[ "$months" == "all" ]];then
        start_month=1
        end_month=12
    else
        if [[ $(grep -o '-' <<< $months | grep -c .) -eq 1 ]];then
            start_month=$(awk -F '-' '{print $1}' <<< $months)
            end_month=$(awk -F '-' '{print $2}' <<< $months)
        else
            start_month=$months
            end_month=$months
        fi

        if ! [[ "$start_month" =~ ^[0-9]+$ ]] || ! [[ "$end_month" =~ ^[0-9]+$ ]];then
            echo -e "Invalid --months provided. Accepted formats are 'all', '<month>' or '<start_month>-<end_month>'."
            usage 1
        elif [[ "$start_month" -gt "$end_month" ]];then
            echo -e "Start month can't be higher that end month. Accepted formats are 'all', '<month>' or '<start_month>-<end_month>'."
            usage 1
        elif [[ "$start_month" -lt 1 ]] || [[ "$end_month" -gt 12 ]];then
            echo -e "Invalid --months provided. Accepted formats are 'all', '<month>' or '<start_month>-<end_month>'."
            usage 1
        fi

    fi
}

function usage() {
    cat <<EOF
Usage: $0 --pair <pair> [TYPE] [OPTIONAL] | [ -h | --help ]
    --pair <pair>                                                             The pair we get the data for. BTCUSDT, AAVEUST, ETHBTC etc.
TYPE                                                                          Specify only one of --klines --trades and --aggtrades
    --klines <interval>                                                       The interval offered by binance. Choose between 1m|3m|5m|15m|30m|1h|2h|4h|6h|8h|12h|1d|3d|1w|1mo.
OR
    --trades                                                                  Download old market trades for the specified pair.
OR
    --aggtrades                                                               Download old aggregated trades for the specified pair.
[OPTIONAL]
    --years  <all | start_year-end_year | year>                               The period of year(s) to download data for.  Defaults to 'all'. I.e. from when it's listed on the exchange until now.
    --months <all | start_month-end_month | month>                            The period of month(s) to download data for. Defaults to 'all'. I.e. for every month of the year.

Examples:
$(basename $0) --help                                                              Prints this.
$(basename $0) --pair AAVEUST --interval 1m                                        Downloads all 1 minute spot kline data for pair AAVEUST for every month of every year since the listing of the pair.
$(basename $0) --pair ETHUSDT --interval 30m --years all --months 3                Downloads all 30 minute spot kline data for pair ETHUSDT only for month march for every year since the listing of the pair.
$(basename $0) --pair DOGEUSDC --interval 1mo --years 2020-2021 --months 3-6       Downloads all 1 month spot kline data for pair DOGEUSDC for the years 2020 and 2021, only for months March,April,May,June. If the pair wasn't listed in this period, we do nuthin'. 
$(basename $0) --aggtrades --pair 1INCHUPUSDT --years 2021                         Downloads all aggregate trades for pair 1INCHUPUSDT for the year 2021.
$(basename $0) --trades --pair AGLDBTC                                             Downloads all historical trades for pair AGLDBTC, since it's listing.

Notice: All available pairs can be found at pairs.txt
EOF
    exit $1
}

function _wget() {
    wget --verbose --directory-prefix=$data_dir $url 1>>$log_file 2>&1

    if [[ $? -ne 0 ]]; then
        echo -e "No available data for period $period_as_date" | tee -a $log_file
        return 1
    fi

    return 0
}


function _unzip() {
    unzip -qo $zip_file -d $data_dir 1>>$log_file 2>&1

    if [[ $? -ne 0 ]];then
        echo -e "${cerr}Failed${cdef} to unzip $zip_file." | tee -a $log_file
        return 1
    fi

    return 0
}
