#!/bin/sh

fix_dns(){
              perl -p -e 's/http:\/\/ebooks\.library\.cornell\.edu//g' $1 > temp
              mv temp $1
              echo "fixing $1"
              }

fix_dns about.html
fix_dns browse.html
fix_dns guidelines.html
fix_dns help.html
fix_dns index.html
fix_dns moa_adv.html
fix_dns moa_browse.html
fix_dns moa_collection.html
fix_dns moa_conversion.html
fix_dns moa_faq.html
fix_dns moa_implement.html
fix_dns moa_mail.html
fix_dns moa_monographs.html
fix_dns moa_search.html
fix_dns permissions.html
fix_dns print.html
fix_dns search.html
