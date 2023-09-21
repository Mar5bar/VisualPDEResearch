classdef (Abstract) Sim < handle

    properties (Abstract, Constant)
        Type
    end

    properties (Abstract, SetAccess = protected)
        NumSpecies
        Dimension
        SideLength
        BCs
        DiffCoeff
        Domain
        Sol
    end

    methods (Abstract)
        run(sim)
    end

    methods 
        function plot(sim)
            if isempty(fieldnames(sim.Sol))
                error("No solution available to plot. Call run() before plotting.")
            end
            switch sim.Dimension
            case 1
                plot(sim.Domain.x,sim.Sol.y)
            case 2
                surf(sim.Domain.x,sim.Domain.y,sim.Sol.y(:,end),'LineStyle','none')
            end
        end

        function setSideLength(sim,Ls)
            if numel(Ls) == 0
                error("No side length specified.")
            elseif numel(Ls) == 1
                Ls = Ls*ones(1,sim.Dimension);
            elseif numel(Ls) ~= sim.Dimension
                error("Fewer side lengths given than dimensions.")
            end
            sim.SideLength = Ls;
        end

        function setDiffCoeff(sim,spec)
            sim.DiffCoeff = cell(sim.NumSpecies);
            for i = 1 : sim.NumSpecies
                for j = 1 : sim.NumSpecies
                    sim.DiffCoeff{i,j} = str2func(spec.DiffCoeff{i,j});
                end
            end
        end
    end

end