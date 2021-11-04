export PYTHONPATH=""
export PIP_CONFIG_FILE=""
#conda create --yes --name py38 python=3.8.11
#conda activate py38
conda install --yes pytorch=1.10.0 cudatoolkit=11.3 -c pytorch
pip install faiss-gpu==1.6.5
conda install --yes openjdk=11 -c conda-forge
pip install transformers==4.9.2
conda install --yes pandas scikit-learn tqdm
pip install pyjnius onnxruntime fire
