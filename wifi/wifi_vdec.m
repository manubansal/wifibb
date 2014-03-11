function [ dmsg ] = wifi_vdec(incode, nbits, tblen, mode, chunksize, msglen)
%msglen is excluding the tail length
%
%VDEC Viterbi decoder tester function. 
%It can be passed in a coded message, or be called without any 
%input arguments. In both cases, the 802.11 trellis is used for
%decoding.
%incode : coded soft-bit sequence
%nbits  : code soft-bits are in [0, 2^nbits - 1]
%tblen  : traceback length

  initmetric = [];
  initstates = [];
  initinputs = [];

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
    if strcmp(mode, 'trunc')
      %truncated mode decode - asssumes head start state but non-terminated sequence

      if chunksize == 0
	dmsg=vitdec(code,trellis,tblen,'trunc','soft',nbits);
      else
	%if mod(length(code), chunksize) ~= 0
	%  error('coded message length not a multiple of chunksize')
	%end
	chunksize_coded = chunksize * 2;
	tblen_coded = tblen * 2;

	chunksize_multiple = chunksize_coded * ceil((msglen + 6) * 2 / chunksize_coded);
	nchzr = chunksize_multiple - (msglen + 6) * 2;

	code = code(:);
	code = code(1:((msglen + 6)*2));
	chzr = zeros(nchzr,1);
	code = [code; chzr];

	chunks = reshape(code, chunksize_coded, []);

	pre = chunks(end-tblen_coded+1:end, 1:end-1);
	prezr = zeros(tblen_coded,1);
	pre = [prezr pre];

	post = chunks(1:tblen_coded, 2:end);
	postzr = zeros(tblen_coded, 1);
	post = [post postzr];

	frames = [pre; chunks; post];
	%size_frames = size(frames)

	nframes = size(frames, 2);

	dframes = [];
	for ii = 1:nframes
	  code = frames(:,ii);
	  dframe=vitdec(code,trellis,tblen,'trunc','soft',nbits);
	  dframes = [dframes dframe];
	end

	dframes(1:tblen,:) = [];
	dframes(end-tblen+1:end,:) = [];
	%size_frames = size(dframes)
	dmsg = reshape(dframes, [], 1);
	dmsg = dmsg(1:(msglen+6));
      end
      %dmsg(end-5:end) = [];
    elseif strcmp(mode, 'cont')
      %continuous mode decoding: delays output by tblen (fills tblen 
      %zeroes in the output sequence before decisions)
      %dmsg=vitdec(code,trellis,tblen,'cont','soft',8);

      %continous mode with init states etc
      %dmsg=vitdec(code,trellis,tblen,'cont','soft',8,[],[],[]);

      %initmetric = zeros(1,2^6);
      %initstates = zeros(2^6,tblen);
      %initinputs = zeros(2^6,tblen);
      dmsg=vitdec(code,trellis,tblen,'cont','soft',nbits,initmetric,initstates,initinputs);
    else
      error('bad wifi_vdec mode')
    end
  end

  dmsg = dmsg;
end
