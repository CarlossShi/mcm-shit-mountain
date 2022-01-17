                         function [C,P,E] = oil_centroid(theta,thld_theta,v,x,y,z)
% theta, thld_theta: rad
if v > x*y*z
    % fprintf(' overflow! \n')
    P = -1;
    C = [0, 0, 0];
    E = v-x*y*z;
    return
else
    E = 0;
end
sig = sign(theta);
if theta == 0
    % fprintf(' sig == 0 \n')
    P = -1;
    C = [0, 0, v/x/y/2 - z/2];
    return
elseif abs(theta) < thld_theta
    % fprintf(' abs(theta) < thld_theta \n')
    v_prism = 0.5*x*x*y*tan(theta);
    if v <= v_prism
        % fprintf(' v <= v_prism \n')
        P = [-x/2*sig, y/2, -z/2;
            -x/2*sig, -y/2, -z/2;
            sig*(sqrt(2*v/y/tan(theta))-x/2), y/2, -z/2;
            sig*(sqrt(2*v/y/tan(theta))-x/2), -y/2, -z/2;
            -x/2*sig, y/2, sqrt(2*v*tan(theta)/y)-z/2;
            -x/2*sig, -y/2, sqrt(2*v*tan(theta)/y)-z/2];
        C = centroid(P);
        return
    elseif v <= x*y*z - v_prism
        % fprintf(' v_prism < v <= x*y*z - v_prism \n')
        P = [-x/2*sig, y/2, -z/2;
            -x/2*sig, -y/2, -z/2;
            x/2*sig, y/2, -z/2;
            x/2*sig, -y/2, -z/2;
            x/2*sig, y/2, v/x/y-x*tan(theta)/2-z/2;
            x/2*sig, -y/2, v/x/y-x*tan(theta)/2-z/2;
            -x/2*sig, y/2, v/x/y+x*tan(theta)/2-z/2;
            -x/2*sig, -y/2, v/x/y+x*tan(theta)/2-z/2];
        C = centroid(P);
    else
        % fprintf(' v > x*y*z - v_prism \n')
        P = [-x/2*sig, y/2, -z/2;
            -x/2*sig, -y/2, -z/2;
            x/2*sig, y/2, -z/2;
            x/2*sig, -y/2, -z/2;
            -x/2*sig, y/2, z/2;
            -x/2*sig, -y/2, z/2;
            sig*(x/2-sqrt((2*x*y*z-2*v)/y/tan(theta))), y/2, z/2;
            sig*(x/2-sqrt((2*x*y*z-2*v)/y/tan(theta))), -y/2, z/2
            x/2*sig, y/2, z/2-sqrt((2*x*y*z-2*v)*tan(theta)/y);
            x/2*sig, -y/2, z/2-sqrt((2*x*y*z-2*v)*tan(theta)/y)];
        C = centroid(P);
        return
    end
else
    % fprintf(' abs(theta) > thld_theta \n')
    v_prism = 0.5*z*z*y/tan(theta);
    if v <= v_prism
        % fprintf(' v <= v_prism \n')
        P = [-x/2*sig, y/2, -z/2;
            -x/2*sig, -y/2, -z/2;
            sig*(sqrt(2*v/y/tan(theta))-x/2), y/2, -z/2;
            sig*(sqrt(2*v/y/tan(theta))-x/2), -y/2, -z/2;
            -x/2*sig, y/2, sqrt(2*v*tan(theta)/y)-z/2;
            -x/2*sig, -y/2, sqrt(2*v*tan(theta)/y)-z/2];
        C = centroid(P);
        return
    elseif v <= x*y*z - v_prism
        % fprintf(' v_prism < v <= x*y*z - v_prism \n')
        P = [-x/2*sig, y/2, z/2;
            -x/2*sig, -y/2, z/2;
            -x/2*sig, y/2, -z/2;
            -x/2*sig, -y/2, -z/2;
            sig*(v/y/z-z/2/tan(theta)-x/2),y/2,z/2;
            sig*(v/y/z-z/2/tan(theta)-x/2),-y/2,z/2;
            sig*(v/y/z+z/2/tan(theta)-x/2),y/2,-z/2;
            sig*(v/y/z+z/2/tan(theta)-x/2),-y/2,-z/2];
        C = centroid(P);
        return
    else
        % fprintf(' v > x*y*z - v_prism \n')
        P = [-x/2*sig, y/2, -z/2;
            -x/2*sig, -y/2, -z/2;
            x/2*sig, y/2, -z/2;
            x/2*sig, -y/2, -z/2;
            -x/2*sig, y/2, z/2;
            -x/2*sig, -y/2, z/2;
            sig*(x/2-sqrt((2*x*y*z-2*v)/y/tan(theta))), y/2, z/2;
            sig*(x/2-sqrt((2*x*y*z-2*v)/y/tan(theta))), -y/2, z/2
            x/2*sig, y/2, z/2-sqrt((2*x*y*z-2*v)*tan(theta)/y);
            x/2*sig, -y/2, z/2-sqrt((2*x*y*z-2*v)*tan(theta)/y)];
        C = centroid(P);
        return
    end
end