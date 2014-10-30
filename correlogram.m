function [correlo,correloAxe] = correlogram(data,timeSamp,correloLength);
  
  % abscisses
  freq_Sampling = 1/timeSamp;
  axe_freq = (0.5*freq_Sampling/correloLength)*(0:correloLength-1);
  correloAxe = axe_freq;
  
  % Calcul � l'aide d'une transform�e de Fourier
  coeffs = xcorr(data,'unbiased');
  
  correlo = fft(coeffs,2*correloLength);
  correlo = correlo(1:correloLength);
  correlo = real(timeSamp*correlo.*conj(correlo));
end