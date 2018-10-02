clear;
% x = 0:0.1:1000;
% y = sin(2*pi*x);
% N = numel(x);
% Ts = 1000 / N;
% omega = (0 : 2 * pi / N: pi) / Ts;
% 
% Un = FFTr(y);
% 
% plot(omega/2/pi,abs(Un(1:numel(omega))))

M = dlmread(convertStringsToChars(strcat('CompData/bag', string(30), '.csv')));
%M = M(1:201,:);
N = size(M,1);
Ts = M(end,1) / N;
omega = (0 : 2 * pi / N: pi) / Ts;
omega = omega(2 : end - 1);

velX = FFTr(M(:,2)');
velY = FFTr(M(:,3)');
velZ = FFTr(M(:,4)');
accX = FFTr(M(:,5)');
accY = FFTr(M(:,6)');
accZ = FFTr(M(:,7)');

figure(1)
    subplot(2,3,1) 
    loglog(omega/2/pi, abs(velX(2:numel(omega)+1)));
    hold on;
    xlabel("Freq (rad/s)");
    ylabel("magnitude (dB)");
    title("vel X");

    subplot(2,3,2) 
    loglog(omega/2/pi, abs(velY(2:numel(omega)+1)));
    hold on;
    xlabel("Freq (rad/s)");
    ylabel("magnitude (dB)");
    title("vel Y");
    
    subplot(2,3,3) 
    loglog(omega/2/pi, abs(velZ(2:numel(omega)+1)));
    hold on;
    xlabel("Freq (rad/s)");
    ylabel("magnitude (dB)");
    title("vel Z");

    subplot(2,3,4) 
    loglog(omega/2/pi, abs(accX(2:numel(omega)+1)));
    hold on;
    xlabel("Freq (rad/s)");
    ylabel("magnitude (dB)");
    title("acc X");
    
    subplot(2,3,5) 
    loglog(omega/2/pi, abs(accY(2:numel(omega)+1)));
    hold on;
    xlabel("Freq (rad/s)");
    ylabel("magnitude (dB)");
    title("acc Y");

    subplot(2,3,6) 
    loglog(omega/2/pi, abs(accZ(2:numel(omega)+1)));
    hold on;
    xlabel("Freq (rad/s)");
    ylabel("magnitude (dB)");
    title("acc Z");
        


function [ Un ] = FFTr(Uk)
  S = size(Uk);
  N = S(1,2);  

  for n = 0 : N-1
    Wn = 2 * pi * n / N;
    sum = 0;  
    for k = 0 : N-1
      val = Uk(k+1) * exp(-i * Wn * k);
      sum = sum + val;       
    end
    Un(n+1) = sum;
  end
  
end