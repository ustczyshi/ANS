function [out1, out2] = exFun(inStr,inVar,inArr,inMat)
    % Short description (fit in one line)
    %{
    -----------------------------------------------------------------------
    DESCRIPTION:
        Longer description here in paragraph form. All text should fit
        within the standard MATLAB width unless the line includes a string.
    -----------------------------------------------------------------------
    USAGE: [out1, out2] = funName(inStr,inVar,inArr,inMat)
        inStr:      str, string or character type input description
        inVar:      double, description of 1x1 variable (unit)
        inArr:      nx1 double, description of an array. Arrays shoulbe be
                    nx1, not 1xn whenever possible because MATLAB accesses
                    memory column-wise fastest
                        [var1 var2 var3]'
                        (unit unit unit)
        inMat:      nxm cell, description of matrix
                        {var1 var2 var3;
                         var4 var5 var6}
                        (unit unit unit;
                         unit unit unit)
    -----------------------------------------------------------------------
    OUTPUT: 
        out1:       type, description
        out2:       type, description
    -----------------------------------------------------------------------
    REFERENCES:
        - Citations here, preferrably IEEE format
    -----------------------------------------------------------------------
    NOTES:
        - Text text text text text text text text text text text text text
          text text text text text text text text text text text text
        - Text text text text text text text text text text text text text
          text text text text text text text text text text text text
    -----------------------------------------------------------------------
    AUTHOR: Kaitlin Dennison
    -----------------------------------------------------------------------
    COPYTRIGHT: 2019 SLAB Group
    -----------------------------------------------------------------------
    TIMESTAMPS:
        - 13-Jun-2019: creation (KD)
    -----------------------------------------------------------------------
    %}
    
    %% Section1
    out1 = localFun(inVar);
    %% Section2
    out2 = inStr;

end

function out = localFun(in)
    % Short description
    % out = localFun(in)
    %{
    -----------------------------------------------------------------------
    INPUT:
        in:         type, description
    -----------------------------------------------------------------------
    OUTPUT:
        out:        type, description
    -----------------------------------------------------------------------
    NOTES:
        - Text
    -----------------------------------------------------------------------
    %}
    
    out = in;

end