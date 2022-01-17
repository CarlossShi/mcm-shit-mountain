function [P]=pos_rgb(pic,r,g,b)  %返回rgb像素位置
P=zeros(size(pic,1)*size(pic,2),2);
n=1;
for i =1: size(pic,1)
    for j =1:size(pic,2)
        if pic(i,j,1)==r && pic(i,j,2)==g && pic(i,j,3)==b
            P(n,1)=i;P(n,2)=j;
            n=n+1;
        end
    end
end     
P (all(P == 0, 2),:) = []; %删除全0行
end