classdef CAMERA
    % Camera intrinsics and image propagation
    %{
    -----------------------------------------------------------------------
    DESCRIPTION:
        Text
    -----------------------------------------------------------------------
    REFERENCES:
        - Text
    -----------------------------------------------------------------------
    NOTES:
        - Text
    -----------------------------------------------------------------------
    AUTHOR: Kaitlin Dennison
    -----------------------------------------------------------------------
    COPYTRIGHT: 2019 SLAB Group
    -----------------------------------------------------------------------
    TIMESTAMPS:
        - 09-Jun-2019: creation (KD)
        - 14-Jun-2019: style update and added properties (KD)
    -----------------------------------------------------------------------
    %}
    properties
        name = 'Orbiter'
    end
    properties (SetAccess = private)
        f                   % double, focal length (mm)
        pxNum               % 1x2 double, sensor size [wxh] (px)
        pxSze               % 1x2 double, size of a pixel [wxh] (micron)
        A                   % 3x3 double, instrinsic matrix
        radDist = 0         % double, radial distortion
    end
    methods
        function c = CAMERA(f,pxNum,pxSze,name,radDist)
            % Camera constructor
            %{
            ---------------------------------------------------------------
            INPUT:
                f:          double, focal length (mm)
                pxNum:      1x2 double, sensor size [wxh] (px)
                pxSze:      1x2 double, size of a pixel [wxh] (micron)
                name:       str, name of the camera 
                            DEFAULT: 'Orbiter'
                radDist:    double, radial distortion
                            DEFAULT: 0
            ---------------------------------------------------------------
            OUTPUT:
                c:          CAMERA object
            ---------------------------------------------------------------
            %}
            
            c.f = f;
            c.pxNum = pxNum;
            c.pxSze = pxSze;
            k = 1000./pxSze; % (px/mm)
            imSze = pxSze.*pxNum.*0.001; % [wxh] (mm)
            x0 = imSze(1)/2;
            y0 = imSze(2)/2;
            c.A = [f*k(1) 0      k(1)*x0;
                   0      f*k(2) k(2)*y0;
                   0      0      1];
            
            if nargin > 3
                c.name = name;
            end
            
            if nargin > 4
                c.radDist = radDist;
            end
            
        end
    end
end