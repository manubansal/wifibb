function [ dmsg ] = wifi_vdec(incode, nbits, tblen, initmetric, initstates, initinputs)
%VDEC Viterbi decoder tester function. 
%It can be passed in a coded message, or be called without any 
%input arguments. In both cases, the 802.11 trellis is used for
%decoding.
%incode : coded soft-bit sequence
%nbits  : code soft-bits are in [0, 2^nbits - 1]
%tblen  : traceback length
%initmetric: (optional)
%initstates: (optional)
%initinputs: (optional)


trellis=poly2trellis(7,[133 171]);


if nargin > 0
    code = incode;
else
    nbits = 8;
    %code = cenc();
    %v1 = 63 * ones(1,128);
    %code = zeros(1,256);
    %code(1:2:end) = v1;
    code = 255 * ones(1,64);
    code2 = zeros(1,64);
    code2(1:2:end) = 255 * ones(1,32);
    code = code2;
    code
end

if nargin < 3
  %tblen = 8;
  tblen = 36;
end

%decoded = vitdec(code,trellis,tblen,opmode,dectype)
%dmsg=vitdec(code,trellis,8,'trunc','hard');
%dmsg(1:32)

if (nargin < 4)
  %truncated decoding
  %dmsg=vitdec(code,trellis,tblen,'trunc','soft',8);

  %terminated decoding (last K-1 = 6 bits in the input stream of cenc must have been 0)
  dmsg=vitdec(code,trellis,tblen,'term','soft',nbits);

else
  %continuous mode decoding: delays output by tblen (fills tblen 
  %zeroes in the output sequence before decisions)
  %dmsg=vitdec(code,trellis,tblen,'cont','soft',8);

  %continous mode with init states etc
  %dmsg=vitdec(code,trellis,tblen,'cont','soft',8,[],[],[]);

  %initmetric = zeros(1,2^6);
  %initstates = zeros(2^6,tblen);
  %initinputs = zeros(2^6,tblen);
  dmsg=vitdec(code,trellis,tblen,'cont','soft',nbits,initmetric,initstates,initinputs);
end

dmsg = dmsg;
