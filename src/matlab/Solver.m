classdef Solver < handle

    properties
        Type string = "";
        IsReady logical = false;
        Params struct = struct([]);
    end

    methods (Sealed)
        function solve(solver)
            if (~solver.IsReady)
                solver.init();
            end
            solver.compute();
        end
    end

    methods (Access = protected)
        % Must set IsReady = true if init successful.
        function init(solver)
        end

        function compute(solver)
        end
    end

end