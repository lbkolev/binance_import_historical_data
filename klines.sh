function _modify_klines_csv() {
    tmp_file="${csv_file}.tmp"

    # Fix: scientific notation was used for some entries in opening and closing timestamps. This changes it to BIGINT as it's more easily queried in the database.
    # Example: some entries for timestamp were looking like 1.57787e+09, now should be 1577865599
    awk -F ',' -v pair_id="$pair_id" '{ printf pair_id "," "%.0f" "," $2 "," $3 "," $4 "," $5 "," $6 "," "%.0f" "," $8 "," $9 "," $10 "," $11 "\n", $1/1000, $7/1000}' $csv_file > $tmp_file 2>>$log_file

    if [[ $? -ne 0 ]];then
        echo -e "${cerr}Failed${cdef} to modify $csv_file." | tee -a $log_file
        return 1
    fi

    mv --verbose $tmp_file $csv_file 1>>$log_file 2>&1
    return $?
}



function _import_klines() {

    dbconn "\copy kl_${klines}(pair_id, ts, open, high, low, close, volume, close_ts, qavol, trades, tbavol, tqavol) FROM '$csv_file' DELIMITER ',' CSV"

    if [[ $? -eq 1 ]];then
        echo -e "${cerr}Failed${cdef} import of $csv_file into database '$dbname'." | tee -a $log_file
        return 1
    fi

    return 0

}


function _process_klines() {
    file="${pair}-${klines}-${period_as_date}"
    zip_file="${data_dir}/${file}.zip"
    csv_file="${data_dir}/${file}.csv"
    url="${base_url}/${period}/klines/${pair}/${klines}/${file}.zip"


    _wget
    if [[ $? -eq 1 ]];then return 1;fi
    
    _unzip
    if [[ $? -eq 1 ]];then return 1; fi

    _modify_klines_csv
    if [[ $? -eq 1 ]];then return 1;fi

    _import_klines
    if [[ $? -eq 1 ]];then return 1;fi

    return 0
}
