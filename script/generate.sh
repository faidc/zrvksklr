#!/bin/bash

conf=/etc/sing-box
sb="./sing-box"

fetch_file(){
    local git_token="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"
    local custom_git="https://raw.githubusercontent.com/faidc/vps-tunnel/main"
    local rule_git="https://github.com/malikshi/sing-box-geo/releases/latest/download"
    local rules_dir="/etc/sing-box/rules"

    if [ ! -d "$rules_dir" ]; then
        mkdir -p "$rules_dir"
    fi

    curl -L --header "Authorization: token $git_token" $custom_git/rule-custom.json > $conf/rules/rule-custom.json
    #curl -L https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt > $conf/rules/adguard.txt
    curl -L $rule_git/geoip.db -o $conf/geoip.db
    curl -L $rule_git/geosite.db -o $conf/geosite.db

    #$sb rule-set convert -t adguard $conf/rules/adguard.txt -o $conf/rules/adguard.srs
    #wait $!
    #$sb rule-set compile $conf/rule-custom.json -o $conf/rules/rule-custom.srs
    wait $!
}

export_compile(){
    local type=$1
    local rules=("${!2}")

    for rule in "${rules[@]}"; do
        $sb $type export $rule -o $conf/$rule.json -f $conf/$type.db
        wait $!

        $sb rule-set compile $conf/$rule.json -o $conf/rules/$rule.srs
        wait $!

        rm -r $conf/$rule.json
        sleep 1
    done
}

cleanup() {
    rm -r $conf/{geoip.db,geosite.db,rules/adguard.txt}
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
