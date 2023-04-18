#!/bin/bash
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1
#SBATCH --time=4-00:00:00
#SBATCH --mem=128000mb
#SBATCH --job-name=validation6
#SBATCH --error=job.%A.err
#SBATCH --output=job.%A.out

tool="./main"
folder="Simulation-Results/Insertion-Bias/validation_6"
genome="mb:1"
rep=100

# Updated base population without insertion bias
echo "5000 R 0; 0;
2500 R 0; 0; 0;
2500 R 0;;" > $folder/input_sel

# Updated base population without insertion bias
echo "5000 R 0; 0;
2500 R 0; 0; 0;
2500 R 0;;" > $folder/input_sel


# All commands updated
$tool --N 1000 --gen 100 --genome $genome --cluster kb:100 --rr 4 --rep $rep --u 0.1 --basepop "100(0)" --steps 25 -x 0.1 --file-mhp $folder/validation_6_1_mhp > $folder/validation_6_1 &

$tool --N 1000 --gen 100 --genome $genome --cluster kb:100 --rr 4 --rep $rep --u 0.1 --basepop "100(0)" --steps 25 -x 0.1 -no-x-cluins --file-mhp $folder/validation_6_2_mhp > $folder/validation_6_2 &

$tool --N 10000 --u 0 --basepop $folder/input_sel --gen 1000 --genome $genome --steps 10 --rr 0 --rep $rep --sampleid psel3 > $folder/validation_6_3 &

$tool --N 10000 --u 0 -x 0.1 --basepop $folder/input_sel --gen 1000 --genome $genome --steps 10 --rr 0 --rep $rep --sampleid psel4 > $folder/validation_6_4 &

$tool --N 10000 --u 0 -x 0.01 --basepop $folder/input_sel --gen 1000 --genome $genome --steps 10 --rr 0 --rep $rep --sampleid psel5 > $folder/validation_6_5 &

$tool --N 10000 --u 0 -x 0.001 --basepop $folder/input_sel --gen 1000 --genome $genome --steps 10 --rr 0 --rep $rep --sampleid psel6 > $folder/validation_6_6 &

$tool --N 10000 --u 0 -x 0.0001 --basepop $folder/input_sel --gen 1000 --genome $genome --steps 10 --rr 0 --rep $rep --sampleid psel7 > $folder/validation_6_7 &

# Wait for all simulations to finish
wait

# Concatenate output files
cat "$folder/validation_6_3" "$folder/validation_6_4" "$folder/validation_6_5" "$folder/validation_6_6" "$folder/validation_6_7" | grep -v "^Invade" | grep -v "^#" > "$folder/2023_03_09_Validation_6_Selection"
