export PYTHONPATH=""
export PIP_CONFIG_FILE=""
#conda create --yes --name pyserini python=3.8.10
#conda activate pyserini

conda install --yes -c huggingface transformers
conda install --yes -c conda-forge faiss-gpu=1.6.5
conda install --yes pytorch=1.10.0 cudatoolkit=11.3 -c pytorch
conda install --yes openjdk=11 -c conda-forge
conda install --yes pandas tqdm
pip install pyjnius onnxruntime fire scikit-learn
