subplot(2,3,1)
plot(1:7200,prob1_result(:,1),'linewidth',3)
title("质心坐标x轴分量随时间变化")
xlabel('时间(s)') 
ylabel('x(m)') 

subplot(2,3,2)
plot(1:7200,prob1_result(:,2),'linewidth',3)
title("质心坐标y轴分量随时间变化")
xlabel('时间(s)') 
ylabel('y(m)') 

subplot(2,3,3)
plot(1:7200,prob1_result(:,3),'linewidth',3)
title("质心坐标z轴分量随时间变化")
xlabel('时间(s)') 
ylabel('z(m)') 

subplot(2,3,[4:6])

% 参考https://blog.csdn.net/u012366767/article/details/83183868
colorMarker = linspace(1,100,7200);
patch([prob1_result(:,1)' NaN],...
    [prob1_result(:,2)' NaN],...
    [prob1_result(:,3)' NaN],...
    [colorMarker NaN],'EdgeColor','interp','MarkerFaceColor','flat','linewidth',3)
xlabel('x(m)') 
ylabel('y(m)') 
zlabel('z(m)') 
title("质心随时间变化(深色比浅色时间晚)")
%色彩使用插值策略平滑
           
      