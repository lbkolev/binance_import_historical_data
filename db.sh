function get_db_creds() {
    if [[ ! -f ~/.pgpass ]];then
        echo -e "The script works with credentials provided by the first row of the ~/.pgpass file, which seems to be missing
Check out https://www.postgresql.org/docs/current/libpq-pgpass.html for how to create one"
        exit 1
    fi

    dbhost=$(awk -F ':' '{if(NR==1) print $1}' ~/.pgpass)
    dbport=$(awk -F ':' '{if(NR==1) print $2}' ~/.pgpass)
    dbname=$(awk -F ':' '{if(NR==1) print $3}' ~/.pgpass)
    dbuser=$(awk -F ':' '{if(NR==1) print $4}' ~/.pgpass)
    dbpass=$(awk -F ':' '{if(NR==1) print $5}' ~/.pgpass)

    if [[ -z $dbhost ]] || [[ -z $dbport ]] || [[ -z $dbname ]] || [[ -z $dbuser ]] || [[ -z $dbpass ]];then
        echo -e "The script works with credentials provided by the first row of the ~/.pgpass file, which seems to be missing or incomplete
Check out https://www.postgresql.org/docs/current/libpq-pgpass.html for how to create one"
        exit 1
    fi

}

function dbconn() {
    cmd=$1
#    psql "postgresql://$dbuser:$dbpass@$dbhost:$dbport/$dbname?options=--search_path%3dpublic" -Atc "$cmd" 2>&1 | tee $log_file
    psql "postgresql://$dbuser:$dbpass@$dbhost:$dbport/$dbname" -Atc "$cmd"
}

function init_pair() {
    dbconn "INSERT INTO pairs (pair) VALUES ('$1')"
}
