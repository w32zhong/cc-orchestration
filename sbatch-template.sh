#!/bin/bash
#SBATCH --nodes=2           # total nodes
#SBATCH --gres=gpu:2        # how many GPUs per node
#SBATCH --cpus-per-task=4   # Cores proportional to GPUs: 6 on Cedar, 16 on Graham.
#SBATCH --mem=64gb          # Memory proportional to GPUs: 32000 Cedar, 64000 Graham.
#SBATCH --time=4-02:10      # 4 days and 2 hours and 10 minutes
#SBATCH --output=job-%j-%N.out
set -x

#####################
#  Configuration
#####################
TRAINER=${1-colbert}
CODE_VER=$(cd pya0 && pwd && git rev-parse HEAD)

EPOCHS=40
case $TRAINER in
   pretrain)
    DEV_BSIZE=10
    SAVE_FOLD=10

    DATA_VER=rwXKRZPsX8m3HFe
    START_POINT=bert-base-uncased
    TOK_CKPOINT=bert-tokenizer
    SHARDS_LIST=shards.txt
    EXTRA_DAT=mse-aops-2021-vocab.pkl
    EXTRA_ARG=
    ;;
   finetune)
    DEV_BSIZE=10
    SAVE_FOLD=2

    DATA_VER=2nXzW9m3jDY9H6m
    START_POINT=bert-pretrained-for-math
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    EXTRA_DAT=mse-aops-2021-data.pkl.tags.ids
    EXTRA_ARG=
    ;;
   colbert)
    DEV_BSIZE=6
    SAVE_FOLD=10

    DATA_VER=dE8HMCdMW9PWFXw
    START_POINT=bert-finetuned-for-math
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    EXTRA_DAT=
    EXTRA_ARG=--active_fp16
    ;;
esac

#####################
#   Download Data
#####################
DATA_DIR=data.$DATA_VER
set -e
if [ ! -e $DATA_DIR ]; then
    tarball=`mktemp`
    wget https://vault.cs.uwaterloo.ca/s/$DATA_VER/download -O $tarball
    tar xzf $tarball --one-top-level=$DATA_DIR --strip-components 1
fi
set +e

#####################
#   Run SLURM Job
#####################
N_NODE=$(cat $0 | grep -Po '(?<=SBATCH --nodes=)[0-9]+')
N_GPUS=$(cat $0 | grep -Po '(?<=SBATCH --gres=gpu:)[0-9]+')

export NCCL_BLOCKING_WAIT=1  # Set this variable to use the NCCL backend
export SLURM_ACCOUNT=def-jimmylin
export SBATCH_ACCOUNT=$SLURM_ACCOUNT
export SALLOC_ACCOUNT=$SLURM_ACCOUNT

if which srun; then
    srun --unbuffered \
        python ./pya0/utils/transformer.py $TRAINER \
        $DATA_DIR/$START_POINT $DATA_DIR/$TOK_CKPOINT $DATA_DIR/$EXTRA_DAT \
        --shards_list $DATA_DIR/$SHARDS_LIST \
        --cluster tcp://$(hostname):8912 \
        --batch_size $(($N_NODE * $N_GPUS * $DEV_BSIZE)) \
        --save_fold $SAVE_FOLD --epochs $EPOCHS $EXTRA_ARG
else
    echo python ./pya0/utils/transformer.py $TRAINER \
    $DATA_DIR/$START_POINT $DATA_DIR/$TOK_CKPOINT $DATA_DIR/$EXTRA_DAT \
    --shards_list $DATA_DIR/$SHARDS_LIST --batch_size $DEV_BSIZE \
    --save_fold $SAVE_FOLD --epochs $EPOCHS $EXTRA_ARG
fi

# Other example usages
#srun python pytorch-test-v2.py tcp://$(hostname):8921
#salloc --nodes=1 --gres=gpu:1 --cpus-per-task=2 --time=0-01:10 --mem=32gb
#srun --jobid 12345 --pty bash
