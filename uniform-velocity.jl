using Oceananigans
# using CairoMakie
using Plots
# using LazyGrids
# using UnicodePlots


grid = RegularRectilinearGrid(size=(128, 128), x=(-5, 5), y=(-5, 5),
                              topology=(Periodic, Periodic, Flat))

model = NonhydrostaticModel(grid=grid, tracers=:c, buoyancy=nothing)

initial_c(x, y, z) = exp.(-x.^2 - y.^2)
set!(model, u=1, c=initial_c)

xs =  LinRange(-5, 5, 128)
ys =  LinRange(-5, 5, 128)


simulation = Simulation(model, Δt=1e-2, stop_iteration=1000)


using Oceananigans.OutputWriters: JLD2OutputWriter, IterationInterval

simulation.output_writers[:velocities] = JLD2OutputWriter(model,
(c=model.tracers.c,),
prefix="uniform-velocity-particle",
schedule=IterationInterval(10), force=true)



run!(simulation)

# simulation.stop_iteration

# simulation.model.clock.iteration

x,y,z = nodes(model.velocities.u)

#xu, yu, zu = nodes(u)


using JLD2

file = jldopen(simulation.output_writers[:velocities].filepath)

iterations = parse.(Int, keys(file["timeseries/t"]))


anim = @animate for (i, iter) in enumerate(iterations)
    
    @info "Drawing frame $i from iteration $iter..."
    
    t = file["timeseries/t/$iter"]
    c = file["timeseries/c/$iter"][:, :, 1]
    Plots.heatmap(x, y, c', colormap=:deep)
end

    #print(v)
    # print(t)
    
    # cMatrixTrimmed = interior(model.tracers.c)[:, :, 1]'
    # Plots.heatmap(x, y, cMatrixTrimmed, colormap=:deep)

mp4(anim, "uniform-velocity-particle.mp4", fps = 8)



# fig = Figure(resolution=(700, 450), fontsize=18, font="sans")
# ax = fig[1, 1] = Axis(fig, xlabel="x", ylabel="y")