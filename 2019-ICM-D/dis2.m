function [dd]=dis2(A,B,pic,up_stair,down_stair,stair)  %两团点的像素最短距离（不同层），A、B为n×2的矩阵
%返回A和B所在层数
f1=6-ceil(A(1,1)/684);%出发楼层
f2=6-ceil(B(1,1)/684);%目的楼层
dd=0;
while f1~=f2
    if f1<f2 %上楼
        [d,~,X]=dis1(A,pos_n([up_stair;stair],f1)); %A→X，从出发地移动至同层电梯
        dd=dd+d; 
        f1=f1+1;
        A=ele_match(X,pic,up_stair,down_stair,stair);
        dd=dd+dis1([X(:,1)-684,X(:,2)],pos_n(A,f1));    %X→R,乘上电梯，出现在上层电梯口
    end
    if f1>f2 %下楼
        [d,~,X]=dis1(A,pos_n([down_stair;stair],f1)); %A→X，从出发地移动至同层电梯
        dd=dd+d; 
        f1=f1-1;
        A=ele_match(X,pic,up_stair,down_stair,stair);
        dd=dd+dis1([X(:,1)+684,X(:,2)],pos_n(A,f1));    %X→R,乘上电梯，出现在下层电梯口
    end
end
dd=dd+dis1(A,B);