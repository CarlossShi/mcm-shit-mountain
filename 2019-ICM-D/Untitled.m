%图像颜色预处理
cd('C:\Users\hasee\Desktop\19美赛\比赛开始\图\5层')
empty=imread('22.png');
s=size(empty)
image(empty)
for i =1:s(1)
    for j=1:s(2)
        if ~(empty(i,j,1)==255 &&  empty(i,j,2)==255 && empty(i,j,3)==255) && ...
                (empty(i,j,1)==empty(i,j,2) && empty(i,j,1)==empty(i,j,3))
            empty(i,j,1)=0;
            empty(i,j,2)=0;
            empty(i,j,3)=0;
        end
    end
end
image(empty)
imwrite(empty,'napoleonhall_n.png')

%拼图
p1=imread('1.png');
p2=imread('2.png');
p3=imread('3.png');
p4=imread('4.png');
p5=imread('5.png');
pic=[p5;p4;p3;p2;p1];
image(pic)
imwrite(pic,'all.png')

%test
ts=imread('test.png');
R=ts(:,:,1);
G=ts(:,:,2);
B=ts(:,:,3);
R==255 & G==255 & B==255 ;
pos_rgb(ts,255,255,255)

%每个点的距离出口的最短距离
A=walk;
A=A(1:100:size(A,1),:);
for i =1:size(A,1)
    d1=dis2([A(i,1),A(i,2)],gate1,pic,up_stair,down_stair,stair);
    d2=dis2([A(i,1),A(i,2)],gate2,pic,up_stair,down_stair,stair);
    d3=dis2([A(i,1),A(i,2)],gate3,pic,up_stair,down_stair,stair);
    A(i,3)=min([d1,d2,d3]);
end
tri = delaunay(A(:,1),A(:,2));
trisurf(tri,A(:,1),A(:,2),A(:,3));
shading interp
view(0,90);grid on;colorbar
max(A(:,3))
%%%%%%%%%%%%%%%% max(A:,3)大于1452

            


