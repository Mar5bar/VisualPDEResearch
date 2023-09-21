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
        DiffCoeff = cell(1);
        Sol = struct();
        Domain = struct();
        InitCond = [];
        Params = struct();
        TSpan = linspace(0,1,1e2);
    end

    methods
        function sim = FDSim(spec)
            % Build a simulation from a model specification.
            if nargin == 1
                % Set properties.
                sim.NumSpecies = spec.NumSpecies;
                sim.Dimension = spec.Dimension;
                setSideLength(sim,spec.SideLength);
                setDisc(sim,spec.DiscNum);
                setBCs(sim,spec.BCs);
                setTSpan(sim,spec.TSpan);

                % Construct domain.
                setDomain(sim);

                % Set initial condition.
                setInitCond(sim,spec);

                % Build spatial operators.
                setSpatialOps(sim,spec);

                % Form anonymous functions for diffusion coeffs.
                setDiffCoeff(sim,spec);

            end
        end
        function run(sim)
            sim.Sol = ode15s(@(t,y)odefun(sim,t,y),sim.TSpan,sim.InitCond);
        end
    end

    methods 
        du = RHS(sim,t,y);

        function du = odefun(sim,t,y)
            du = RHS(sim,t,y);
        end

        function setDisc(sim,Ns)
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

        function setTSpan(sim,Ts)
            if numel(Ts) == 2
                Ts = linspace(Ts(1),Ts(2),1e2);
            end
            sim.TSpan = Ts;
        end

        function setBCs(sim,BCs)
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

        function setSpatialOps(sim,model)
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
                    switch dim
                    case 1
                        raise = @(m) kron(m,speye(sim.DiscNum(2)));
                    case 2
                        raise = @(m) kron(speye(sim.DiscNum(1)),m);
                    end
                    sim.SpatialOps.AdFD{dim} = raise(FD) / sim.Step(dim);
                    sim.SpatialOps.LapFD{dim} = raise(FD) / sim.Step(dim)^2;

                    sim.SpatialOps.AdBD{dim} = raise(BD) / sim.Step(dim);
                    sim.SpatialOps.LapBD{dim} = raise(BD) / sim.Step(dim)^2;
                end

            end

        end

        function setDomain(sim)
            x = linspace(0,sim.SideLength(1),sim.DiscNum(1));
            sim.Domain.x = x;
            sim.Domain.xm = x(:);
            sim.Domain.ym = 0*sim.Domain.x;
            sim.Domain.ym = 0*sim.Domain.xm;
            if sim.Dimension == 2
                y = linspace(0,sim.SideLength(2),sim.DiscNum(2));
                sim.Domain.y = y;
                [xm,ym] = meshgrid(x,y);
                sim.Domain.xm = xm;
                sim.Domain.ym = ym;
            end
        end

        function setInitCond(sim,spec)
            sim.InitCond = zeros([sim.NumSpecies,sim.DiscNum]);
            for i = 1 : sim.NumSpecies
                f = str2func(spec.InitCond{i});
                sim.InitCond(i,:) = f(sim.Domain.xm(:),sim.Domain.ym(:),sim.Params);
            end
            sim.InitCond = permute(sim.InitCond,[2:length(size(sim.InitCond)),1]);
            sim.InitCond = sim.InitCond(:);
        end

    end


end