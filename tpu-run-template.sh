#!/bin/bash
# https://cloud.google.com/tpu/docs/pytorch-quickstart-tpu-vm
#
# gcloud compute instances create msev2 --zone=europe-west4-a  --machine-type=n1-highmem-8  --image-family=torch-xla --image-project=ml-images  --boot-disk-size=200GB --scopes=https://www.googleapis.com/auth/cloud-platform
# gcloud compute ssh --zone=europe-west4-a msev2
# conda activate torch-xla-1.8.1
# git clone https://github.com/approach0/pya0.git
# pip3 install fire GPUtil transformers
# wget https://vault.cs.uwaterloo.ca/s/5t9N6wPtEn7pBrJ/download -O mse-aops-2021-vocab.pkl
# wget https://vault.cs.uwaterloo.ca/s/cmCEkdWomp2jwKP/download -O mse-aops-2021-data.pkl

python3 pya0/utils/transformer.py pretrain --batch_size 16 --save_fold 100 --epochs 3 --xla_cores 8
