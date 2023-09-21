classdef (Abstract) Sim

    properties (Abstract, Constant)
        Type
    end

    properties (Abstract, SetAccess = protected)
        NumSpecies
        Dimension
        SideLength
        BCs
    end

    methods (Abstract)
        run(sim)
        plot(sim)
    end

    methods 
        function sim = setSideLength(sim,Ls)
            if numel(Ls) == 0
                error("No side length specified.")
            elseif numel(Ls) == 1
                Ls = Ls*ones(1,sim.Dimension);
            elseif numel(Ls) ~= sim.Dimension
                error("Fewer side lengths given than dimensions.")
            end
            sim.SideLength = Ls;
        end
    end

end