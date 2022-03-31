#!/bin/bash
#SBATCH --nodes=2           # total nodes
#SBATCH --gres=gpu:v100l:2  # how many GPUs per node
#SBATCH --cpus-per-task=2   # Cores proportional to GPUs: 6 on Cedar, 16 on Graham.
#SBATCH --mem=64gb          # Memory proportional to GPUs: 32000 Cedar, 64000 Graham.
#SBATCH --time=3-02:10      # days-hours:minutes
#SBATCH --output=job-%j-%N.out
set -x
date

#####################
#  Configuration
#####################
TRAINER=${1-pretrain}
SETUP=${2}
CODE_VER=$(test -e pya0 && cd pya0 && pwd && git rev-parse HEAD)
COMMAND="$0 $@"

EPOCHS=10
TEST_CYCLE=100
case $TRAINER-${SETUP} in
   pretrain-from-scratch)
    DEV_BSIZE=30
    SAVE_FOLD=1

    DATA_VER=arjmPWtGwzKrkmR
    START_POINT=bert-from-scratch
    TOK_CKPOINT=bert-tokenizer
    SHARDS_LIST=shards-for-scratch.txt
    TEST_FILE=test.txt
    CALL_ARGS="data.$DATA_VER/mse-aops-2021-vocab.pkl"
    #TRAINER_ARGS="--lr 1e-4"
    ;;

   pretrain-for-newvocab)
    DEV_BSIZE=30
    SAVE_FOLD=2

    DATA_VER=arjmPWtGwzKrkmR
    START_POINT=bert-base-uncased
    TOK_CKPOINT=bert-tokenizer
    SHARDS_LIST=shards-for-newvocab.txt
    TEST_FILE=test.txt
    CALL_ARGS="data.$DATA_VER/mse-aops-2021-vocab.pkl"
    TRAINER_ARGS=
    ;;

   finetune-from-base)
    DEV_BSIZE=8
    SAVE_FOLD=2

    DATA_VER=GceiSWS4TSYsySa
    START_POINT=bert-base-uncased
    TOK_CKPOINT=bert-tokenizer
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=200
    CALL_ARGS="data.$DATA_VER/mse-aops-2021-data.pkl.tags.ids"
    TRAINER_ARGS="--lr 5e-7"
    ;;

   finetune-from-pretrained)
    DEV_BSIZE=8
    SAVE_FOLD=2

    DATA_VER=GceiSWS4TSYsySa
    START_POINT=bert-pretrained-for-math-7ep/6_3_1382/
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=200
    CALL_ARGS="data.$DATA_VER/mse-aops-2021-data.pkl.tags.ids"
    TRAINER_ARGS="--lr 5e-7"
    ;;

   tag_prediction-direct)
    DEV_BSIZE=8
    SAVE_FOLD=2

    DATA_VER=aMGYy47dPPXbQm6
    START_POINT=bert-pretrained-for-math-7ep-3.5b/7-5-921
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=200
    CALL_ARGS="data.$DATA_VER/mse-aops-2021-data.pkl.tags.ids direct"
    TRAINER_ARGS="--lr 2e-6 --dev_map 2"
    #TRAINER_ARGS="--lr 2e-6 --dev_map 2 --debug"
    ;;

   tag_prediction-variational)
    DEV_BSIZE=25
    SAVE_FOLD=2

    DATA_VER=aMGYy47dPPXbQm6
    START_POINT=bert-pretrained-for-math-7ep-3.5b/7-5-921
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=200
    CALL_ARGS="data.$DATA_VER/mse-aops-2021-data.pkl.tags.ids variational"
    #TRAINER_ARGS="--lr 2e-5 --dev_map 2 --debug"
    TRAINER_ARGS="--lr 2e-5 --dev_map 2"
    ;;

   colbert-from-base)
    DEV_BSIZE=3
    SAVE_FOLD=10

    DATA_VER=LNE6tiZpJasCcyb
    START_POINT=bert-base-uncased
    TOK_CKPOINT=bert-tokenizer
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=300
    CALL_ARGS=
    TRAINER_ARGS=--active_fp16
    ;;

   colbert-on-narval-v2-128) # a100 (40GB)
    DEV_BSIZE=25
    SAVE_FOLD=1

    DATA_VER=kYsYFf5JbdbZFda
    START_POINT=bert-pretrained-for-math-7ep-3.5b/7-5-921/
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=200
    CALL_ARGS="128" # qmax
    TRAINER_ARGS=--active_fp16
    ;;

   colbert-on-narval-v3)
    EPOCHS=16
    DEV_BSIZE=20
    SAVE_FOLD=1

    DATA_VER=pHoLt8iLSrkD3XB
    START_POINT=bert-pretrained-for-math/7-5-921
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=300
    CALL_ARGS="512" # qmax
    TRAINER_ARGS=--active_fp16
    ;;

   colbert-on-v100-v3)
    EPOCHS=8
    DEV_BSIZE=8
    SAVE_FOLD=1

    DATA_VER=pHoLt8iLSrkD3XB
    START_POINT=bert-pretrained-for-math/7-5-921
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=300
    CALL_ARGS="512" # qmax
    TRAINER_ARGS=--active_fp16
    ;;

   dpr-on-basilisk-using-new-data-model)
    DEV_BSIZE=36
    SAVE_FOLD=1

    DATA_VER=kYsYFf5JbdbZFda
    START_POINT=bert-pretrained-for-math-7ep-3.5b/7-5-921/
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=300
    CALL_ARGS=
    TRAINER_ARGS='--dev_map 0,1 --cluster tcp://localhost:8912 --lr 3e-6'
    ;;

   dpr-on-narval-using-pretrained-model)
    DEV_BSIZE=16
    SAVE_FOLD=2

    DATA_VER=kYsYFf5JbdbZFda
    START_POINT=bert-pretrained-for-math-7ep-3.5b/7-5-921
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=200
    CALL_ARGS=
    TRAINER_ARGS=
    ;;

   dpr-on-narval-using-finetuned-model)
    DEV_BSIZE=16
    SAVE_FOLD=2

    DATA_VER=kYsYFf5JbdbZFda
    START_POINT=tag-predictor-8-6-7642
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=200
    CALL_ARGS=
    TRAINER_ARGS=
    ;;

   dpr-from-vanilla-backbone-v3-on-v100)
    EPOCHS=8
    DEV_BSIZE=8
    SAVE_FOLD=1

    DATA_VER=pHoLt8iLSrkD3XB
    START_POINT=bert-base-uncased
    TOK_CKPOINT=bert-tokenizer
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=300
    CALL_ARGS=
    TRAINER_ARGS='--lr 3e-6'
    ;;

   dpr-from-3ep-pretrained-v3-on-narval)
    EPOCHS=8
    DEV_BSIZE=14
    SAVE_FOLD=1

    DATA_VER=pHoLt8iLSrkD3XB
    START_POINT=bert-pretrained-for-math/3-1-0
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=300
    CALL_ARGS=
    TRAINER_ARGS='--lr 3e-6'
    ;;

   dpr-from-7ep-pretrained-v3-on-v100)
    EPOCHS=8
    DEV_BSIZE=8
    SAVE_FOLD=1

    DATA_VER=pHoLt8iLSrkD3XB
    START_POINT=bert-pretrained-for-math/7-5-921
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=300
    CALL_ARGS=
    TRAINER_ARGS='--lr 3e-6'
    ;;

   dpr-from-scibert-v3-on-narval)
    EPOCHS=8
    DEV_BSIZE=14
    SAVE_FOLD=1

    DATA_VER=pHoLt8iLSrkD3XB
    START_POINT=scibert_model
    TOK_CKPOINT=scibert_tokenizer
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=300
    CALL_ARGS=
    TRAINER_ARGS='--lr 3e-6'
    ;;

   dpr-from-azbert-v3-on-v100)
    EPOCHS=8
    DEV_BSIZE=8
    SAVE_FOLD=1

    DATA_VER=gqstFZmWHCLGXe3
    START_POINT=bert-pretrained-for-math-7ep/6_3_1382
    TOK_CKPOINT=bert-tokenizer-for-math
    SHARDS_LIST=shards.txt
    TEST_FILE=test.txt
    TEST_CYCLE=300
    CALL_ARGS=
    TRAINER_ARGS='--lr 3e-6'
    ;;

   *)
    echo "[Bad args] $COMMAND"
    exit 1;
    ;;
