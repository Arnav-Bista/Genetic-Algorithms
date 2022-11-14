import java.lang.Math;
public class Candidate {
    private int[][] chromosome;
    private double fitness;
    
    public Candidate() {}

    public Candidate(int length) {
        this.chromosome = new int[length][2];
    }

    public Candidate(Candidate c) {
        this.chromosome = new int[c.chromosome.length][2];
        for(int i = 0; i < c.chromosome.length; i++) {
            for(int j = 0; j < c.chromosome[i].length; j++) {
                this.chromosome[i][j] = c.chromosome[i][j];
            }
        }
        calculateFitness(c.chromosome);
    }

    public Candidate(int[][] chromosome) {
        this.chromosome = new int[chromosome.length][2];
        for(int i = 0; i < chromosome.length; i++) {
            for(int j = 0; j < chromosome[i].length; j++) {
                this.chromosome[i][j] = chromosome[i][j];
            }
        }
        calculateFitness(chromosome);
    }

    public Candidate(int[][] chromosome, double fitness) {
        for(int i = 0; i < chromosome.length; i++) {
            for(int j = 0; j < chromosome[i].length; j++) {
                this.chromosome[i][j] = chromosome[i][j];
            }
        }
        this.fitness = fitness;
    }

    private void calculateFitness(int[][] chromosome) {
        double distance = 0.0;
        for(int i = 0; i < chromosome.length - 1; i++) {
            distance += Math.pow(Math.pow(chromosome[i][0] - chromosome[i+1][0], 2) + Math.pow(chromosome[i][1] - chromosome[i+1][1], 2), 0.5); 
        }
        this.fitness = 1 / distance * 1000;
    }

    public void calculateFitness() {
        double distance = 0.0;
        for(int i = 0; i < chromosome.length - 1; i++) {
            distance += Math.pow(Math.pow(chromosome[i][0] - chromosome[i+1][0], 2) + Math.pow(chromosome[i][1] - chromosome[i+1][1], 2), 0.5); 
        }
        this.fitness = 1 / distance * 1000;   
    }

    public int getChromosomeLength() {
        return this.chromosome.length;
    }

    public int[][] getChromosome(){
        return this.chromosome;
    }

    public void setChromosome(int[][] chromosome){
        this.chromosome = chromosome;
    }

    public void setGene(int[] gene, int index) {
        this.chromosome[index] = gene;
    }

    public int[] getGene(int index) {
        return this.chromosome[index];
    } 

    public double getFitness(){
        return this.fitness;
    }

    public void setFitness(double fitness) {
        this.fitness = fitness;
    }

    public void print() {
        for(int i = 0; i < chromosome.length;i++) {
            System.out.printf("%d %d\n",chromosome[i][0],chromosome[i][1]);
        }
    }


}
