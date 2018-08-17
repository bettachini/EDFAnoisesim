function RT
% function RT(InBitString)
InBitString= 'AT_1_15.dat';

% intro
  maxdata=4096;

% path
  local= pwd;
  stringPath= '/home/vbettachini/Documentos/PONs/simulations/Strings';
  cd(stringPath);

%% reading
  %InBitFID= fopen(InBitString,'r','l');	% opens file for reading in little-endian format
  %while ( ~feof(InBitFID) &&  )
    %val=fread(InBitFID,1,'char');
    %val
  %end
  %fclose(InBitFID);

%% reading a la C
  %InBitFID= fopen(InBitString,'r','l');	% opens file for reading in little-endian format
  %i=1;
  %while( ( [val, N_Bits]= fread(InBitFID,maxdata) )> 0)
  %end
  %fclose(InBitFID);
  %val
  
  
% reading
% http://www.mathworks.com/access/helpdesk/help/techdoc/import_export/f5-6031.html
  InBitFID= fopen(InBitString,'r','l');	% opens file for reading in little-endian format
  while (~feof(InBitFID) ) 
    [val, N_Bits]= fread(InBitFID,maxdata,'char=>uint8');
    if ~isempty(val)
      val
    end		
  end
  fclose(InBitFID);
  
  
%% writing
  %OutBitString= 'test.dat'; 
  %OutBitFID= fopen(OutBitString,'w+','l');
  %fwrite(OutBitFID, );
  %fclose(OutBitFID);
%  


% end
  cd(local);