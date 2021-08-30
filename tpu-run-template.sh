#!/bin/bash
# https://cloud.google.com/tpu/docs/pytorch-quickstart-tpu-vm
#
# gcloud compute instances create math --zone=europe-west4-a  --machine-type=n1-highmem-2  --image-family=torch-xla --image-project=ml-images  --boot-disk-size=200GB --scopes=https://www.googleapis.com/auth/cloud-platform # 13GB memory, 2 vCPU
# gcloud compute ssh --zone=europe-west4-a math
#
# git clone https://github.com/approach0/pya0.git
#
# git clone https://github.com/t-k-/cc-orchestration.git
# chmod +x cc-orchestration/download-pretrain-sent-pairs.sh
# ./cc-orchestration/download-pretrain-sent-pairs.sh
#
# conda activate torch-xla-1.8.1
# pip3 install fire GPUtil transformers
# wget https://vault.cs.uwaterloo.ca/s/5t9N6wPtEn7pBrJ/download -O mse-aops-2021-vocab.pkl

conda activate torch-xla-1.8.1
export TPU_IP_ADDRESS=`gcloud compute tpus describe math --zone=europe-west4-a | grep -Po '(?<=ipAddress: ).*' | head -1` && echo $TPU_IP_ADDRESS
export XRT_TPU_CONFIG="tpu_worker;0;$TPU_IP_ADDRESS:8470"

sudo fallocate -l 20G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

gcloud compute operations list
# on a TPU-v3-8 (torch-1.8)
python3 pya0/utils/transformer.py pretrain \
	--batch_size $((8 * 16)) \
	--epochs 4 \
	--save_fold 50 \
	--xla_cores 8 \
	--shards_list data/shards.txt
