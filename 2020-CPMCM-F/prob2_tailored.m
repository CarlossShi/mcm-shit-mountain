max_time = 7200;
data = [0.3,1.5,2.1,1.9,2.6,0.8;...  % 当前油量
       0,0,0,0,0,0;...  % 供油速度
       0,0,0,0,0,0];  % 开启时间
plane_centroid = [0,0,0];
for i = 1:6
    C_absolute = [x_c(i), y_c(i), z_c(i) + ...
        data(1,i)*(data(1,i)-x(i)*y(i)*z(i))/2/x(i)/y(i)];
    plane_centroid = plane_centroid + data(1,i) * C_absolute;
end
plane_centroid = plane_centroid ./ (sum(data(1,:)) + 3000/850);
dis = sqrt(sum((prob2_centroid(1,:) - plane_centroid).^2));
best_so_far = [inf, -1];


t = tree({data, dis, 0});  % {data, dis, time}

active = [1,dis, 0];  % active set [node_num, dis, time]

while ~isempty(active)
    % 先考虑剪枝
    tar_idx = find(active(:,2)>best_so_far(1));  % 待剪枝的node
    
    for i = length(tar_idx):-1:1  % debug!一定要倒着删除
        active(tar_idx(i),:) = []; % 从active set中删除
        %t = t.chop(tar_idx(i))  % 从树中删除
    end
    % 深度优先选择
    [M,I] = max(active(:,3));
    node = active(I,1);  % 选择最深的node
    active(I,:) = [];  % 从active set中删除
    
    % 看看现在又多少个active node待扩展
    % 由选择的node扩展出来的node就从row+1开始添加
    [row,col] = size(active);  % row代表active set中现存的元素
    
    cell = t.get(node);
    data = cell{1};  % 查看带扩展node的信息
    dis = cell{2};
    time = cell{3};  % 信息应是完整的
    
    
    wkg_ft = find([0,data(2,2:5),0]>0);  % 向发动机供油的油箱索引 fuel tank
    trs_ft = find([data(2,1),0,0,0,0,data(2,6)]>0);  % 向其他油箱输油的油箱索引 fuel tank
    % debug! 这里不对矩阵进行扩充，则索引会偏移
        
    wkg_num = length(wkg_ft);  % 向发动机供油的油箱数 [0,1,2]
    trs_num = length(trs_ft);  % 向其他油箱输油的油箱数  [0,1,2]
    
    % 此时刻所有可能的油箱组合，这里列出的所有
    if wkg_num == 0 && trs_num == 0
        cur_ft_list = {[2,3,1],[2,4,1],[2,5,1],[2,3,6],[2,4,6],[2,5,6],...
                  [3,4,1],[3,5,1],[3,4,6],[3,5,6],...
                  [4,5,1],[4,5,6],...  % [2,1] 12种
                  [2,1,6],[3,1,6],[4,1,6],[5,1,6]};  % [1,2] 4种
    elseif wkg_num == 0 && trs_num == 1
        t1 = trs_ft(1);  % 仍然开着的唯一一个油箱
        add_ft = setdiff([1,6],t1); 
        cur_ft_list = {[2,3,t1],[2,4,t1],[2,5,t1],[3,4,t1],[3,5,t1],[4,5,t1],... % [2,0] 6种
                  [2,1,6],[3,1,6],[4,1,6],[5,1,6]};
        if data(3,t1) >= 60  % 此开启的油箱可以关闭
            cur_ft_list = [cur_ft_list,...
                  [2,3,add_ft],[2,4,add_ft],[2,5,add_ft],...
                  [3,4,add_ft],[3,5,add_ft],[4,5,add_ft]];  % [2,1]
        end      
    elseif wkg_num == 1 && trs_num == 0
        w1 = wkg_ft(1);  % 仍然开着的唯一一个油箱
        add_ft = setdiff([2,3,4,5],w1);
        cur_ft_list = {[add_ft(1),w1,1],[add_ft(1),w1,6],...
                  [add_ft(2),w1,1],[add_ft(2),w1,6],...
                  [add_ft(3),w1,1],[add_ft(3),w1,6],...  % [1,1] 6种
                  [w1,1,6]};
        if data(3,w1) >= 60
            cur_ft_list = [cur_ft_list,...
                  [add_ft(1),add_ft(2),1],[add_ft(1),add_ft(3),1],[add_ft(2),add_ft(3),1],...
                  [add_ft(1),add_ft(2),6],[add_ft(1),add_ft(3),6],[add_ft(2),add_ft(3),6]];% [2,0]
        end
    elseif wkg_num == 1 && trs_num == 1
        t1 = trs_ft(1); w1 = wkg_ft(1);
        add_ft = setdiff([2,3,4,5],w1);
        add_ft2 = setdiff([1,6],t1);
        cur_ft_list = {[t1,w1,add_ft(1)],[t1,w1,add_ft(2)],[t1,w1,add_ft(3)],...%  [1,0]
                  [w1,1,6]};
        if data(3,t1) >= 60  && data(3,w1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [add_ft(1),add_ft(2),add_ft2],...
                     [add_ft(1),add_ft(3),add_ft2],...
                     [add_ft(2),add_ft(3),add_ft2]];  % [0,1]
        elseif data(3,w1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [add_ft(1),add_ft(2),t1],...
                     [add_ft(1),add_ft(3),t1],...
                     [add_ft(2),add_ft(3),t1],... % [2,0]
                     [add_ft(1),1,6],[add_ft(2),1,6],[add_ft(3),1,6]];
        elseif data(3,t1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [w1,add_ft(1),add_ft2],...
                     [w1,add_ft(2),add_ft2],...
                     [w1,add_ft(3),add_ft2]];
        end
    elseif wkg_num == 2 && trs_num == 0
        w1 = wkg_ft(1); w2 = wkg_ft(2);
        add_ft = setdiff([2,3,4,5],wkg_ft);
        cur_ft_list = {[w1,w2,1],[w1,w2,6],[w1,w2]};
        if data(3,w1) >= 60  && data(3,w2) >= 60
            cur_ft_list = [cur_ft_list,...
                     [add_ft,1], [add_ft,6],...   % [2,1]
                     [add_ft(1),1,6],[add_ft(2),1,6]];
        elseif data(3,w1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [w2,add_ft(1),1],[w2,add_ft(1),6],...
                     [w2,add_ft(2),1],[w2,add_ft(2),6],...  % [1,1]
                     [w2,1,6]];
        elseif data(3,w2) >= 60
            cur_ft_list = [cur_ft_list,...
                     [w1,add_ft(1),1],[w1,add_ft(1),6],...
                     [w1,add_ft(2),1],[w1,add_ft(2),6],...  % [1,1] 
                     [w1,1,6]];
        end
    elseif wkg_num == 0 && trs_num == 2
        t1 = trs_ft(1); t2 = trs_ft(2);
        cur_ft_list = {[2,1,6],[3,1,6],[4,1,6],[5,1,6],[1,6]};
        if data(3,t1) >= 60  && data(3,t2) >= 60
            cur_ft_list = [cur_ft_list,...
                     [2,3],[2,4],[2,5],[3,4],[3,5],[4,5]];  % [1,0]
        elseif data(3,t1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [t2,2,3],[t2,2,4],[t2,2,5],...
                     [t2,3,4],[t2,3,5],[t2,4,5]];
        elseif data(3,t1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [t1,2,3],[t1,2,4],[t1,2,5],...
                     [t1,3,4],[t1,3,5],[t1,4,5]];
        end
    elseif  wkg_num == 2 && trs_num == 1
        w1 = wkg_ft(1); w2 = wkg_ft(2);t1 = trs_ft(1);
        add_ft = setdiff([2,3,4,5],[w1,w2]);
        add_ft2 = setdiff([1,6],t1);
        cur_ft_list = {[wkg_ft,trs_ft]};
        if data(3,w1) >= 60  && data(3,w2) >= 60 && data(3,t1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [add_ft, add_ft2]];
        elseif data(3,w1) >= 60  && data(3,w2) >= 60
            cur_ft_list = [cur_ft_list,...
                     [add_ft,1,6]];
        elseif data(3,w1) >= 60  && data(3,t1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [w2,add_ft(1),add_ft2],...
                     [w2,add_ft(2),add_ft2]];
        elseif data(3,w2) >= 60  && data(3,t1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [w1,add_ft(1),add_ft2],...
                     [w1,add_ft(2),add_ft2]];
        elseif data(3,w1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [w2,t1,add_ft(1)],[w2,t1,add_ft(2)],...  % [1,0]
                     [w2,1,6]];
        elseif data(3,w2) >= 60
            cur_ft_list = [cur_ft_list,...
                     [w1,t1,add_ft(1)],[w1,t1,add_ft(2)],...  % [1,0]
                     [w1,1,6]];
        elseif data(3,t1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [w1,w2,add_ft2]];
        end
    elseif  wkg_num == 1 && trs_num == 2
        w1 = wkg_ft(1); t1 = trs_ft(1); t2 = trs_ft(2);
        add_ft = setdiff([2,3,4,5],w1);
        cur_ft_list = {[wkg_ft,trs_ft]};
        if data(3,w1) >= 60  && data(3,t1) >= 60 && data(3,t2) >= 60
            cur_ft_list = [cur_ft_list,...
                     [add_ft(1),add_ft(2)],...
                     [add_ft(1),add_ft(3)],...
                     [add_ft(2),add_ft(3)]];
        elseif data(3,w1) >= 60  && data(3,t1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [t2,add_ft(1),add_ft(2)],...
                     [t2,add_ft(1),add_ft(3)],...
                     [t2,add_ft(2),add_ft(3)]];
        elseif data(3,w1) >= 60  && data(3,t2) >= 60
            cur_ft_list = [cur_ft_list,...
                     [t1,add_ft(1),add_ft(2)],...
                     [t1,add_ft(1),add_ft(3)],...
                     [t1,add_ft(2),add_ft(3)]];
        elseif data(3,t1) >= 60  && data(3,t2) >= 60
            cur_ft_list = [cur_ft_list,...
                     [w1,add_ft(1)],...
                     [w1,add_ft(2)],...
                     [w1,add_ft(3)]];
        elseif data(3,w1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [t1,t2,add_ft(1)],...
                     [t1,t2,add_ft(2)],...
                     [t1,t2,add_ft(3)]];
        elseif data(3,t1) >= 60
            cur_ft_list = [cur_ft_list,...
                     [w1,t2,add_ft(1)]...
                     [w1,t2,add_ft(2)]...
                     [w1,t2,add_ft(3)]];
        elseif data(3,t2) >= 60
            cur_ft_list = [cur_ft_list,...
                     [w1,t1,add_ft(1)]...
                     [w1,t1,add_ft(2)]...
                     [w1,t1,add_ft(3)]];
        end
    end
    % 此时刻所有可能的油箱组合储存再cur_ft_list中
    % 下面要遍历其中的所有元素，每个都要创建node
    time = time +1;
    temp = 1;
    %celldisp(cur_ft_list)
    
    %{
    list_num = length(cur_ft_list);
    rand_index = randperm(list_num);  % 将序号随机排列
    draw_rand_index = rand_index(1:min(list_num,4));  % 取出若干个序号
    cur_ft_list = cur_ft_list(draw_rand_index);  % 取出这m个序号对应的元素
    %}
    
    for  cur_ft = cur_ft_list
        % 首先要求解供油速度
        fun=@(t)sum((([x_c(1),y_c(1),z_c(1)+...
                (data(1,1)-t(1)-xyz(1))/2/x(1)/y(1)]*(data(1,1)-t(1))+...
                [x_c(2),y_c(2),z_c(2)+...
                (min(data(1,2)+t(1)-t(2),xyz(2))-xyz(2))/2/x(2)/y(2)]*min(data(1,2)+t(1)-t(2),xyz(2))+...
                [x_c(3),y_c(3),z_c(3)+...
                (data(1,3)-t(3)-xyz(3))/2/x(3)/y(3)]*(data(1,3)-t(3))+...
                [x_c(4),y_c(4),z_c(4)+...
                (data(1,4)-t(4)-xyz(4))/2/x(4)/y(4)]*(data(1,4)-t(4))+...
                [x_c(5),y_c(5),z_c(5)+...
                (min(data(1,5)+t(6)-t(5),xyz(5))-xyz(5))/2/x(5)/y(5)]*min(data(1,5)+t(6)-t(5),xyz(5))+...
                [x_c(6),y_c(6),z_c(6)+...
                (data(1,6)-t(6)-xyz(6))/2/x(6)/y(6)]*(data(1,6)-t(6)))...
                /(sum(data(1,:))-t(2)-t(3)-t(4)-t(5)+3000/850)...
                -prob2_centroid(time,:)).^2);  %离欧式距离差一个开方
        
        A=[0,-1,-1,-1,-1,0;
           -1,1,0,0,0,0;
           0,0,0,0,1,-1];
        b=[-prob2_spd(time);
           data(1,2);
           data(1,5)];
        Aeq = [];
        beq = [];
        nonlcon = [];
        
        lb = [0,0,0,0,0,0];
        ub = [0,0,0,0,0,0];
        x0 = [0,0,0,0,0,0];
        

        for n = cur_ft{1}  % 遍历每个开启的油箱
            if any([1,3,4,6]==n)  % 这四个油箱用量不能超过上1s的油量
                ub(n) = min(oil_ub(n),data(1,n));
            else
                ub(n) = oil_ub(n);
            end
        end
        
        options = optimset('Display','off');
        
        [tt,fval] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
        [best_so_far, 100/(row+1),time, fval, tt]
        
        opn_tm = data(3,:);  % node的已开启时间
        for i=[trs_ft,wkg_ft]  % [2,3,6]
            if tt(i)==0  % i是上1s开启了的，若这1s它为0，说明它关了
                opn_tm(i) = 0;  % 老的归零
            end
        end
        for i=1:6
            if tt(i) > 0  % 这1s开着的油箱计时加一
                opn_tm(i) = opn_tm(i) + 1;
            end
        end
        data_new = [data(1,1)-tt(1),data(1,2)-tt(2)+tt(1),...
                data(1,3)-tt(3),data(1,4)-tt(4),...
                data(1,5)-tt(5)+tt(6),data(1,6)-tt(6);...  % 当前油量
                tt;...  % 供油速度
                opn_tm];  % 已开启时间
        % debug!因为这里有多层循环，data命名一定要改为data new
        dis = max(dis,sqrt(fval));  % 更新lowerbound为迄今为止dis的最大值！

        if any(data_new(1,:)<0)  % 判断data new的可行性
            continue
        end
        if time == 7200  % 此扩展node为leaf
            if dis < best_so_far(1)  % 若更优则更新
                best_so_far(1) = dis;
                [t, best_so_far(2)] = t.addnode(node,{data_new, dis, time});
            end
        else  % 若没有到底部
            if dis <= best_so_far(1)  % 人为规定一个剪枝阈值
                % 扩展node
                [t, active(row+temp,1)] = t.addnode(node,{data_new, dis, time});
                active(row+temp,2) = dis;
                active(row+temp,3) = time;
                temp = temp + 1;  % temp最终应等于从node扩展出去的新node个数
            end
        end     
    end
end

prob2_result1 = zeros(max_time,6);
prob2_result2 = zeros(max_time,6);
prob2_result3 = zeros(max_time,6);

target_node = best_so_far(2);
for i =max_time:-1:1
    target_cell = t.get(target_node);
    target_data = target_cell{1};
    prob2_result1(i,:) = target_data(1,:);
    prob2_result2(i,:) = target_data(2,:);
    prob2_result3(i,:) = target_data(3,:);
    target_node = t.getparent(target_node);
end
best_so_far
    


% disp(t.tostring)
