#!/bin/bash
#SBATCH --nodes=2           # total nodes
#SBATCH --gres=gpu:2        # how many GPUs per node
#SBATCH --cpus-per-task=4   # Cores proportional to GPUs: 6 on Cedar, 16 on Graham.
#SBATCH --mem=64gb          # Memory proportional to GPUs: 32000 Cedar, 64000 Graham.
#SBATCH --time=4-02:10      # 4 days and 2 hours and 10 minutes
#SBATCH --output=job-%j-%N.out

set -x
export NCCL_BLOCKING_WAIT=1  # Set this variable to use the NCCL backend
export SLURM_ACCOUNT=def-jimmylin
export SBATCH_ACCOUNT=$SLURM_ACCOUNT
export SALLOC_ACCOUNT=$SLURM_ACCOUNT

TRAINER=finetune
#TRAINER=pretrain
START_POINT=save/$TRAINER/0-0-0 #base-models/bert-base-uncased
TOK_CKPOINT=base-models/bert-tokenizer
if [ $TRAINER == finetune ]; then
    ADD_DAT=./data/mse-aops-2021-data.pkl.tags.ids
else
    ADD_DAT=./data/mse-aops-2021-vocab.pkl
fi

set -x
srun --unbuffered python \
    ./pya0/utils/transformer.py $TRAINER $START_POINT $TOK_CKPOINT $ADD_DAT \
    --cluster tcp://$(hostname):8921 \
    --shards_list data/shards-for-$TRAINER.txt \
    --batch_size $((2 * 2 * 10)) --save_fold 4 --epochs 20

# Other example usages
#srun python pytorch-test-v2.py tcp://$(hostname):8921
#salloc --nodes=1 --gres=gpu:1 --cpus-per-task=2 --time=0-01:10 --mem=32gb
#srun --jobid 12345 --pty bash
