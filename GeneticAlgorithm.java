import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Scanner;
import java.util.Random;


public class GeneticAlgorithm {
    private final static int populationSize = 10000;
    private final static int chromosomeSize = 50;
    private static int truncationSelection = 500;
    private final static int biodiversityRefresh = 100;
    private final static int biodiversityScaleFactor = 5;

    private double[] probability = new double[truncationSelection * biodiversityScaleFactor];
    private final static int numberOfOffsprings = populationSize / truncationSelection;

    private int[][] cities = new int[chromosomeSize][2];
    private Candidate[] populationArray = new Candidate[populationSize];
    private Candidate[] selection = new Candidate[truncationSelection * biodiversityScaleFactor];

    private Candidate best;
    private Candidate current;

    private Random rand = new Random();



    // private Candidate[]

    // BEGIN https://www.geeksforgeeks.org/quick-sort/
    private static void swap(Candidate[] arr, int i, int j) {
        Candidate temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }

    private static int partition(Candidate[] arr, int low, int high){
        double pivot = arr[high].getFitness();
        int i = (low - 1);
        for (int j = low; j <= high - 1; j++) {
            if (arr[j].getFitness() < pivot) {
                i++;
                swap(arr, i, j);
            }
        }
        swap(arr, i + 1, high);
        return (i + 1);
    }

    private static void quickSort(Candidate[] populationArray, int low, int high) {
        if (low < high) {
            int pi = partition(populationArray, low, high);
            quickSort(populationArray, low, pi - 1);
            quickSort(populationArray, pi + 1, high);
        }
    }
    // END

    private void shuffle(int[][] array) {
        for (int i = 1; i < array.length - 1; i++) {
			int randomIndexToSwap = rand.nextInt(1,array.length - 1);
			int[] temp = array[randomIndexToSwap];
			array[randomIndexToSwap] = array[i];
			array[i] = temp;
		}
    }

    private void loadFile(){
        int index = 0;
        String[] str;
        try(Scanner s = new Scanner(new FileReader("cities"))) {
            while (s.hasNextLine()) {
                // temp = s.nextLine();
                // if (temp.equals("")) break;
                str = s.nextLine().split(" ");
                cities[index][0] = Integer.valueOf(str[0]);
                cities[index][1] = Integer.valueOf(str[1]);
                index++;
            }
        } catch (Exception e) {
            System.out.println("An Error has occured!\n" + e);
        }
    }

    private void saveToFile(String fileName) throws IOException {
        FileWriter fileWriter = new FileWriter(fileName);
        try (PrintWriter printWriter = new PrintWriter(fileWriter)) {
            for(int i = 0; i < chromosomeSize; i++) {
                printWriter.printf("%d %d\n", best.getGene(i)[0], best.getGene(i)[1]);
            }
        }
    }  

    private boolean checkExists(int[] city, Candidate A) {
        for (int i = 0; i < A.getChromosomeLength(); i++) {
            // System.out.println(A.getGene(i)[0] + " " + A.getGene(i)[1] + " | " + city[0] + " " + city[1]);
            if (city[0] == A.getGene(i)[0] && city[1] == A.getGene(i)[1]) {
                return true;
            }
        }
        return false;
    }

    private Candidate OX(Candidate A, Candidate B) {
        int lower, upper;
        lower = rand.nextInt(2,chromosomeSize - 2);
        upper = rand.nextInt(2,chromosomeSize - 2);
        if (lower > upper) {
            int temp = lower;
            lower = upper;
            upper = temp;
        }
        else if (lower == upper) {
            lower--;
        }
        Candidate child = new Candidate(chromosomeSize);
        for(int i = lower; i < upper; i++) {
            child.setGene(A.getGene(i), i);
        }
        int childIndex = 0;
        int parentIndex = 0;
        while (childIndex < chromosomeSize - 1) {
            if (childIndex == lower) {
                childIndex = upper;
            }
            if (checkExists(B.getGene(parentIndex), child)) {
                parentIndex++;
            }
            else {
                child.setGene(B.getGene(parentIndex), childIndex);
                childIndex++;
                parentIndex++;
            }
        }
        child.setGene(child.getGene(0), chromosomeSize - 1);
        mutate(child);
        child.calculateFitness();
        return child;
    }

    private void mutate(Candidate A) {
        while (rand.nextFloat() < 0.5) {
            int i,j;
            i = rand.nextInt(2,chromosomeSize - 2);
            j = rand.nextInt(2,chromosomeSize -2);
            int[] temp = A.getGene(i);
            A.setGene(A.getGene(j),i);
            A.setGene(temp, j);
        }
    }

    private void initialise() {
        for(int i = 0; i < populationSize; i++) {
            shuffle(cities);
            populationArray[i] = new Candidate(cities);
        }
        quickSort(populationArray,0,populationSize - 1);
        this.best = populationArray[populationSize - 1];
        this.current = populationArray[populationSize - 1];
    }

    private void truncationSelection() {
        for(int i = 0; i < truncationSelection; i++) {
            selection[i] = new Candidate(populationArray[populationSize - i - 1]);
        }
    }
    
    // private void rouletteWheelSelection() {
    //     double totalFitness = 0.0;
    //     for(Candidate i : populationArray) {
    //         totalFitness += i.getFitness();
    //     }


    // }

    private void runSimulation(int generationLimit) {
        int index;
        for(int generation = 0; generation < generationLimit; generation++) {
            // Every 50 Generations, undergo biodiversity preservation
            // if (generation % biodiversityRefresh == 0) {
            //     truncationSelection *= biodiversityScaleFactor;    
            // }
            truncationSelection();
            // selection[truncationSelection - 1] = best;
            index = 0;
            while (index < populationSize - 3) {
                for(int lmao = 0; lmao < populationSize / truncationSelection; lmao++) {
                    for(int i = 0; i < truncationSelection - 1; i++) {
                        populationArray[index] = OX(selection[i], selection[i + 1]);
                        index++;
                    }
                    if (index != populationSize) {
                        populationArray[index] = OX(selection[0],selection[truncationSelection - 1]);
                        index++;
                    }
                }
            }
            quickSort(populationArray, 0, populationSize - 1);
            current = populationArray[populationSize - 1];
            if (current.getFitness() > best.getFitness()) {
                best = current;
            }
            System.out.printf("Generation: %d\tBest Fitness: %.4f\tCurrent Fitness: %.4f\n",generation,best.getFitness(),current.getFitness());
            // if (generation % biodiversityRefresh == 0) {
            //     truncationSelection /= biodiversityScaleFactor;
            // }
        }
    }

    public void printCities() {
        for(int i = 0; i < chromosomeSize; i++) {
            System.out.printf("%d %d\n",cities[i][0], cities[i][1]);
        }
    }

    public static void main(String[] args) throws IOException{
        // System.out.println("Hello World!");
        GeneticAlgorithm ga = new GeneticAlgorithm();
        ga.loadFile();
        ga.initialise();
        ga.runSimulation(500);
        ga.saveToFile("output.txt");
    }
}
