classdef Model < handle

    properties
        Sim;
        Parameters = struct([]);
        NumSpecies = 1;
        Dimension = 1;
        SideLength = 1
        BCs = ["periodic"];
    end

    methods
        % Constructor
        function vm = Model(filepath)

        end

        load(vm,filepath)

        buildSim(vm)

        function solve(vm)
            vm.Sim.run();
        end
    end

end