classdef FDModel < Model

    properties
        % ----
        % TEMP FOR TESTING.
        DiscNum = 101;
        DiffCoeff = cell(1);
        InitCond = cell(1);
        TSpan = [0,1];
        % ----
    end

    methods

        function fd = FDModel(spec)
            % ----
            % TEMP FOR TESTING.
            fd.DiffCoeff{1,1} = "@(t,x,y,params) 1 + 0*x";
            fd.InitCond{1} = "@(x,y,params) exp(-20*(x-0.5).^2)";
        end

    end


end