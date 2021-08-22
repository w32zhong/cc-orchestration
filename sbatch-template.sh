#!/bin/bash
#SBATCH --nodes=4           # total nodes
#SBATCH --gres=gpu:1        # how many GPUs per node
#SBATCH --cpus-per-task=2   # Cores proportional to GPUs: 6 on Cedar, 16 on Graham.
#SBATCH --mem=32gb          # Memory proportional to GPUs: 32000 Cedar, 64000 Graham.
#SBATCH --time=2-00:10      # 2 days and 10 minutes
#SBATCH --output=job-%j-%N.out

export NCCL_BLOCKING_WAIT=1  # Set this variable to use the NCCL backend

export SLURM_ACCOUNT=def-jimmylin
export SBATCH_ACCOUNT=$SLURM_ACCOUNT
export SALLOC_ACCOUNT=$SLURM_ACCOUNT

set -x
srun --unbuffered python pya0/utils/transformer.py 8 --master tcp://$(hostname):8921
