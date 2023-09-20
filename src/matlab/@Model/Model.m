classdef Model < handle

    properties
        Value = 1;
        Solver;
    end

    methods
        % Constructor
        function vm = Model(filepath)

        end

       load(vm,filepath)

       function solve(vm)
            if (any(contains([class(vm.Solver);superclasses(vm.Solver)],"Solver")))
                vm.Solver.solve();
            else
                error("Solver not set.")
            end
       end
    end

end