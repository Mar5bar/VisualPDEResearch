classdef FDSolver < Solver

    methods
        function solver = FDSolver()
            solver.Type = "FiniteDifference";
        end
    end

    methods (Access = protected)
        function init(solver)
            % Must set IsReady = true if init successful.
            disp("Init")
            solver.IsReady = true;
        end

        function compute(solver)
            disp("Computing")
        end
    end

end