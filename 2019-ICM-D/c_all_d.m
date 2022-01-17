pic=imread('all.png');
all_d=zeros(3420,1395); %size(walk,1)=1066998
A=walk;
for i =1:size(A,1)
    f=6-ceil(A(i,1)/684);
    if f==2
        d1=dis2([A(i,1),A(i,2)],gate1,pic,up_stair,down_stair,stair);
        d2=dis2([A(i,1),A(i,2)],gate2,pic,up_stair,down_stair,stair);
        d3=dis2([A(i,1),A(i,2)],gate3,pic,up_stair,down_stair,stair);
        all_d(A(i,1),A(i,2))=min([d1,d2,d3]);
    elseif f==1
        d3=dis2([A(i,1),A(i,2)],gate3,pic,up_stair,down_stair,stair);
        all_d(A(i,1),A(i,2))=d3;
    else
        d1=dis2([A(i,1),A(i,2)],gate1,pic,up_stair,down_stair,stair);
        d2=dis2([A(i,1),A(i,2)],gate2,pic,up_stair,down_stair,stair);
        all_d(A(i,1),A(i,2))=min([d1,d2]);
    end
    i
end

%all_d(all_d==0) = max(max(all_d));
%all_d(find(isnan(all_d)==1)) = 0
A=0;
all_d_o=all_d;
[x,y]=meshgrid(1:1395,1:3420);
subplot(1,2,1)
mesh(x,y,all_d)
title('Minimal evacuation distance model')
view(0,90);grid on;
subplot(1,2,2)
mesh(x,y,all_d)
title('Minimal evacuation distance model (overhead view)')
view(0,90);grid on;colorbar
