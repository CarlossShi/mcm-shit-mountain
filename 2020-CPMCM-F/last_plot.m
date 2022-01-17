plot(1:7200, prob1_oil(:,1),'linewidth',3)
hold on
plot(1:7200, prob1_oil(:,2),'linewidth',3)
hold on
plot(1:7200, prob1_oil(:,3),'linewidth',3)
hold on
plot(1:7200, prob1_oil(:,4),'linewidth',3)
hold on
plot(1:7200, prob1_oil(:,5),'linewidth',3)
hold on
plot(1:7200, prob1_oil(:,6),'linewidth',3)

legend('油箱1','油箱2','油箱3','油箱4','油箱5','油箱6')
title('油量随时间变化图')
xlabel('时间')
ylabel('体积')