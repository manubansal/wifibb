
%----------------------------------------------------------------------------------------------------------------------------
function writeVars_corr(corrvec, abscorrvec, abscorrvecsq, norm1val, norm2val, normval, corrwin, norm1terms, norm2terms, isMetricHigh)
%----------------------------------------------------------------------------------------------------------------------------
  util_writeVarToCFile(norm1terms, 'norm1terms', 0, 30, 'Uint32');
  %util_writeVarToCFile(norm1val, 'norm1val', ceil(log2(corrwin)), 30, 'Uint32');	%scale down by window size rounded to 
  											%(ceiled to) power of 2
  util_writeVarToCFile(norm1val, 'norm1val', 0, 30, 'Uint32');				%no scaling down
  util_writeVarToCFile(norm1val .* norm1val, 'norm1sqval', 0, 30, 'Uint32');				%no scaling down

  util_writeVarToCFile(isMetricHigh, 'isMetricHigh', 0, 0, 'Uint32');			%Qval = 0 corresponds to integer
end
