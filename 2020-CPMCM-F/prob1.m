% plot(alphaShape(P(:,1),P(:,2),P(:,3))  
% 画多面体
max_t = 1;
oil_status = zeros(max_t, 6);  % m^3
prob1_result = zeros(max_t, 3);
eject = zeros(max_t,1);  % [t, eject_v]

oil_status(1,:) = init_v;
oil_status(1,2) = oil_status(1,2) + prob1_oil(1,1);  % 油箱1给2输油
oil_status(1,6) = oil_status(1,6) + prob1_oil(1,5);  % 油箱6给5输油
oil_status(1,:)
plane_centroid = [0,0,0];
for n = 1:6
    % [C,P] = oil_centroid(theta,thld_theta,v,x,y,z)
    [C,P,E] = oil_centroid(prob1_theta(1),thld_theta(n),oil_status(1,n),x(n),y(n),z(n)); 
    if E
        eject(t) = E;
    end
    plane_centroid = plane_centroid + oil_status(1,n) * (C + [x_c(n), y_c(n), z_c(n)]);
end
prob1_result(1,:) = plane_centroid ./ (sum(oil_status(1,:)) + 3000/850);
for t = 2:max_t
    t
    oil_status(t,:) = oil_status(t-1,:) - prob1_oil(t,:);
    oil_status(t,2) = oil_status(t,2) + prob1_oil(t,1);  % 油箱1给2输油
    oil_status(t,6) = oil_status(t,6) + prob1_oil(t,5);  % 油箱6给5输油
    plane_centroid = [0,0,0];
    for n = 1:6
        % [n,prob1_theta(t),thld_theta(n),oil_status(t,n),x(n),y(n),z(n)]
        [C,P,E] = oil_centroid(prob1_theta(t),thld_theta(n),oil_status(t,n),x(n),y(n),z(n)); 
        if E
            eject(t) = E;
        end
        plane_centroid = plane_centroid + oil_status(t,n) * (C + [x_c(n), y_c(n), z_c(n)]);
    end
    prob1_result(t,:) = plane_centroid ./ sum(oil_status(t,:) + 3000/850);
end
%plot3(1:7200, prob1_result(:,1), prob1_result(:,3),'MarkerSize',10,'LineWidth',3)
oil_status;
init_v;