#!/bin/bash
#SBATCH --nodes=2           # total nodes
#SBATCH --gres=gpu:2        # how many GPUs per node
#SBATCH --cpus-per-task=4   # Cores proportional to GPUs: 6 on Cedar, 16 on Graham.
#SBATCH --mem=64gb          # Memory proportional to GPUs: 32000 Cedar, 64000 Graham.
#SBATCH --time=6-02:10      # 4 days and 2 hours and 10 minutes
#SBATCH --output=job-%j-%N.out

export NCCL_BLOCKING_WAIT=1  # Set this variable to use the NCCL backend

export SLURM_ACCOUNT=def-jimmylin
export SBATCH_ACCOUNT=$SLURM_ACCOUNT
export SALLOC_ACCOUNT=$SLURM_ACCOUNT

set -x
srun --unbuffered python pya0/utils/transformer.py pretrain \
        --cluster tcp://$(hostname):8921 \
        --ckpoint base-models/bert-base-uncased \
        --tok_ckpoint base-models/bert-tokenizer \
        --batch_size $((2 * 2 * 8)) --save_fold 100 --epochs 3
# Other example usages
#srun python pytorch-test-v2.py tcp://$(hostname):8921
#salloc --nodes=1 --gres=gpu:1 --cpus-per-task=2 --time=0-01:10 --mem=32gb
#srun --jobid 12345 --pty bash
