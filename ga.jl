using Random
using Plots
using Printf

# Globals

cities = [
    (44, 95)
    (58, 92)
    (11, 89)
    (42, 34)
    (82, 27)
    (11, 6)
    (83, 77)
    (36, 6)
    (46, 59)
    (17, 56)
    (10, 87)
    (63, 72)
    (82, 64)
    (53, 64)
    (77, 50)
    (44, 44)
    (30, 6)
    (92, 31)
    (44, 49)
    (64, 37)
    (91, 14)
    (82, 12)
    (52, 10)
    (67, 81)
    (6, 83)
    (46, 80)
    (75, 48)
    (8, 74)
    (18, 20)
    (82, 40)
    (64, 45)
    (26, 50)
    (53, 55)
    (67, 32)
    (71, 11)
    (90, 52)
    (53, 69)
    (88, 25)
    (37, 84)
    (87, 90)
    (66, 85)
    (78, 37)
    (45, 62)
    (64, 81)
    (9, 36)
    (10, 49)
    (90, 57)
    (38, 70)
    (54, 44)
    (25, 52)
    (44, 95)
]

mutable struct Candidate
    chromosome::Vector{Tuple{Int64,Int64}}
    fitness::Float64
end

chromosomeSize = size(cities,1)
populationSize = 20000
# Make sure populationSize is divisible by truncationSelection
truncationSelection = 40
numberOfOffsprings = trunc(Int,populationSize / truncationSelection)

# Modified Quick Sort 
# https://gist.github.com/alexholehouse/2624050
# I have no idea what it does but it works very well
function qsort!(a,lo,hi)
    i, j = lo, hi
    while i < hi
        pivot = a[(lo+hi)>>>1].fitness
        while i <= j
            while a[i].fitness < pivot; i = i+1; end
            while a[j].fitness > pivot; j = j-1; end
            if i <= j
                a[i], a[j] = a[j], a[i]
                i, j = i+1, j-1
            end
        end
        if lo < j; qsort!(a,lo,j); end
        lo, j = i, hi
    end
    return a
end
# End of Copied Code

function generateRandomCities(n)
    for _ in 1:n
        r1 = rand(2:100)
        r2 = rand(2:100)
        println("($r1, $r2)")
    end
end

function calculateDistance(A::Tuple{Int64,Int64}, B::Tuple{Int64,Int64})::Float64
    return sum((A .- B).^2) ^ 0.5
end

function calculateFitness(chromosome::Vector{Tuple{Int64,Int64}})
    totalDistance = 0
    for i in 1:chromosomeSize - 1
        totalDistance += calculateDistance(chromosome[i],chromosome[i+1])
    end
    return 1/totalDistance * 1000
end


function calculateFitness!(candidate::Candidate)
    totalDistance = 0.0
    for i in 1:chromosomeSize - 1
        totalDistance += calculateDistance(
            candidate.chromosome[i],
            candidate.chromosome[i+1]
            )
    end
    # The lower the distance, the better the fitness
    # * 100 for readability
    candidate.fitness = 1/totalDistance * 1000
end

function getIndexes()::Tuple{Int64,Int64}
    # Index for Subarray
    # 3 and -3 to avoid edge case
    lower = rand(3:chromosomeSize - 3)
    upper = rand(3:chromosomeSize - 3)
    if lower > upper
        upper,lower = lower,upper
    elseif  lower == upper
        if lower != 1
            lower -= 1
        end
    end
    return lower,upper
end

# The order of A and B matter.
function OX(A::Candidate,B::Candidate,lower::Int64,upper::Int64)::Candidate
    child = Candidate([(0.0,0.0) for _ in 1:chromosomeSize],0.0)
    for i in lower:upper
        child.chromosome[i] = A.chromosome[i]
    end
    childIndex = 1
    parentIndex = 1
    while childIndex != chromosomeSize
        if childIndex == lower
            childIndex = upper + 1
        end
        if B.chromosome[parentIndex] in child.chromosome
            parentIndex += 1
        else
            child.chromosome[childIndex] = B.chromosome[parentIndex]
            childIndex += 1
            parentIndex += 1
        end
    end
    return child
end

function OX(A::Candidate,B::Candidate)::Candidate
    lower, upper = getIndexes()
    child = Candidate([(0.0,0.0) for _ in 1:chromosomeSize],0.0)
    for i in lower:upper
        child.chromosome[i] = A.chromosome[i]
    end
    childIndex = 1
    parentIndex = 1
    while childIndex != chromosomeSize
        if childIndex == lower
            childIndex = upper + 1
        end
        if B.chromosome[parentIndex] in child.chromosome
            parentIndex += 1
        else
            child.chromosome[childIndex] = B.chromosome[parentIndex]
            childIndex += 1
            parentIndex += 1
        end
    end
    return child
end

function population_shuffle(c)
    c[2 : end - 1] = shuffle(c[2 : end - 1])
    return c
end

function initialise()
    populationArray = []
    sizehint!(populationArray,populationSize)
    for _ in 1:populationSize
        randomisedCity = population_shuffle(cities)
        # Copy to force julia to pass by value than reference.
        push!(populationArray,Candidate(copy(randomisedCity), calculateFitness(randomisedCity)))
    end
    return populationArray
end

function GeneticAlgorithm(generationLimit)
    populationArray = initialise()
    qsort!(populationArray,1,populationSize)
    best = populationArray[end]
    current = populationArray[end]
    for generation in 1:generationLimit
        # Truncation Selection
        selection = populationArray[end - truncationSelection:end]
        # CrossOver
        index = 1
        while index <= populationSize
            for _ in 1:numberOfOffsprings
                for i in 1:truncationSelection - 1
                    populationArray[i] = OX(selection[i],selection[i+1])
                    index += 1
                end
                # To make sure the first and last also mate twice
                populationArray[index] = OX(selection[1],selection[end])
                index += 1
            end
        end
        qsort!(populationArray,1,populationSize)
        current = populationArray[end]
        if current.fitness > best.fitness
            best = copy(current)
        end
        @printf("Generation: %d\tBest Fitness: %.4f\tCurrent Fitness: %.4f\n",generation,best.fitness,current.fitness)
    end
    return populationArray,best
end