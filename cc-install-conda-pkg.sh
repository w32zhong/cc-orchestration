export PYTHONPATH=""
export PIP_CONFIG_FILE=""
#conda create --yes --name py38 python=3.7.10
#conda activate py38
conda install --yes pytorch cudatoolkit=11.1 -c pytorch # pytorch=1.10.0
pip install faiss-gpu==1.6.5
conda install --yes openjdk=11 -c conda-forge
pip install transformers==4.9.2
conda install --yes pandas scikit-learn tqdm
pip install pyjnius onnxruntime fire

## For faiss-gpu training, need a specific conda environment
#$ conda list | grep pytorch
#cpuonly                   1.0                           0    pytorch
#faiss-gpu                 1.4.0           py36_cuda8.0.61_1    pytorch
#pytorch                   1.10.0              py3.6_cpu_0    pytorch
# first: conda install -c pytorch faiss-gpu cudatoolkit=11.3
# final: conda install pytorch=1.10.0 cudatoolkit=11.3 -c pytorch
