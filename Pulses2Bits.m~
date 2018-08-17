function BitsDisc=Pulses2Bits(Carrier, RZPulsesTrain, RZPulsesTrainTime, Id, DSigmaNoise)

    RZPulsesTrain= OpticalFilter(RZPulsesTrain, Carrier.NPtos_Tot);

  % Optical -> Electrical signal (current)
  for i=1: Carrier.NPtos_Tot
      RZPulsesTrain(i)= RZPulsesTrain(i)* RZPulsesTrain(i);	% optical amplitude-> optical power= electrical current (detector responsivity R= 1)
  end
  
  % 'THERMAL' NOISE AT DETECTOR
  % float DNoiseVector[(*Carrier).NPtos_Tot];						% Thermal noise vector
    % GenRuidoRapido(DNoiseVector, *DSigmaNoise, (*Carrier).NPtos_Tot);		 	% NoiseVector amplitude
    DNoiseVector= wgn(Carrier.NPtos_Tot,1,DSigmaNoise^2,'linear','real');          % MATLAB GAUSSIAN NOISE
    
  for i=1: Carrier.NPtos_Tot
      RZPulsesTrain(i)= RZPulsesTrain(i)+ DNoiseVector(i);		% Noise addition to electrical current signal
  end
  %WriteFile("antes.dat", RZPulsesTrainTime, RZPulsesTrain, (*Carrier).NPtos_Tot);	% TEST train to file

  RZPulsesTrain= ElectricalFilter(RZPulsesTrain, Carrier.NPtos_Tot);
  %WriteFile("despues.dat", RZPulsesTrainTime, RZPulsesTrain, (*Carrier).NPtos_Tot);	% TEST train to file

  BitsDisc= zeros(Carrier.N_Bits,1);
  SamplingPoint= 45;
  for i=1:Carrier.N_Bits
    if ( RZPulsesTrain((i-1)* Carrier.NPtos_Bit+ SamplingPoint)> Id)
        BitsDisc(i)=1;
    else
        BitsDisc(i)=0;
    end
  end

