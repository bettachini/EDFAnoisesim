function RZPulsesTrain= RZTrain(Carrier, Gauss, RZBit1Gauss, InBitString, TrainLength, transmitters)

RZPulsesTrain= zeros(TrainLength,1);
k=0;
while (k<TrainLength)
  senders= InBitString(k+ 1);
  for i=1:Carrier.NPtos_Bit
    % Optical intensities addition
    RZPulsesTrain(k* Carrier.NPtos_Bit+ i)= RZBit1Gauss(i)+ 2* Gauss.A_0;
    RZPulsesTrain(k* Carrier.NPtos_Bit+ i)= RZPulsesTrain(k* Carrier.NPtos_Bit+ i)* senders* RZBit1Gauss(i);
    RZPulsesTrain(k* Carrier.NPtos_Bit+ i)= RZPulsesTrain(k* Carrier.NPtos_Bit+ i)+ transmitters* Gauss.P_0;
    RZPulsesTrain(k* Carrier.NPtos_Bit+ i)= sqrt(RZPulsesTrain(k* Carrier.NPtos_Bit+ i) );
  end
  k= k+ 1;
end

% Write1Col("amplitude1.dat", RZBit1Gauss, (*Carrier).NPtos_Bit);	% TEST bitslot '1'
% Write1Col("RZPulsesTrain.dat", RZPulsesTrain, (*Carrier).NPtos_Tot); % TEST train to file
% for(i=0; i<(*Carrier).NPtos_Tot; i++) printf("%.3e\t%.3e\n",RZPulsesTrainTime[i],RZPulsesTrain[i]); % TEST
