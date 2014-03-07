#!/usr/bin/env bash

#grep "n_crc_unknown" a30db_output
for i in `ls a*_output`; do
  resline=`grep n_crc_unknown $i`
  echo $i  $resline > pers.txt 
  #cat $i | grep -i -A 2 snr_db | tr -d '\n' | sed 's/--/\n--/g' | sed 's/constellation_avgsnr_dB_overestimate/evm_avgsnr_dB/g' | sed 's/power_ratio_SNR_dB/pwrrat_snr_dB/g' > ${i}_snrs.txt
  cat $i | grep -i -A 2 snr_db | tr -d '\n' | sed 's/--/\n/g' > snrs_${i}.txt
  sort -s -k1,1 snrs_${i}.txt > sorted_snrs_${i}.txt
done
