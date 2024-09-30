#!/bin/bash

sb="/usr/local/bin/sing-box"

fetch_file(){
    local rule_git="https://github.com/malikshi/sing-box-geo/releases/latest/download"

    curl -L $rule_git/geoip.db -o geoip.db
    curl -L $rule_git/geosite.db -o geosite.db

    #$sb rule-set convert -t adguard adguard.txt -o adguard.srs
    wait $!
}

export_compile(){
    local type=$1
    local rules=("${!2}")

    for rule in "${rules[@]}"; do
        $sb $type export $rule -o $rule.json -f $type.db
        wait $!

        $sb rule-set compile $rule.json -o $rule.srs
        wait $!

        rm -r $rule.json
        sleep 1
    done
}

cleanup() {
    rm -r {geoip.db,geosite.db}
}

main(){
    local rule_site=("oisd-full" "oisd-nsfw" "rule-indo" "rule-doh" "rule-malicious" "bank-id" "youtube" "google" "google-ads" "rule-speedtest" "rule-ipcheck")
    local rule_ip=("netflix" "id")
    fetch_file
    export_compile "geosite" rule_site[@]
    wait $!
    export_compile "geoip" rule_ip[@]
    cleanup
}
main
