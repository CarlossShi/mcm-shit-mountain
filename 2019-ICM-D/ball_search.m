function [R]=ball_search(A,pic) %ͬɫ��������
c=[pic(A(1,1),A(1,2),1),pic(A(1,1),A(1,2),2),pic(A(1,1),A(1,2),3)];
R=A;
while true
    n=0;
    for i=1:size(R)
        if pic(R(i,1)-1,R(i,2),1)==c(1) && ...
           pic(R(i,1)-1,R(i,2),2)==c(2) && ...
           pic(R(i,1)-1,R(i,2),3)==c(3) && ...
          ~ismember(R(i,2),R(R(:,1)==R(i,1)-1,2))
            R=[R;R(i,1)-1,R(i,2)];
            n=n+1;
        end
        if pic(R(i,1)+1,R(i,2),1)==c(1) && ...
           pic(R(i,1)+1,R(i,2),2)==c(2) && ...
           pic(R(i,1)+1,R(i,2),3)==c(3) && ...
          ~ismember(R(i,2),R(R(:,1)==R(i,1)+1,2))
            R=[R;R(i,1)+1,R(i,2)];
            n=n+1;
        end
        if pic(R(i,1),R(i,2)-1,1)==c(1) && ...
           pic(R(i,1),R(i,2)-1,2)==c(2) && ...
           pic(R(i,1),R(i,2)-1,3)==c(3) && ...
          ~ismember(R(i,2)-1,R(R(:,1)==R(i,1),2))
            R=[R;R(i,1),R(i,2)-1];
            n=n+1;
        end
        if pic(R(i,1),R(i,2)+1,1)==c(1) && ...
           pic(R(i,1),R(i,2)+1,2)==c(2) && ...
           pic(R(i,1),R(i,2)+1,3)==c(3) && ...
          ~ismember(R(i,2)+1,R(R(:,1)==R(i,1),2))
            R=[R;R(i,1),R(i,2)+1];
            n=n+1;
        end
    end
    if n==0
        break
    end
end