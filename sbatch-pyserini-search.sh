#!/bin/bash
#SBATCH --nodes=1           # total nodes
#SBATCH --gres=gpu:1        # how many GPUs per node
#SBATCH --cpus-per-task=4   # Cores proportional to GPUs: 6 on Cedar, 16 on Graham.
#SBATCH --mem=64gb          # Memory proportional to GPUs: 32000 Cedar, 64000 Graham.
#SBATCH --time=2-02:10      # 2 days and 2 hours and 10 minutes
#SBATCH --output=job-%j-%N.out
set -x
N_NODE=$(cat $0 | grep -Po '(?<=SBATCH --nodes=)[0-9]+')
N_GPUS=$(cat $0 | grep -Po '(?<=SBATCH --gres=gpu:)[0-9]+')

export NCCL_BLOCKING_WAIT=1  # Set this variable to use the NCCL backend
export SLURM_ACCOUNT=def-jimmylin
export SBATCH_ACCOUNT=$SLURM_ACCOUNT
export SALLOC_ACCOUNT=$SLURM_ACCOUNT

cd pyserini
srun --unbuffered python -m pyserini.dsearch \
	--topics msmarco-passage-dev-subset \
	--index ../msmarco-passage-index-53609828 \
	--encoder ../encoders/colbert_distil_128 \
	--tokenizer ../encoders/tokenizer-distilbert-base-uncased \
	--output msmarco-passage-$SLURM_JOBID.run

# Other example usages
#salloc --nodes=1 --gres=gpu:1 --cpus-per-task=2 --time=0-01:10 --mem=32gb
#srun --jobid 12345 --pty bash