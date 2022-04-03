using Plots
using Random
cities = [
    (1, 1) # INITIAL CITY, HAS TO BE FIRST AND LAST
    (46, 77)
    (17, 57)
    (100, 100)
    (12, 29)
    (68, 48)
    (80, 12)
    (73, 32)
    (12, 99)
    (86, 88)
    (29, 83)
    (66, 47)
    (50, 30)
    (59, 16)
    (47, 48)
    (16, 100)
    (76, 54)
    (98, 13)
    (64, 6)
    (94, 78)
    (49, 20)
    (30, 3)
    (51, 57)
    (22, 17)
    (24, 42)
    (54, 10)
    (24, 36)
    (19, 25)
    (13, 47)
    (50, 40)
    (55, 45)
    (76, 92)
    (94, 95)
    (72, 17)
    (85, 59)
    (23, 100)
    (54, 78)
    (10, 19)
    (83, 41)
    (88, 56)
    (73, 97)
    (1, 1)
]

mutable struct Candidate
    chromosome::Vector{Tuple{Int64,Int64}}
    fitness::Float64
end

scatter(cities)
chromosomeSize = size(cities, 1)
populationSize = 4000
divisions = 800
halfPopulation = trunc(Int, populationSize / 2)

function generateRandomCities(n)
    for i in 1:n
        r1 = rand(2:100)
        r2 = rand(2:100)
        println("($r1 , $r2 )")
    end
end

function bubbleSort(data)
    len = size(data, 1)
    for i in 1:len
        for j in 1:len-1
            if data[j].fitness < data[j+1].fitness
                data[j], data[j+1] = data[j+1], data[j]
            end
        end
    end
end

function getDistance(x1, x2)
    (sum((x2 .- x1) .^ 2))^0.5
end

function getFitness(candidate)
    distance = 0.0
    for i in 1:chromosomeSize-1
        distance += getDistance(candidate[i], candidate[i+1])
    end
    return 1 / distance * 1000
end

function truncationSelection(populationArray)
    bubbleSort(populationArray)
    index = trunc(Int, populationSize / divisions)
    return populationArray[1:index]
end

function mutate(candidate::Candidate)
    # 50% chance to mutate
    if rand((true, false))
        iS = rand(2:chromosomeSize-1)
        iL = rand(2:chromosomeSize-1)
        candidate.chromosome[iS], candidate.chromosome[iL] = candidate.chromosome[iL], candidate.chromosome[iS]
    end
    candidate.fitness = getFitness(candidate.chromosome)
    return candidate
end

function MyCrossover(P1::Candidate, P2::Candidate)
    # Don't judge, if it works it works.
    # If it ain't broke, don't fix it ;)
    C1 = Candidate([(1, 1) for i in 1:chromosomeSize], 0.0)
    iS = rand(2:chromosomeSize-1)
    iL = rand(2:chromosomeSize-1)
    C1.chromosome[iS:iL] = P1.chromosome[iS:iL]
    for i in 2:iS
        j = 1
        while j < chromosomeSize
            if P2.chromosome[j] in C1.chromosome
                j += 1
            else
                C1.chromosome[i] = P2.chromosome[j]
                break
            end
        end
    end
    for i in iL:chromosomeSize-1
        j = 1
        while j < chromosomeSize
            if P2.chromosome[j] in C1.chromosome
                j += 1
            else
                C1.chromosome[i] = P2.chromosome[j]
                break
            end
        end
    end
    return C1
end

function generateCandidate(candidate)
    final = [(1, 1) for i in 1:chromosomeSize]
    final[2:end-1] = shuffle(candidate[2:end-1])
    return Candidate(final, getFitness(final))
end

function initiateGeneration(limit)
    populationArray = [Candidate(cities, 0) for i in 1:populationSize]
    for i in 1:populationSize
        populationArray[i] = generateCandidate(cities)
    end
    bubbleSort(populationArray)
    println("Generation: 0   Highest Fitness: ", populationArray[1].fitness)
    return calculateGeneration(limit, populationArray, 1)
end

function mate(parentArray)
    # Randomly select parents for mating
    # Prevents the same paents from making multiple offsprings
    m = size(parentArray, 1)
    half = trunc(Int, m / 2)
    PArray1 = [Candidate(cities, 0) for i in 1:halfPopulation]
    PArray2 = [Candidate(cities, 0) for i in 1:halfPopulation]
    for j in 1:divisions
        indexList = [i for i in 1:m]
        for i in 1:half
            choice = rand(indexList)
            splice!(indexList, findall(x -> x == choice, indexList)[1])
            P1 = parentArray[choice]
            choice = rand(indexList)
            splice!(indexList, findall(x -> x == choice, indexList)[1])
            P2 = parentArray[choice]
            C1 = mutate(MyCrossover(P1, P2))
            C2 = mutate(MyCrossover(P1, P2))
            PArray1[i+(j-1)*half] = C1
            PArray2[i+(j-1)*half] = C2
        end
    end
    return [PArray1; PArray2]
end

function calculateGeneration(limit, populationArray, generationNumber)
    a = Animation()
    max = populationArray[1]
    while generationNumber < limit
        parentArray = truncationSelection(populationArray)
        populationArray = [Candidate(cities, 0) for i in 1:populationSize]
        parentArraySize = size(parentArray, 1)
        populationArray = mate(parentArray)
        for i in 1:populationSize
            populationArray[i] = mutate(populationArray[i])
        end
        bubbleSort(populationArray)
        println("Generation: ", generationNumber, "   Highest Fitness: ", round(populationArray[1].fitness, digits=5), "   Best Fitness: ", round(max.fitness, digits=5))
        if populationArray[1].fitness > max.fitness
            max = populationArray[1]
        end
        generationNumber += 1
        f = plot(populationArray[1].chromosome, label="Route", title="Generation: $generationNumber")
        f = plot!(max.chromosome, label="Best Solution", linecolor=:red, linewidth=2)
        f = scatter!(cities, label="Cities")
        #! DISPLAY PLOT REAL TIME
        display(f)
        frame(a, f)
    end
    return populationArray, a, max
end

function plt(a)
    plot(a.chromosome)
    scatter!(cities)
end

#=
After installing julia, you must install Plots.jl
Open cmd, type "julia" and then type " ] add 'Plots' "


INSTRUCTIONS FOR USE:
This is to be done using REPL. (Interactive window)
> popualtionArray, animation, bestSolution = initiateGeneration(TOP GENERATION LIMIT)

To view the animation, type: gif(animation)
to save it, type: gif(animation,"mygifname.gif")

To disable realtime plotting, comment out "display(f)" at line 237

=#