esac

######################################
#   Extract Slurm Header Arguments
######################################
N_NODE=$(cat $0 | grep -Po '(?<=SBATCH --nodes=)[0-9]+')
N_GPUS=$(cat $0 | grep -Po '(?<=SBATCH --gres=gpu:)[0-9]+')
if [ -z "$N_GPUS" ]; then
    N_GPUS=$(cat $0 | grep -Po '(?<=SBATCH --gres=gpu:).+:[0-9]+')
    N_GPUS=$(echo $N_GPUS | cut -f 2 -d':')
fi

if [ -z "$N_GPUS" -o -z "$N_NODE" ]; then
    echo "No value in: num_node=$N_NODE, num_gpu=$N_GPUS"
    exit 1
else
    echo "num_node=$N_NODE, num_gpu=$N_GPUS"
fi

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
export NCCL_BLOCKING_WAIT=1  # Set this variable to use the NCCL backend
export NCCL_IB_DISABLE=1
export NCCL_DEBUG=INFO
export NCCL_P2P_DISABLE=1

export SLURM_ACCOUNT=def-jimmylin
export SBATCH_ACCOUNT=$SLURM_ACCOUNT
export SALLOC_ACCOUNT=$SLURM_ACCOUNT

let TOTAL_N="$N_NODE * $N_GPUS"
if which srun && [ $TOTAL_N -gt 1 ]; then
    srun --unbuffered \
        python ./pya0/utils/transformer.py $TRAINER \
        $DATA_DIR/$START_POINT $DATA_DIR/$TOK_CKPOINT $CALL_ARGS \
        --test_file $DATA_DIR/$TEST_FILE --test_cycle $TEST_CYCLE \
        --shards_list $DATA_DIR/$SHARDS_LIST \
        --cluster tcp://$(hostname):8912 \
        --batch_size $(($TOTAL_N * $DEV_BSIZE)) \
        --save_fold $SAVE_FOLD --epochs $EPOCHS $TRAINER_ARGS
else
    python ./pya0/utils/transformer.py $TRAINER \
        $DATA_DIR/$START_POINT $DATA_DIR/$TOK_CKPOINT $CALL_ARGS \
        --test_file $DATA_DIR/$TEST_FILE --test_cycle $TEST_CYCLE \
        --shards_list $DATA_DIR/$SHARDS_LIST \
        --batch_size $DEV_BSIZE \
        --save_fold $SAVE_FOLD --epochs $EPOCHS $TRAINER_ARGS
fi;

# Other example usages
#salloc --nodes=1 --gres=gpu:1 --cpus-per-task=2 --time=0-01:10 --mem=32gb
#srun --jobid 12345 --pty bash
#
# git clone https://github.com/t-k-/cc-orchestration.git
# git clone https://github.com/approach0/pya0.git
# ln -s cc-orchestration/sbatch-template.sh sbatch.sh
# (cd pya0 && git pull) && (cd cc-orchestration && git pull)
