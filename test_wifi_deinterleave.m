
function test_wifi_deinterleave()
  nbebp = testbp();
  nbeqp = testqp();
  nbe16 = test16();
  nbe64 = test64();

  n_bit_errs = [nbebp nbeqp nbe16 nbe64]
  pause

  test16FromStd();
end

function n_bit_err = testbp()
  display('testbp');
  t = wifi_deinterleaveTables();

  rand('seed',3)

  %288, 192, 96, 48
  ncbps = 48; nbpsc = 1;
  n_bit = ncbps;

  %Generate random bitstream:
  input_bits = round(rand(n_bit,1));

  interleaved_bits = wifi_interleave(input_bits, ncbps);
  s_interleaved_bits = size(interleaved_bits)
  pause

  deinterleaved_bits = wifi_deinterleave(t, interleaved_bits, nbpsc);
  s_deinterleaved_bits = size(deinterleaved_bits)
  pause

  [input_bits deinterleaved_bits]

  n_bit_err = sum(abs(input_bits - deinterleaved_bits))
end

function n_bit_err = testqp()
  display('testqp');
  t = wifi_deinterleaveTables();

  rand('seed',3)

  %288, 192, 96, 48
  ncbps = 96; nbpsc = 2;
  n_bit = ncbps;

  %Generate random bitstream:
  input_bits = round(rand(n_bit,1));

  interleaved_bits = wifi_interleave(input_bits, ncbps);
  s_interleaved_bits = size(interleaved_bits)
  pause

  deinterleaved_bits = wifi_deinterleave(t, interleaved_bits, nbpsc);
  s_deinterleaved_bits = size(deinterleaved_bits)
  pause

  [input_bits deinterleaved_bits]

  n_bit_err = sum(abs(input_bits - deinterleaved_bits))
end

function n_bit_err = test16()
  display('test16');
  t = wifi_deinterleaveTables();

  rand('seed',3)

  %288, 192, 96, 48
  ncbps = 192; nbpsc = 4;
  n_bit = ncbps;

  %Generate random bitstream:
  input_bits = round(rand(n_bit,1));

  interleaved_bits = wifi_interleave(input_bits, ncbps);
  s_interleaved_bits = size(interleaved_bits)
  pause

  deinterleaved_bits = wifi_deinterleave(t, interleaved_bits, nbpsc);
  s_deinterleaved_bits = size(deinterleaved_bits)
  pause

  [input_bits deinterleaved_bits]

  n_bit_err = sum(abs(input_bits - deinterleaved_bits))
end

function n_bit_err = test64()
  display('test64');
  t = wifi_deinterleaveTables();

  rand('seed',3)

  %288, 192, 96, 48
  ncbps = 288; nbpsc = 6;
  n_bit = ncbps;

  %Generate random bitstream:
  input_bits = round(rand(n_bit,1));

  interleaved_bits = wifi_interleave(input_bits, ncbps);
  s_interleaved_bits = size(interleaved_bits)
  pause

  deinterleaved_bits = wifi_deinterleave(t, interleaved_bits, nbpsc);
  s_deinterleaved_bits = size(deinterleaved_bits)
  pause

  [input_bits deinterleaved_bits]

  n_bit_err = sum(abs(input_bits - deinterleaved_bits))
end

