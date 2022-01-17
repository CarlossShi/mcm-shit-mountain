pic=imread('all.png');
image(pic)
gate=pos_rgb(pic,34,177,76); %green
gate1=gate(1:12,:);
gate2=gate(13:22,:);
gate3=gate(23:40,:);
up_stair=pos_rgb(pic,255,127,39); %orange
down_stair=pos_rgb(pic,255,242,0); %yellow
stair=pos_rgb(pic,185,122,87); %brown
image(pic_n(pic,5)) %top floor
%统计可以站立的点
walk=zeros(size(pic,1)*size(pic,2),2);n=1;
for i =1: size(pic,1)
    for j =1:size(pic,2)
        if ~(pic(i,j,1)==0 && pic(i,j,2)==0 && pic(i,j,3)==0)...
               && ~(pic(i,j,1)==195 && pic(i,j,2)==195 && pic(i,j,3)==195)
            walk(n,1)=i;walk(n,2)=j;
            n=n+1;
        end
    end
end     
walk(all(walk == 0, 2),:)=[]; %删除全0行