%%%%%%%%%%%%%%%%%
pic=imread('all.png');
all_s2=zeros(3420,1395); %size(walk,1)=1066998
R=walk;
for i =1:size(R,1)
     if pic(R(i,1),R(i,2),1)==255 && pic(R(i,1),R(i,2),2)==255 && pic(R(i,1),R(i,2),3)==255
        all_s2(R(i,1),R(i,2))=1;
     end
     i;
end
R=0;
[x,y]=meshgrid(1:1395,1:3420);
subplot(1,2,1)
mesh(x,y,all_s2)
title('Corridor distribution')
view(0,90);grid on;
subplot(1,2,2)
mesh(x,y,all_s2)
title('Corridor distribution (overhead view)')
view(0,90);grid on;colorbar