function du = RHS(sim,t,y)
    du = sim.DiffCoeff{1,1}(t,sim.Domain.xm,sim.Domain.ym,sim.Params).*(sim.SpatialOps.LapFD{1} - sim.SpatialOps.LapBD{1}) * y;
end