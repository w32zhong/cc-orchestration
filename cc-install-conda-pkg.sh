export PYTHONPATH=""
export PIP_CONFIG_FILE=""
conda create --name base_pkg --file conda-requirements.txt -c huggingface -c conda-forge -c pytorch
pip install pyjnius onnxruntime fire