function n_bit_err = test16FromStd()
%coded bits
cbits_m = [
0 0 32 1 64 0 96 1 128 1 160 1
1 0 33 0 65 1 97 0 129 1 161 1
2 1 34 0 66 0 98 0 130 0 162 1
3 0 35 1 67 0 99 0 131 0 163 0
4 1 36 1 68 1 100 1 132 0 164 0
5 0 37 1 69 0 101 1 133 0 165 0
6 1 38 0 70 1 102 1 134 0 166 0
7 1 39 1 71 0 103 1 135 0 167 0
8 0 40 1 72 1 104 1 136 0 168 1
9 0 41 0 73 1 105 1 137 1 169 1
10 0 42 1 74 1 106 0 138 0 170 0
11 0 43 1 75 1 107 0 139 0 171 1
12 1 44 0 76 1 108 0 140 0 172 0
13 0 45 1 77 0 109 0 141 0 173 0
14 0 46 0 78 1 110 0 142 1 174 1
15 0 47 1 79 1 111 0 143 1 175 1
16 1 48 1 80 1 112 1 144 1 176 1
17 0 49 0 81 1 113 1 145 1 177 1
18 1 50 0 82 1 114 0 146 1 178 1
19 0 51 1 83 0 115 0 147 0 179 0
20 0 52 1 84 1 116 1 148 0 180 1
21 0 53 0 85 0 117 0 149 0 181 0
22 0 54 1 86 0 118 0 150 0 182 1
23 1 55 0 87 0 119 0 151 0 183 1
24 1 56 0 88 1 120 0 152 0 184 1
25 1 57 0 89 1 121 1 153 0 185 0
26 1 58 0 90 0 122 1 154 0 186 1
27 1 59 1 91 0 123 1 155 1 187 1
28 0 60 1 92 0 124 0 156 1 188 0
29 0 61 1 93 0 125 0 157 0 189 0
30 0 62 0 94 1 126 1 158 0 190 1
31 0 63 1 95 0 127 1 159 1 191 0
];
cbits = cbits_m(:,[2 4 6 8 10 12]);
cbits = reshape(cbits, prod(size(cbits)), 1);
%pause

%interleaved bits
ibits_m = [
0 0 32 0 64 0 96 0 128 0 160 0
1 1 33 1 65 0 97 1 129 0 161 0
2 1 34 1 66 0 98 1 130 0 162 0
3 1 35 1 67 1 99 0 131 1 163 0
4 0 36 0 68 0 100 1 132 1 164 0
5 1 37 0 69 0 101 1 133 0 165 0
6 1 38 1 70 0 102 1 134 1 166 0
7 1 39 1 71 0 103 0 135 1 167 0
8 1 40 0 72 1 104 0 136 0 168 0
9 1 41 0 73 0 105 0 137 1 169 0
10 1 42 0 74 0 106 1 138 1 170 0
11 1 43 0 75 1 107 1 139 0 171 0
12 0 44 0 76 1 108 1 140 1 172 1
13 0 45 0 77 0 109 0 141 0 173 1
14 0 46 0 78 1 110 0 142 1 174 0
15 0 47 0 79 0 111 0 143 1 175 1
16 1 48 1 80 0 112 1 144 1 176 1
17 1 49 0 81 0 113 1 145 0 177 0
18 1 50 1 82 0 114 1 146 0 178 1
19 0 51 1 83 1 115 1 147 1 179 1
20 1 52 1 84 1 116 0 148 1 180 0
21 1 53 1 85 1 117 1 149 0 181 0
22 1 54 1 86 0 118 0 150 0 182 1
23 1 55 1 87 1 119 1 151 0 183 1
24 1 56 0 88 0 120 0 152 0 184 0
25 1 57 0 89 0 121 1 153 1 185 1
26 0 58 0 90 0 122 1 154 0 186 1
27 0 59 1 91 1 123 0 155 0 187 0
28 0 60 0 92 0 124 1 156 0 188 1
29 1 61 0 93 0 125 0 157 0 189 1
30 0 62 0 94 1 126 0 158 1 190 0
31 0 63 1 95 0 127 1 159 1 191 1
];
ibits = ibits_m(:,[2 4 6 8 10 12]);
ibits = reshape(ibits, prod(size(ibits)), 1);
%pause


  t = wifi_deinterleaveTables();

  %288, 192, 96, 48
  ncbps = 192; nbpsc = 4;

  [ibits2 j] = wifi_interleave(cbits, ncbps);
  %s_interleaved_bits = size(interleaved_bits)
  %pause

  %[(1:ncbps)' j t.qam16]
  [(1:ncbps)' cbits j ibits ibits2 abs(ibits - ibits2) t.qam16]
  %sortrows(t.qam16, 2)]
  %[ibits ibits2]
  pause

  dibits = wifi_deinterleave(t, ibits, nbpsc);
  dibits2 = wifi_deinterleave(t, ibits2, nbpsc);

  n_bit_err = sum(abs(cbits - dibits))
  n_bit_err2 = sum(abs(ibits - ibits2))
  n_bit_err3 = sum(abs(cbits - dibits2))

end
