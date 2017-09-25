#!/bin/sh 

fix_tocs (){

perl -p -e 's/<br><span class="title">/<h1>/g' $1 > temp
mv temp $1
perl -p -e 's/<\/span><\/p>/<\/h1>/g' $1 > temp
mv temp $1
perl -p -e 's/<td valign="top"><\/td>/<\/p><p>/g' $1 > temp
mv temp $1
perl -p -e 's/<td valign="top" class="bgx"><span class="mib">/<b>/g' $1 > temp
mv temp $1
perl -p -e 's/<td valign="top"><span class="m">/ /g' $1 > temp
mv temp $1
perl -p -e 's/<td valign="top"><span class="xsmg">/ /g' $1 > temp
mv temp $1
perl -p -e 's/MB\)<\/span><\/td>/MB\)/g' $1 > temp
mv temp $1
perl -p -e 's/<\/a><\/td>/<\/a>/g' $1 > temp
mv temp $1
perl -p -e 's/<\/span><\/td>/<\/li>/g' $1 > temp
mv temp $1
perl -p -e 's/<td valign="top"><a/<li><a/g' $1 > temp
mv temp $1
perl -p -e 's/tr>/ul>/g' $1 > temp
mv temp $1
}

fix_tocs toc_durley1.html
fix_tocs toc_euler1.html
fix_tocs toc_evans1.html
fix_tocs toc_ferguson1.html
fix_tocs toc_gradenwitz1.html
fix_tocs toc_grubler1.html
fix_tocs toc_guericke1.html
fix_tocs toc_hachette1.html
fix_tocs toc_hartenberg1.html
fix_tocs toc_huygens1.html
fix_tocs toc_kennedy1.html
fix_tocs toc_kennedy2.html
fix_tocs toc_kennedy3.html
fix_tocs toc_kennedy4.html
fix_tocs toc_laboulaye1.html
fix_tocs toc_lanz1.html
fix_tocs toc_leonardo1.html
fix_tocs toc_leopold1.html
fix_tocs toc_leupold1.html
fix_tocs toc_leupold2.html
fix_tocs toc_leupold3.html
fix_tocs toc_mariano.html
fix_tocs toc_monge1.html
fix_tocs toc_muybridge1.html
fix_tocs toc_newark1.html
fix_tocs toc_newark2.html
fix_tocs toc_poinsot1.html
fix_tocs toc_rankine1.html
fix_tocs toc_rankine2.html
fix_tocs toc_redtenbacher1.html
fix_tocs toc_reuleaux1.html
fix_tocs toc_reuleaux2.html
fix_tocs toc_reuleaux3.html
fix_tocs toc_reuleaux4.html
fix_tocs toc_reuleaux5.html
fix_tocs toc_reuleaux6.html
fix_tocs toc_schroder1.html
fix_tocs toc_sciam1.html
fix_tocs toc_strada1.html
fix_tocs toc_thurston1.html
fix_tocs toc_thurston2.html
fix_tocs toc_valturio1.html
fix_tocs toc_voigt1.html
fix_tocs toc_voigt2.html
fix_tocs toc_wankel1.html
fix_tocs toc_weisbach1.html
fix_tocs toc_weisbach2.html
fix_tocs toc_willis1.html
fix_tocs toc_willis2.html
fix_tocs toc_zeising1.html
fix_tocs toc_zonca1.html
fix_tocs toc_zopke1.html
