function [R]=ele_match(A,pic,up_stair,down_stair,stair)
f=6-ceil(A(1,1)/684);%电梯所在楼层
n=randperm(size(A,1),1); %随机选取团中的一个点
c=[pic(A(n,1),A(n,2),1),pic(A(n,1),A(n,2),2),pic(A(n,1),A(n,2),3)];
if c==[185,122,87]  %棕色，上下搜索
    A=[A(:,1)+684,A(:,2)];
    f=f-1;
    [~,~,Y]=dis1([A(n,1),A(n,2)],pos_n([up_stair;stair],f));
    R=ball_search(Y,pic);
    A=[A(:,1)-684*2,A(:,2)];
    f=f+2;
    [~,~,Y]=dis1([A(n,1),A(n,2)],pos_n([down_stair;stair],f));
    R=[R;ball_search(Y,pic)];
elseif c==[255,242,0]   %黄色，往下搜索
    A=[A(:,1)+684,A(:,2)];
    f=f-1;
    [~,~,Y]=dis1([A(n,1),A(n,2)],pos_n([up_stair;stair],f));
    R=ball_search(Y,pic);
elseif c==[255,127,39]  %橙色，往上搜索
    A=[A(:,1)-684,A(:,2)];
    f=f+1;
    [~,~,Y]=dis1([A(n,1),A(n,2)],pos_n([down_stair;stair],f));
    R=ball_search(Y,pic);
else
    fprintf('not elevator\n')
end