% Computes and displays (default) the one-sided FFT for REAL 'data'
% [fftR,fftAxe] = FFTR(data,timeSamp,fftLength,fftDim)
% plus the frequency axis, with harmonic amplitude preservation
% 'timeSamp' = 1 (default)
% 'fftLength' equals data length (default) or specified
% length or the next power of two (fftLength = 'n')
% 'fftDim' applies the FFT operation across the
%  dimension DIM.

% Example:
  length_Signal = 512;
  time = (0:length_Signal-1)'/length_Signal;
  time_Sampling = median(diff(time));
  data = cos(64*pi*time);

  figure;clf
  subplot(2,1,1)
  plot(time,data);axis tight;grid on;xlabel('Time (s)');ylabel('Amplitude (a. u.)');
  subplot(2,1,2);hold on
  [fft_R,fft_Axe] = FFTR(data,time_Sampling);
  [fft_R_Max,fft_R_Idx] = max(fft_R);
  plot(fft_Axe,fft_R,'x');axis tight;grid on;xlabel('Frequency (Hz)');ylabel('Amplitude (a. u.)');
  plot(fft_Axe(fft_R_Idx),fft_R(fft_R_Idx),'ro');
  title('Transformée de Fourier discrète');
  
  
% Uses: fft
%
%	Author: Laurent C. Duval
%	Institution: IFP Energies nouvelles, Technology Department
%	Website: http://www.laurent-duval.eu
%	Created: 05/07/2002
%	Modified: 05/05/2003