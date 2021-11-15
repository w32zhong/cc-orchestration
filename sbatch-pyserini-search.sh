#!/bin/bash
#SBATCH --nodes=1           # total nodes
#SBATCH --gres=gpu:a100:1   # how many GPUs per node
#SBATCH --cpus-per-task=4   # Cores proportional to GPUs: 6 on Cedar, 16 on Graham.
#SBATCH --mem=120gb         # Memory proportional to GPUs: 32000 Cedar, 64000 Graham.
#SBATCH --time=1-2:10       # 1 days and 2 hours and 10 minutes
#SBATCH --output=job-%j-%N.out
set -x

export NCCL_BLOCKING_WAIT=1  # Set this variable to use the NCCL backend
export SLURM_ACCOUNT=def-jimmylin
export SBATCH_ACCOUNT=$SLURM_ACCOUNT
export SALLOC_ACCOUNT=$SLURM_ACCOUNT

COMMAND="$0 $@"
SRCH_RANGE=${1-10_5_10} # or 10_0_5

cd pyserini
srun --unbuffered python -m pyserini.dsearch \
	--topics msmarco-passage-dev-subset \
	--index /lustre07/scratch/w32zhong/msmarco-passage-index-339094 \
	--device cuda:0 \
	--encoder ../encoders/colbert_vanilla_128 \
	--tokenizer ../encoders/tokenizer-bert-base-uncased \
	--search-range $(echo $SRCH_RANGE | sed -e 's/_/ /g') \
	--output msmarco-passage-$SLURM_JOBID-$SRCH_RANGE.run

	#--encoder ../encoders/colbert_distil_128 \
	#--tokenizer ../encoders/tokenizer-distilbert-base-uncased \

echo python -m pyserini.dsearch \
	--topics msmarco-passage-dev-subset \
	--index /lustre07/scratch/w32zhong/msmarco-passage-index-debug \
	--device cuda:0 \
	--encoder ../encoders/colbert_distil_128 \
	--tokenizer ../encoders/tokenizer-distilbert-base-uncased \
	--output msmarco-passage-debug.run

# Other example usages
#salloc --nodes=1 --gres=gpu:1 --cpus-per-task=2 --time=0-01:10 --mem=32gb
#srun --jobid 12345 --pty bash
