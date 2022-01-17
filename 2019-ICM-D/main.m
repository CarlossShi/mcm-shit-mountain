n=1000; %number of people
tmax=50000;
ak=1/150; %the degree of familiarity with the exit k(s2[0,1452])
bk=2;
lambda=2;
beta=-2;%repulsive force between people and people or between people and obstacles
delta=2;
ks=0.4;
kr=0.1;%排斥力
kd=0.0;%从众
maxad=max(max(all_d));
bottleneck=zeros(3420,1395);

test=imread('all.png');%原图
pic=test;%画红点的图
%man=walk(randperm(size(walk,1),n),:); %随便放n个人
%man_o=man;
man=man_o;
for i =1:size(man,1)
    man(i,3)=0;  %代表没有进行行动决策
    %man(i,4)=man(i,1);  %代表下一格前进的方向
    %man(i,5)=man(i,2);
    man(i,4)=0; %表示踩在不同颜色格子上的状态
    man(i,5)=i;
end
%imh=image(pic)

result=zeros(tmax,10);
for t=1:tmax
    man(man(:,3)~=0,3)=0;  %代表没有进行行动决策
    for i =1:size(man,1) %对每个人循环，一共循环n次
        sig_p=my_sig(man(i,1),man(i,2));
        if sig_p~=0
            man(i,3)=sig_p;       %sign作用于目标决策
            continue
        end
        color=[test(man(i,1),man(i,2),1),test(man(i,1),man(i,2),2),test(man(i,1),man(i,2),3)];
        if color(1,1)==185 && color(1,2)==122 && color(1,3)==87  %棕色
            ele=ele_match([man(i,1),man(i,2)],test,up_stair,down_stair,stair);
            d111=min([dis2([ele(1,1),ele(1,2)],gate1,test,up_stair,down_stair,stair), ...
                      dis2([ele(1,1),ele(1,2)],gate2,test,up_stair,down_stair,stair), ...
                      dis2([ele(1,1),ele(1,2)],gate3,test,up_stair,down_stair,stair), ...
                      dis2([ele(size(ele,1),1),ele(size(ele,1),2)],gate1,test,up_stair,down_stair,stair), ...
                      dis2([ele(size(ele,1),1),ele(size(ele,1),2)],gate2,test,up_stair,down_stair,stair), ...
                      dis2([ele(size(ele,1),1),ele(size(ele,1),2)],gate3,test,up_stair,down_stair,stair)]); %乘电梯上下后距离出口的最短距离
            d112=min([dis2([man(i,1),man(i,2)],gate1,test,up_stair,down_stair,stair), ...
                      dis2([man(i,1),man(i,2)],gate2,test,up_stair,down_stair,stair), ...
                      dis2([man(i,1),man(i,2)],gate3,test,up_stair,down_stair,stair)]);  %位于棕色格子时距离出口的最短距离
        end
        if ~(color(1,1)==255 && color(1,2)==242 && color(1,3)==0)  ... %非黄色
        && ~(color(1,1)==255 && color(1,2)==127 && color(1,3)==39) ... %非橙色
        && ~(color(1,1)==185 && color(1,2)==122 && color(1,3)==87) ....%非棕色
        || color(1,1)==185 && color(1,2)==122 && color(1,3)==87 && d111<=d112
            man(i,4)=0;  %不在电梯口，则mani4为0,或棕色格乘电梯后距离出口更近，则mani4为0
        end
        if color(1,1)==34 && color(1,2)==177 && color(1,3)==76 ... %绿色
        || color(1,1)==255 && color(1,2)==242 && color(1,3)==0 && man(i,4)==0 ...  %黄色
        || color(1,1)==255 && color(1,2)==127 && color(1,3)==39 && man(i,4)==0 ... %橙色
        || color(1,1)==185 && color(1,2)==122 && color(1,3)==87 && man(i,4)==0     %棕色
            man(i,3)=5;
            continue
        end 
        R=around([man(i,1),man(i,2)],0); 
        m_s1=zeros(9,1);
        m_s2=zeros(9,1);
        m_s3=zeros(9,1);
        m_r=zeros(9,1);
        m_p=zeros(9,1);
        m_d=zeros(9,1);   %更新
        direction=zeros(9,1);
        for j =1:size(R,1)   %一共循环9次
            if ~(pic(R(j,1),R(j,2),1)==0 && pic(R(j,1),R(j,2),2)==0 && pic(R(j,1),R(j,2),3)==0) %不计算黑格
%             m_s1(j,1)=ak*(1500-min([dis2([R(j,1),R(j,2)],gate1,pic,up_stair,down_stair,stair) ...
%                             ,dis2([R(j,1),R(j,2)],gate2,pic,up_stair,down_stair,stair)...
%                             ,dis2([R(j,1),R(j,2)],gate3,pic,up_stair,down_stair,stair)]));
              %m_s1(j,1)=ak*(maxad-all_d(R(j,1),R(j,2)));
              m_s3(j,1)=bk*(all_d(man(i,1),man(i,2))-all_d(R(j,1),R(j,2)));
