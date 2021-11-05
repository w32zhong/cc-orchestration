export PYTHONPATH=""
export PIP_CONFIG_FILE=""
#conda create --yes --name py38 python=3.7.10
#conda activate py38
conda install --yes pytorch=1.8.1 cudatoolkit=10.1 -c pytorch
pip install faiss-gpu==1.6.5
conda install --yes openjdk=11 -c conda-forge
pip install transformers==4.9.2
conda install --yes pandas scikit-learn tqdm
pip install pyjnius onnxruntime fire
