classdef EXCLASS
    % Short, one-line description
    %{
    -----------------------------------------------------------------------
    DESCRIPTION:
        This is an example description. Lorem ipsum dolor sit amet, 
        consectetur adipiscing elit, sed do eiusmod tempor incididunt ut 
        labore et dolore magna aliqua. Ut enim ad minim veniam, quis 
        nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
        consequat. Duis aute irure dolor in reprehenderit in voluptate 
        velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint
        occaecat cupidatat non proident, sunt in culpa qui officia deserunt
        mollit anim id est laborum.
    -----------------------------------------------------------------------
    REFERENCES:
        - IEEE format citations should go here
    -----------------------------------------------------------------------
    NOTES:
        - Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do 
          eiusmod tempor incididunt ut labore et dolore magna aliqua.
        - Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do 
          eiusmod tempor incididunt ut labore et dolore magna aliqua.
    -----------------------------------------------------------------------
    AUTHOR: First Lastname
    -----------------------------------------------------------------------
    COPYTRIGHT: 2019 SLAB Group
    -----------------------------------------------------------------------
    TIMESTAMPS:
        - DD-MMM-YYYY: short description of change (initials)
    -----------------------------------------------------------------------
    %}
    
    properties (SetAccess = private)
        %% Category1
        prpStr      % str, string or character type input description
        prpVar      % double, description of 1x1 variable (unit)
        prpArr      % nx1 double, description of an array. Arrays shoulbe be
                    % nx1, not 1xn whenever possible because MATLAB accesses
                    % memory column-wise fastest
                        % [var1 var2 var3]'
                        % (unit unit unit)
        %% Category2
        prpMat      % nxm cell, description of matrix
                        % {var1 var2 var3;
                        %  var4 var5 var6}
                        % (unit unit unit;
                        %  unit unit unit)
                        
    end
    
    methods
        function c = EXCLASS(prpStr,prpVar,prpArr,prpMat)
            % EXCLASS object constructor
            %{
            ---------------------------------------------------------------
            INPUT: c = EXCLASS(prpStr,prpVar,prpArr,prpMat)
                prpStr:     str, string or character type input description
                prpVar:     double, description of 1x1 variable (unit)
                prpArr:     nx1 double, description of an array. 
                                [var1 var2 var3]'
                                (unit unit unit)
                prpMat:     nxm cell, description of matrix
                                {var1 var2 var3;
                                var4 var5 var6}
                                (unit unit unit;
                                unit unit unit)
            ---------------------------------------------------------------
            OUTPUT:
                c:          EXCLASS object
            ---------------------------------------------------------------
            %}
            
            c.prpStr = prpStr;
            c.prpVar = prpVar;
            c.prpArr = prpArr;
            c.prpMat = prpMat;
        end
        
        function out = exMeth(c,in)
            % Example method for EXCLASS
            %{
            ---------------------------------------------------------------
            INPUT: out = c.exMeth(in)
                c:          EXCLASS object
                in:         type, description
            ---------------------------------------------------------------
            OUTPUT:
                out:        type, description
            ---------------------------------------------------------------
            %}
            
            out = c.prpStr * in;
            
        end
    end
        
end