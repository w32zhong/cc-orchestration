#!/bin/bash
#SBATCH --nodes=2           # total nodes
#SBATCH --gres=gpu:2        # how many GPUs per node
#SBATCH --cpus-per-task=4   # Cores proportional to GPUs: 6 on Cedar, 16 on Graham.
#SBATCH --mem=64gb          # Memory proportional to GPUs: 32000 Cedar, 64000 Graham.
#SBATCH --time=4-02:10      # 4 days and 2 hours and 10 minutes
#SBATCH --output=job-%j-%N.out

set -x
TRAINER=${1-colbert}
DATA_VER=FBxsZSLMCeLZDMk
CODE_VER=$(cd pya0 && pwd && git rev-parse HEAD)

case $TRAINER in
   pretrain)
    DEV_BSIZE=12
    EPOCHS=10
    EXTRA_DAT=$DATA_DIR/mse-aops-2021-vocab.pkl
    ;;
   finetune)
    DEV_BSIZE=12
    EPOCHS=5
    EXTRA_DAT=$DATA_DIR/mse-aops-2021-data.pkl.tags.ids
    ;;
   colbert)
    DEV_BSIZE=10
    EPOCHS=4
    EXTRA_DAT=
    EXTRA_ARG=--active_fp16
    ;;
esac

START_POINT=$DATA_DIR/$TRAINER/model
TOK_CKPOINT=$DATA_DIR/$TRAINER/tokenizer
SHARDS_LIST=$DATA_DIR/shards-for-$TRAINER.txt

N_NODE=$(cat $0 | grep -Po '(?<=SBATCH --nodes=)[0-9]+')
N_GPUS=$(cat $0 | grep -Po '(?<=SBATCH --gres=gpu:)[0-9]+')

export NCCL_BLOCKING_WAIT=1  # Set this variable to use the NCCL backend
export SLURM_ACCOUNT=def-jimmylin
export SBATCH_ACCOUNT=$SLURM_ACCOUNT
export SALLOC_ACCOUNT=$SLURM_ACCOUNT

DATA_DIR=data.$DATA_VER
if [ ! -e $DATA_DIR ]; then
    tarball=`mktemp`
    wget https://vault.cs.uwaterloo.ca/s/$DATA_VER -O $tarball
    tar xzf $tarball --one-top-level=$DATA_DIR --strip-components 1
fi

srun --unbuffered \
    python ./pya0/utils/transformer.py $TRAINER $START_POINT $TOK_CKPOINT $EXTRA_DAT \
    --cluster tcp://$(hostname):8921 \
    --shards_list $SHARDS_LIST \
    --batch_size $(($N_NODE * $N_GPUS * $DEV_BSIZE)) \
    --save_fold 5 --epochs $EPOCHS $EXTRA_ARG

# Other example usages
#srun python pytorch-test-v2.py tcp://$(hostname):8921
#salloc --nodes=1 --gres=gpu:1 --cpus-per-task=2 --time=0-01:10 --mem=32gb
#srun --jobid 12345 --pty bash
