classdef Model < handle

    properties
        Sim;
        Parameters = struct([]);
        NumSpecies = 1;
        Dimension = 1;
        SideLength = 1
        BCs = ["periodic"];
    end

    properties (Access = protected)
        % Set by buildSim. All parameters will be substituted in, so that these
        % are ready for str2func.
        DiffCoeffsStrs;
        ForcingStrs;
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