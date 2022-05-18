function _modify_aggtrades_csv() {
    tmp_file="${csv_file}.tmp"

    awk -F ',' -v pair_id="$pair_id" '{ printf pair_id "," $1 "," $4 "," $5 "," "%.0f" "," $2 "," $3 "," $7 "," $8 "\n" ,$6/1000}' $csv_file > $tmp_file 2>>$log_file

    if [[ $? -ne 0 ]];then
        echo -e "${cerr}Failed${cdef} to modify $csv_file." | tee -a $log_file
        return 1
    fi

    mv --verbose $tmp_file $csv_file 1>>$log_file 2>&1
    return $?
}

function _import_aggtrades() {
    dbconn "\copy aggtrades(pair_id, trade_id, first_trade_id, last_trade_id, ts, price, quantity, maker, isbestmatch) FROM '$csv_file' DELIMITER ',' CSV"

    if [[ $? -eq 1 ]];then
        echo -e "${cerr}Failed${cdef} to import $csv into database '$dbname'" | tee -a $log_file
        return 1
    fi

    return 0
}

function _process_aggtrades() {
    file="${pair}-${dtype}-${period_as_date}"
    zip_file="${data_dir}/${file}.zip"
    csv_file="${data_dir}/${file}.csv"

    url="$base_url/${period}/${dtype}/${pair}/${file}.zip"

    _wget
    [[ $? -eq 1 ]] && return 1

    _unzip
    [[ $? -eq 1 ]] && return 1

    _modify_aggtrades_csv
    [[ $? -eq 1 ]] && return 1

    _import_aggtrades
    [[ $? -eq 1 ]] && return 1

    return 0
}
