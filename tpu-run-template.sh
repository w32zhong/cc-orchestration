#!/bin/bash
# https://cloud.google.com/tpu/docs/pytorch-quickstart-tpu-vm
python pya0/utils/transformer.py pretrain --batch_size 2 --save_fold 100 --epochs 3 --xla
