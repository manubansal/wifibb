#!/usr/bin/env bash

#grep "n_crc_unknown" a30db_output
for i in `ls a*_output`; do
  resline=`grep n_crc_unknown $i`
  echo $i  $resline
done
