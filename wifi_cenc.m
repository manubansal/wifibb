function outcode=wifi_cenc(inmsg, ratetimes120)
%CENC Convolution encoder test output generation (written for MATLAB vR2007a)
%Set inpfile for input data file, ratetimes120 for code rates (puncturing),
%nOcts for number of octets to output


if (nargin < 2)
  ratetimes120 = 60
end


trellis=poly2trellis(7,[133 171])

%if nargin > 0
    msg = inmsg;
    %nOcts = fix(length(inmsg)/8);
    %if nOcts * 8 ~= length(inmsg)
    %    error('badInput','%s','input message length is not a multiple of 8\n');
    %end
    %nOcts
%else
%    %bit-stream scrambled data in row-major format
%    inpfile = 'scr_data.dat' %input scrambled data to encode
%    a=load(inpfile); 
%    nOcts = 16
%    msg=reshape(a',1,prod(size(a)));
%end

%code=convenc(msg,trellis);

if ratetimes120 == 60
    puncpat = [1 1]; % for 1/2 rate puncturing (no puncturing)
elseif ratetimes120 == 90
    puncpat=[1 1 1 0 0 1];  % for 3/4 rate puncturing
elseif ratetimes120 == 80
    puncpat=[1 1 1 0]; % for 2/3 rate puncturing
else
    error('cenc:main:invalidCoderate','bad code rate input');
end
    
    
code=convenc(msg,trellis, puncpat);
outcode=code;

%disp('coded bit-stream output (a0 b0 a1 b1 ...)');
%code(:,1:nOcts*8)
%codeocts = reshape(code,8,length(code)/8)';
%
%disp('coded octet output');
%codeocts(1:nOcts,:)
%
%%%%%%%%%%%%%%%%%%%converting to decimal format to make comparison easier %%%%%%%%%%%%%%%%
%val = ones(size(codeocts)) * diag([128 64 32 16 8 4 2 1]);
%
%codedecs = sum(val .* codeocts, 2);
%codedecs(1:nOcts,:)
%
%if ratetimes120 == 60
%    %compute the depunctured sequences (zero-filled) for 2/3 and 3/4
%    dpcode23 = code;
%    dpcode23(1,4:4:end)=0;
%    
%    dpcode34 = code;
%    dpcode34(1,4:6:end)=0;
%    dpcode34(1,5:6:end)=0;
%    
%    %separate out A and B streams to compare with tiwi output
%    codeA = code(1:2:length(code));
%    codeB = code(2:2:length(code));
%
%    disp('codeA sequence');
%    code = codeA;
%    codeocts = reshape(code,8,length(code)/8)';
%    codeocts(1:nOcts,:)
%
%    val = ones(size(codeocts)) * diag([128 64 32 16 8 4 2 1]);
%
%    codedecs = sum(val .* codeocts, 2);
%    codedecs(1:nOcts,:)
%
%    disp('codeB sequence');
%    code = codeB;
%    codeocts = reshape(code,8,length(code)/8)';
%    codeocts(1:nOcts,:)
%
%    val = ones(size(codeocts)) * diag([128 64 32 16 8 4 2 1]);
%
%    codedecs = sum(val .* codeocts, 2);
%    codedecs(1:nOcts,:)
%    
%    disp('2/3 depunctured sequence');
%    code = dpcode23;
%    codeocts = reshape(code,8,length(code)/8)';
%    codeocts(1:nOcts,:)
%
%    val = ones(size(codeocts)) * diag([128 64 32 16 8 4 2 1]);
%
%    codedecs = sum(val .* codeocts, 2);
%    codedecs(1:nOcts,:)
%    
%    disp('3/4 depunctured sequence');
%    code = dpcode34;
%    codeocts = reshape(code,8,length(code)/8)';
%    codeocts(1:nOcts,:)
%
%    val = ones(size(codeocts)) * diag([128 64 32 16 8 4 2 1]);
%
%    codedecs = sum(val .* codeocts, 2);
%    codedecs(1:nOcts,:)
%
%end