%             if pic(R(j,1),R(j,2),1)==255 && pic(R(j,1),R(j,2),2)==255 && pic(R(j,1),R(j,2),3)==255
%                 m_s2(j,1)=lambda;
%             else
%                 m_s2(j,1)=0;
%             end
              m_s2(j,1)=lambda*all_s2(R(j,1),R(j,2));
            end
            if pic(R(j,1),R(j,2),1)==0 && pic(R(j,1),R(j,2),2)==0 && pic(R(j,1),R(j,2),3)==0 || ...
               pic(R(j,1),R(j,2),1)==237 && pic(R(j,1),R(j,2),2)==28 && pic(R(j,1),R(j,2),3)==36
                m_r(j,1)=beta;
            else
                m_r(j,1)=0;
            end
            if j==5
                continue
            else
                if pic(R(j,1),R(j,2),1)==237 && pic(R(j,1),R(j,2),2)==28 && pic(R(j,1),R(j,2),3)==36
                    XX=man(man(:,2)==R(j,2) & man(:,1)==R(j,1),3);%周围一圈人的方向
                    XX(all(XX == 0, 2),:)=[];
                    if size(XX,1)==0
                        continue
                    else
                        direction(j,1)=XX(randperm(size(XX,1),1),1); %这里有非多个人占有一个格子的问题
                    end
                end
            end
        end
        direction(5,:)=[]; %不考虑自身的决策方向
        table=tabulate(direction);
        [maxCount,idx] = max(table(:,2));
        res=table(idx); %返回出现最多次数的元素
        if res~=0
            m_d(idx,1)=delta;
        end
        N=exp(ks*(m_s1+m_s2+m_s3)+kr*m_r+kd*m_d);
        sum_N=sum(N);
        for j =1:size(R,1)   %一共循环9次
             if pic(R(j,1),R(j,2),1)==0 && pic(R(j,1),R(j,2),2)==0 && pic(R(j,1),R(j,2),3)==0
                 w=0;
             else
                 w=1;
             end
             if pic(R(j,1),R(j,2),1)==237 && pic(R(j,1),R(j,2),2)==28 && pic(R(j,1),R(j,2),3)==36
                 m=1;
             else
                 m=0;
             end
             m_p(j,1)=N(j,1)*w*(1-m)/sum_N;
        end
         c_sum=cumsum(m_p);
         if c_sum==0
             man(i,3)=5; %被挤满了，无路可走
             continue
         end
         rand_p=unifrnd(0,max(c_sum));
         if rand_p>=0 && rand_p <c_sum(1)
             man(i,3)=1;
         elseif rand_p>=c_sum(1) && rand_p<c_sum(2)
             man(i,3)=2;
         elseif rand_p>=c_sum(2) && rand_p<c_sum(3)
             man(i,3)=3;
         elseif rand_p>=c_sum(3) && rand_p<c_sum(4)
             man(i,3)=4;
         elseif rand_p>=c_sum(4) && rand_p<c_sum(5)
             man(i,3)=5;
         elseif rand_p>=c_sum(5) && rand_p<c_sum(6)
             man(i,3)=6;
         elseif rand_p>=c_sum(6) && rand_p<c_sum(7)
             man(i,3)=7;
         elseif rand_p>=c_sum(7) && rand_p<c_sum(8)
             man(i,3)=8;
         elseif rand_p>=c_sum(8) && rand_p<c_sum(9)
             man(i,3)=9;
         else
             fprintf('108 error')
         end
    end %man第3列更新完毕
    occupy=zeros(3420,1395);
    for i =1:size(man,1) %开始更新man第1、2列
        color=[test(man(i,1),man(i,2),1),test(man(i,1),man(i,2),2),test(man(i,1),man(i,2),3)];
        if color(1,1)==34 && color(1,2)==177 && color(1,3)==76 %绿色
            man(i,4)=1; %1表示到了出口，即将被删除
            if man(i,1)<1800
                result(t,8)=result(t,8)+1;   %从gate1出去
            elseif man(i,1)>1800 && man(i,1)<2500
                result(t,9)=result(t,9)+1;   %从gate2出去
            else
                result(t,10)=result(t,10)+1; %从gate3出去
            end
            continue
        end  
        if color(1,1)==255 && color(1,2)==242 && color(1,3)==0 && man(i,4)==0 %黄色，且为自由移动状态
            ele=ele_match([man(i,1),man(i,2)],test,up_stair,down_stair,stair);
            nele=randperm(size(ele,1),1);
            tar=ele(nele,:);
            if occupy(tar(1,1),tar(1,2))==0    %这个位置没有人
                 man(i,1)=tar(1,1);
                 man(i,2)=tar(1,2);
                 occupy(tar(1,1),tar(1,2))=1; 
                 man(i,4)=2;  %保护状态，离开电梯后踩到非电梯格状态恢复，防止重复使用电梯
            else
                man(i,3)=5; %等待
            end
            continue
        end
        
        if color(1,1)==255 && color(1,2)==127 && color(1,3)==39 && man(i,4)==0 %橙色，且为自由移动状态
            ele=ele_match([man(i,1),man(i,2)],test,up_stair,down_stair,stair);
            nele=randperm(size(ele,1),1);
            tar=ele(nele,:);
            if occupy(tar(1,1),tar(1,2))==0    %这个位置没有人
                 man(i,1)=tar(1,1);
                 man(i,2)=tar(1,2);
                 occupy(tar(1,1),tar(1,2))=1; 
                 man(i,4)=2;  %保护状态，离开电梯后踩到非电梯格状态恢复，防止重复使用电梯
            else
                man(i,3)=5; %等待
            end
            continue
        end
        
        if color(1,1)==185 && color(1,2)==122 && color(1,3)==87 && man(i,4)==0 %棕色，且为自由移动状态
            ele=ele_match([man(i,1),man(i,2)],test,up_stair,down_stair,stair);
            d11=min([dis2([ele(1,1),ele(1,2)],gate1,test,up_stair,down_stair,stair), ...
                     dis2([ele(1,1),ele(1,2)],gate2,test,up_stair,down_stair,stair), ...
                     dis2([ele(1,1),ele(1,2)],gate3,test,up_stair,down_stair,stair)]);
            d12=min([dis2([ele(size(ele,1),1),ele(size(ele,1),2)],gate1,test,up_stair,down_stair,stair), ...
                     dis2([ele(size(ele,1),1),ele(size(ele,1),2)],gate2,test,up_stair,down_stair,stair), ...
                     dis2([ele(size(ele,1),1),ele(size(ele,1),2)],gate3,test,up_stair,down_stair,stair)]);
            if d11<d12
                ele=ball_search([ele(1,1),ele(1,2)],test);
            else
                ele=ball_search([ele(size(ele,1),1),ele(size(ele,1),2)],test);
            end
            nele=randperm(size(ele,1),1);
            tar=ele(nele,:);
            if occupy(tar(1,1),tar(1,2))==0    %这个位置没有人
                 man(i,1)=tar(1,1);
                 man(i,2)=tar(1,2);
                 occupy(tar(1,1),tar(1,2))=1; 
                 man(i,4)=2;  %保护状态，离开电梯后踩到非电梯格状态恢复，防止重复使用电梯
            else
                man(i,3)=5; %等待
            end
            continue
        end
            

        tar=around([man(i,1),man(i,2)],man(i,3));
        if occupy(tar(1,1),tar(1,2))==0    %这个位置没有人
             man(i,1)=tar(1,1);
             man(i,2)=tar(1,2);
             occupy(tar(1,1),tar(1,2))=1;  
        else                               %这个位置有人
            if rand(1)>0.5  %一定概率前进，使得原来占有此格子的人停止
                man_t=find(man(:,2)==tar(1,2) & man(:,1)==tar(1,1));%找到让第几个人停
                if man(man_t,3)~=5 %被挤的人动过
                    tar_t=around([tar(1,1),tar(1,2)],-1*man(man_t,3));%往回退一格
                    man(man_t,1)=tar_t(1,1);
                    man(man_t,2)=tar_t(1,2);
                    man(man_t,3)=5; %表示等待状态
                    man(i,1)=tar(1,1);
                    man(i,2)=tar(1,2); 
                else
                    man(i,3)=5; %乘电梯的人没法倒退，所以两者都等待
                end
            else  %一定概率停止前进，不对man的位置状态更新
                man(i,3)=5;
            end
        end
    end
    bottleneck=bottleneck+occupy;
    man(man(:,4)==1,:)=[] ;%删除在出口的人
    result(t,6)=t;
    result(t,7)=size(man,1);
    [t,size(man,1)]
    pic=test;%test是原图，在原图上画红点%开始改变颜色
    for i=1:size(man,1)
        f=6-ceil(man(i,1)/684);
        result(t,f)=result(t,f)+1;
        pic(man(i,1),man(i,2),1)=237;
        pic(man(i,1),man(i,2),2)=28;
        pic(man(i,1),man(i,2),3)=36;
    end
     %set(imh,'cdata',pic);
     %drawnow;
     if result(t,7)<=n/2
         break
     end
end
result(all(result == 0, 2),:)=[];
%image(pic);
%imwrite(pic,'test_main.png')
%plot(result1(:,1),result1(:,2))
