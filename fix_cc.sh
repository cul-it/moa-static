#!/bin/sh

fix_cc(){
              perl -p -e 's/&copy;2015/&copy;2016/g' $1 > temp
              mv temp $1
              echo "fixing $1"
              }

fix_cc about.html
fix_cc browse.html
fix_cc guidelines.html
fix_cc help.html
fix_cc index.html
fix_cc moa_adv.html
fix_cc moa_browse.html
fix_cc moa_collection.html
fix_cc moa_conversion.html
fix_cc moa_faq.html
fix_cc moa_implement.html
fix_cc moa_mail.html
fix_cc moa_monographs.html
fix_cc moa_search.html
fix_cc permissions.html
fix_cc print.html
fix_cc search.html
