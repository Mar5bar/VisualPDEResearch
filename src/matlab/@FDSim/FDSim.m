classdef FDSim < Sim

    properties (Constant)
        Type = "FiniteDifference";
    end

    properties (SetAccess = protected)
        NumSpecies = 1;
        Dimension = 1;
        SideLength = 1;
        DiscNum = 1;
        Step = [1];
        BCs = ["periodic"];
        SpatialOps = struct();
    end

    methods
        function sim = FDSim(model)
            % Build a simulation from a model specification.
            if nargin == 1
                % Set properties.
                sim.NumSpecies = model.NumSpecies;
                sim.Dimension = model.Dimension;
                sim = setSideLength(sim,model.SideLength);
                sim = setDisc(sim,model.DiscNum);
                sim = setBCs(sim,model.BCs);

                % Build spatial operators.
                sim = setSpatialOps(sim,model);
            end
        end
        function sim = run(sim)
        end
        function plot(sim)
        end
    end

    methods (Access = protected)
        RHS(sim,t,y);

        function du = odefun(t,y)
            du = RHS(sim,t,y);
        end

        function sim = setDisc(sim,Ns)
            if numel(Ns) == 0
                error("No discretisation specified.")
            elseif numel(Ns) == 1
                Ns = Ns*ones(1,sim.Dimension);
            elseif numel(Ns) ~= sim.Dimension
                error("Fewer discretisation parameters given than dimensions.")
            end
            if any(Ns == 1)
                error("Discretisation parameters must all be larger than 1.")
            end
            sim.DiscNum = Ns;
            sim.Step = sim.SideLength ./ (Ns - 1);
        end

        function sim = setBCs(sim,BCs)
            if numel(BCs) == 0
                error("No boundary conditions specified.")
            elseif numel(BCs) == 1
                BCs = repmat(BCs,1,sim.NumSpecies);
            elseif numel(BCs) ~= sim.NumSpecies
                error("Fewer boundary conditions given than species.")
            end
            if any(BCs == "periodic") & ~all(BCs == "periodic")
                error("If periodic BCs are specified, they must be specified for all species.")
            end
            sim.BCs = BCs;
        end

        function sim = setSpatialOps(sim,model)
            % Generate spatial operators for advection and Laplace operators.
            % As these are sparse, the wasted memory will be minimal.

            sim.SpatialOps.AdFD = cell(sim.Dimension,1);
            sim.SpatialOps.AdBD = cell(sim.Dimension,1);
            sim.SpatialOps.LapFD = cell(sim.Dimension,1);
            sim.SpatialOps.LapBD = cell(sim.Dimension,1);

            for dim = 1:sim.Dimension
                e = ones(sim.DiscNum(dim),1);

                FD = spdiags([-e,e],[0,1],sim.DiscNum(dim),sim.DiscNum(dim));
                BD = spdiags([e,-e],[0,-1],sim.DiscNum(dim),sim.DiscNum(dim));

                if all(sim.BCs == "periodic")
                    FD(end,1) = 1;
                    BD(1,end) = -1;
                end

                switch sim.Dimension
                case 1
                    sim.SpatialOps.AdFD{dim} = FD / sim.Step(dim);
                    sim.SpatialOps.LapFD{dim} = FD / sim.Step(dim)^2;

                    sim.SpatialOps.AdBD{dim} = BD / sim.Step(dim);
                    sim.SpatialOps.LapBD{dim} = BD / (sim.Step(dim))^2;
                case 2
                    if dim == 1
                        I = speye(sim.DiscNum(2));

                        sim.SpatialOps.AdFD{dim} = kron(FD, I) / sim.Step(dim);
                        sim.SpatialOps.LapFD{dim} = kron(FD, I) / sim.Step(dim)^2;

                        sim.SpatialOps.AdBD{dim} = kron(BD, I) / sim.Step(dim);
                        sim.SpatialOps.LapBD{dim} = kron(BD, I) / sim.Step(dim)^2;
                    elseif dim == 2
                        I = speye(sim.DiscNum(1));

                        sim.SpatialOps.AdFD{dim} = kron(I, FD) / sim.Step(dim);
                        sim.SpatialOps.LapFD{dim} = kron(I, FD) / sim.Step(dim)^2;

                        sim.SpatialOps.AdBD{dim} = kron(I, BD) / sim.Step(dim);
                        sim.SpatialOps.LapBD{dim} = kron(I, BD) / sim.Step(dim)^2
                    end
                end

            end

        end
    end


end