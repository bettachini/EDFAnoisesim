function OSigmaNoise=ONoise(Network)

  h= 6.626E-34;					% [J s] Planck constant
  G= Network.EDFAgain* Network.EDFAgain;	% [1] EDFA power gain
  n_sp= 3.5;					% [1]
  nu= Network.CentralNu;			% [Hz]
  S_sp= (G- 1)* n_sp* h* nu;			% [J]
  P_N= S_sp* Network.sim_BW;			% [W]
  P_ASE= 2* P_N;				% [W]
  OSigmaNoise= sqrt(P_ASE);
}


