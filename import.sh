#!/bin/bash

sfile=$(basename $0)
sdir=$(cd "$(dirname "$0")" ; pwd -P)

# -------------- Load dependencies  -------------- #
. "${sdir}/utils.sh"                               #
. "${sdir}/db.sh"                                  #
. "${sdir}/klines.sh"                              #
. "${sdir}/trades.sh"                              #
. "${sdir}/aggtrades.sh"                           #
# ------------------------------------------------ #


# ------------------------------------------------ #
#             Initialize & Validate                # 
# ------------------------------------------------ #

parse_args $@
validate_arg_pair $pair
validate_arg_type $dtype $klines
validate_arg_years $years
validate_arg_months $months

# Get db credentials from first row of ~/.pgpass.
get_db_creds

if [[ "$dtype" == "klines" ]];then
    data_dir="${sdir}/data/spot/${dtype}/${pair}/${klines}"
else
    data_dir="${sdir}/data/spot/${dtype}/${pair}"
fi

base_url="https://data.binance.vision/data/spot"
log_dir="${sdir}/log"
log_file="${log_dir}/${pair}-${dtype}.log"
valid_pairs_file="${sdir}/pairs.txt"

[[ -d $data_dir ]] || mkdir -p $data_dir
[[ -d $log_dir  ]] || mkdir -p $log_dir
[[ -f $log_file ]] || touch $log_file

start_time=$(date +'%Y/%m/%dT%T.%3N')
start_time_ts=$(date --date $start_time +%s)
echo -e "${cneutral}Script starts at $start_time UTC.${cdef}" | tee -a $log_file

if [[ $(grep -qiw $pair $valid_pairs_file) -ne 0 ]];then
    echo -e "${cerr}Invalid pair.${cdef}" && usage 1
fi



# Get pair id from the database
pair_id=$(dbconn "SELECT id FROM pairs WHERE pair='$pair'" 2>>$log_file)

[[ -n $pair_id ]] || { 
    echo -e "${cerr}No${cdef} entry for pair $pair. Inserting." | tee -a $log_file
    init_pair $pair 1>>$log_file 2>&1
    pair_id=$(dbconn "SELECT id FROM pairs WHERE pair='$pair'" 2>>$log_file)

    [[ -n $pair_id ]] || { echo -e "${cerr}Unable${cdef} to get pair_id. Exiting." | tee -a $log_file && exit 1; }

    echo -e "${cok}Initialized pair $pair with id $pair_id ${cdef}" | tee -a $log_file
}

dbpass_censored=$(printf "%0.s*" $(seq 1 $(wc -c <<< $dbpass)))
echo -e "$cneutral
#---------------------------------------------------------------------------------------------#
Database host:       $dbhost
Database port:       $dbport
Database name:       $dbname
Database user:       $dbuser
Database pass:       $dbpass_censored
#---------------------------------------------------------------------------------------------#
Base endpoint:       $base_url
Pair:                $pair
Type:                $dtype
$( [[ "$dtype" == "klines" ]] && echo "Interval:            $klines")
Data for Year(s):    $years
Data for Month(s):   $months
pair_id:             $pair_id
Script:              $sfile
Script dir:          $sdir
Data dir:            $data_dir
Log dir:             $log_dir
Log file:            $log_file
#---------------------------------------------------------------------------------------------#
$cdef                                                   
" | tee -a $log_file


# ------------------------------------------------ #
#            Action begins from here               #
# ------------------------------------------------ #
current_year=$(date '+%Y')
current_month=$(date '+%m')
current_day=$(date '+%d')
for year in $(seq $start_year $end_year);do
    if [[ $year -eq $current_year ]] && [[ $end_month -gt $current_month ]]; then
        end_month=$current_month
    fi

    for month in $(seq $start_month $end_month);do
        # seq -w expansion doesn't seem to always work
        [[ $month -lt 10 ]] && month="0$month"

        if [[ $year -eq $current_year ]] && [[ $month -eq $current_month ]];then
            for day in $(seq 1 $current_day);do
                # seq -w expansion doesn't seem to always work
                [[ $day -lt 10 ]] && day="0$day"

                period="daily"
                period_as_date="${year}-${month}-${day}"

                process_start=$(date --date $(date +'%Y/%m/%dT%T.%3N') +%s)
                case "$dtype" in
                    klines)
                        _process_klines
                        [[ $? -eq 1 ]] && continue
                        ;;
                    trades)
                        _process_trades
                        [[ $? -eq 1 ]] && continue
                        ;;
                    aggTrades)
                        _process_aggtrades
                        [[ $? -eq 1 ]] && continue
                        ;;
                esac
                process_end=$(date --date $(date +'%Y/%m/%dT%T.%3N') +%s)

                echo -e "${cok}Successfully${cdef} downloaded and imported $url into database '$dbname'. It took $(expr $process_end - $process_start) seconds." | tee -a $log_file
            done
        else
            period="monthly"
            period_as_date="${year}-${month}"

            process_start=$(date --date $(date +'%Y/%m/%dT%T.%3N') +%s)
            case "$dtype" in
                klines)
                    _process_klines
                    [[ $? -eq 1 ]] && continue
                    ;;
                trades)
                    _process_trades
                    [[ $? -eq 1 ]] && continue
                    ;;
                aggTrades)
                    _process_aggtrades
                    [[ $? -eq 1 ]] && continue
                    ;;
            esac
            process_end=$(date --date $(date +'%Y/%m/%dT%T.%3N') +%s)

            echo -e "${cok}Successfully${cdef} downloaded and imported $url into database '$dbname'. It took $(expr $process_end - $process_start) seconds." | tee -a $log_file
        fi
    done
done

end_time=$(date +'%Y/%m/%dT%T.%3N')
end_time_ts=$(date --date $end_time +%s)
echo -e "Script finished at $end_time UTC. It ran for $(expr $end_time_ts - $start_time_ts) seconds." | tee -a $log_file
