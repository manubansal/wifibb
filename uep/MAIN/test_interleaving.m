% Number of rows in I_array has to be a multiple of 48. Same holds true for P_array.
 cd ~/Dropbox/Research/Apex/c/


 I_array = reshape(1:48*6, 48,6);
 P_array = reshape(1:144*6, 144,6);
 P_array = P_array + 1000;
 msg_int = vidwifi_interleave(I_array, P_array);
 [I_de_array, P_de_array] = vidwifi_deinterleave(msg_int, 4, 48);
 norm(I_de_array - I_array)

 norm(P_de_array - P_array)

