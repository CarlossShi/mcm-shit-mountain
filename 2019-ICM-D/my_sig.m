problem=imread('test190127.png'); %可能要改变读取文件
my_sig=zeros(3420,1395);

R=ball_search([1849,750],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=4; %要人为改变方向
end
 
R=ball_search([105,305],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=2; %要人为改变方向
end
 
R=ball_search([97,699],problem);%要人为索引位置
R1=R(R(:,1)>105,:);
for i =1:size(R1,1)
     my_sig(R1(i,1),R1(i,2))=7; %要人为改变方向
end
R2=R(R(:,1)<=105,:);
for i =1:size(R2,1)
     my_sig(R2(i,1),R2(i,2))=2; %要人为改变方向
end

R=ball_search([145,852],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=6; %要人为改变方向
end

R=ball_search([347,1332],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=2; %要人为改变方向
end

R=ball_search([397,1331],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=8; %要人为改变方向
end

R=ball_search([572,388],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=8; %要人为改变方向
end

R=ball_search([477,853],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=6; %要人为改变方向
end

R=ball_search([895,934],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=2; %要人为改变方向
end

R=ball_search([1987,371],problem);%要人为索引位置
R1=R(R(:,1)>1989,:);
for i =1:size(R1,1)
     my_sig(R1(i,1),R1(i,2))=8; %要人为改变方向
end
R2=R(R(:,1)<=1989,:);
for i =1:size(R2,1)
     my_sig(R2(i,1),R2(i,2))=2; %要人为改变方向
end

R=ball_search([2156,301],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=2; %要人为改变方向
end

R=ball_search([2260,708],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=4; %要人为改变方向
end

R=ball_search([2276,736],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=4; %要人为改变方向
end

R=ball_search([2252,764],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=1; %要人为改变方向
end

R=ball_search([2627,388],problem);%要人为索引位置
for i =1:size(R,1)
     my_sig(R(i,1),R(i,2))=8; %要人为改变方向
end

