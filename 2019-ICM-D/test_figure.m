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
imwrite(empty,test.png')

%拼图
p1=imread('1.png');
p2=imread('2.png');
p3=imread('3.png');
p4=imread('4.png');
p5=imread('5.png');
pic=[p5;p4;p3;p2;p1];
image(pic)
imwrite(pic,'all.png')
%拼图2
p1=imread('1.png');
p2=imread('2.png');
p3=imread('3.png');
p4=imread('4.png');
p5=imread('5.png');
pic=[p5,p4;p2,p3];
image(pic)
imwrite(pic,'all2.png')

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

result(all(result == 0, 2),:)=[];

n=1000;
subplot(2,2,1)
 plot(result(:,6),result(:,5)/n,'-','Color',[0.5,0,0])
 hold on
 plot(result(:,6),result(:,4)/n,'-y')
 hold on
 plot(result(:,6),result(:,3)/n,'-','Color',[1,0.5,0])
 hold on
 plot(result(:,6),result(:,2)/n,'-m')
 hold on
plot(result(:,6),result(:,1)/n,'-r')
 hold off
 title('Percentage of people on each 5 floors')
 xlim([0,max(result(:,6))])
 legend('2F','1F','GF','LGF','NH','Location','Northeast')
 subplot(2,2,2)
 plot(result(:,6),cumsum(result(:,8))/n,'-g', ...
     result(:,6),cumsum(result(:,9))/n,'-c', ...
     result(:,6),cumsum(result(:,10))/n,'-b')
 title('Percentage of people exit from 4 gates')
  xlim([0,max(result(:,6))])
   legend('Richelieu','Lions','Pyramid & Carrousel','Location','Northwest')
subplot(2,1,2)
[x,y]=meshgrid(1:1395,1:3420);
mesh(x,y,bottleneck)
title('Occupied time of each grid')
grid on;


%寻找bottleneck
[Y,I]=sort(bottleneck(:),'descend');
Y(1:10) %872 864 773 758 755 742 741 734 700 696
[row,col]=find(bottleneck==864);

%半逃生时间
max(result(:,6))

%
A=[ 1468 ,1479 ,1494 ,1460;
    1189,1195,1182,1214;
    1065,1061,1077,1064;
    1006,1006,988,1011];
[x,y]=meshgrid(-0.4:-0.2:-1,0:0.2:0.6);
mesh(x,y,A)
xlabel=('kd');
ylabel=('ka');
grid on;


