export PYTHONPATH=""
export PIP_CONFIG_FILE=""
conda create --yes --name base_pkg python=3.8.11
conda activate base_pkg
conda install --yes pytorch=1.10.0 cudatoolkit=10.1.243 -c pytorch
conda install --yes faiss-gpu=1.6.5 -c conda-forge 
conda install --yes openjdk=11 -c conda-forge
conda install --yes pandas scikit-learn
pip install transformers==4.9.2
pip install pyjnius onnxruntime fire
