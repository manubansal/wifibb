#!/usr/bin/env bash

touch pers.txt
rm pers.txt
touch avgsnrs.txt
rm avgsnrs.txt
touch snrper.txt
rm snrper.txt
for i in `ls a*_output`; do
#for i in `ls a38*_output`; do
  resline_per=`grep n_crc_unknown $i` 
  echo $resline_per
  resline_per=`grep n_crc_unknown $i | cut -d " " -f 1 | cut -d ":" -f 2`
  resline_per="n_crc_correct/n_crc:$resline_per"
  echo $i  $resline_per
  echo $i  $resline_per >> pers.txt 

  cat $i | grep -i -A 2 snr_db | tr -d '\n' | sed 's/--/\n/g' > snrs_${i}.txt
  sort -s -k1,1 snrs_${i}.txt > sorted_snrs_${i}.txt

  resline_snr=`cat sorted_snrs_${i}.txt | grep avg_snr_db`

  pwrsnrmin=`cat sorted_snrs_${i}.txt | grep power_ratio | sort -n -k 3 | head -n 1 | tr -d ' ' | cut -d '=' -f 2`
  pwrsnrmax=`cat sorted_snrs_${i}.txt | grep power_ratio | sort -n -k 3 | tail -n 1 | tr -d ' ' | cut -d '=' -f 2`
  #echo $i $pwrsnrmin
  #echo $i $pwrsnrmax

  evmsnrmin=`cat sorted_snrs_${i}.txt | grep data_const | sort -n -k 3 | head -n 1 | tr -d ' ' | cut -d '=' -f 2`
  evmsnrmax=`cat sorted_snrs_${i}.txt | grep data_const | sort -n -k 3 | tail -n 1 | tr -d ' ' | cut -d '=' -f 2`
  #echo $i $evmsnrmin
  #echo $i $evmsnrmax

  resline_snr="$resline_snr pwrsnr = $pwrsnrmin,$pwrsnrmax evmsnr = $evmsnrmin,$evmsnrmax"
  #echo $resline_snr

  echo $i  $resline_snr >> avgsnrs.txt
  echo $i  $resline_snr  $resline_per >> snrper.txt
done

