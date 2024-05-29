#!/bin/bash

#SBATCH --job-name=install_conda
#SBATCH --ntasks=32

ROOT=$1
DIR=$2

if [ -z $ROOT ]; then
    echo 'Please pass ROOT directory'
    exit 2
fi

if [ -z $DIR ]; then
    echo 'Please pass CONDA directory'
    exit 2
fi

export DATA=/opt/xchem-fragalysis-2
export HOME=$DATA/$ROOT
export HOME2=$DATA/$ROOT
export CONDA_PREFIX=$HOME2/$DIR

export CONDA_ALWAYS_YES=yes

if ! [ -f $DATA/shared/Miniconda3-latest-Linux-x86_64.sh ]; then
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o $DATA/shared/Miniconda3-latest-Linux-x86_64.sh;
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh --output $DATA/shared/Miniconda3-latest-Linux-x86_64.sh;
fi;

rm -r $CONDA_PREFIX

if [ -f "$CONDA_PREFIX" ]; then
    echo 'Updating...'
    bash $DATA/shared/Miniconda3-latest-Linux-x86_64.sh -p $CONDA_PREFIX -b -u
else
    echo 'Installing...'
    bash $DATA/shared/Miniconda3-latest-Linux-x86_64.sh -p $CONDA_PREFIX -b
fi

source $CONDA_PREFIX/etc/profile.d/conda.sh
export PIP_NO_CACHE_DIR=1
export PIP_NO_USER=1
export PYTHONUSERBASE=$CONDA_PREFIX  # not /lib/python3.11/site-packages
$CONDA_PREFIX/bin/conda activate base
conda config --add channels conda-forge
conda env config vars set PYTHONUSERBASE=$CONDA_PREFIX

# https://mamba.readthedocs.io/en/latest/user_guide/troubleshooting.html#defaults-channels
# there is a problem with the solver with condaforge?
#conda install -y -c conda-forge conda-libmamba-solver
#conda config --set solver libmamba

echo '## Installing weird fixes for this month'
python -m pip install -q --upgrade pip
conda install expat libexpat
conda update -n base -y -c conda-forge -c defaults conda

echo '## Installing Jupyter stuff'
conda install -y -n base -c conda-forge distro nodejs sqlite jupyterlab jupyter_http_over_ws nb_conda_kernels
conda update -y -c conda-forge nodejs   # peace among worlds
# python -m pip install -q  jupyter_theme_editor

# install whatever you want here
echo '## Installing stuff via pip'
python -m pip install -q pandas plotly seaborn pillow pandas pandarallel pandera nglview pebble rdkit jupyterlab-spellchecker tabulate pyarrow;
echo '## Installing utilities'
conda install -y -n base -c conda-forge openssh nano;
conda install -y -n base -c conda-forge util-linux;
conda install -y -c conda-forge htop;
conda install -y -n base -c conda-forge openbabel plip git;
echo '## Installing genomics stuff'
conda install -y -n base -c conda-forge -c bioconda kalign2 hhsuite muscle mmseqs2;

echo '## Installing Fragmenstein and PyRosetta'
python -m pip install -q fragmenstein  pyrosetta_help
#python -m pip install -q $DATA/shared/pyrosetta-2023.27+release.e3ce6ea9faf-cp311-cp311-linux_x86_64.whl
# pip install -q https://levinthal:paradox@graylab.jhu.edu/download/PyRosetta4/archive/release/PyRosetta4.Release.python39.ubuntu.wheel/pyrosetta-2024.4+release.a56f3bb973-cp39-cp39-linux_x86_64.whl

pip install -q  https://levinthal:paradox@graylab.jhu.edu/download/PyRosetta4/archive/release/PyRosetta4.Release.python311.linux.wheel/pyrosetta-2024.8+release.717d2e8-cp311-cp311-linux_x86_64.whl

# python -m pip cache purge  # PIP_NO_CACHE_DIR conflict

# Maximum cuda is 11! Driver 510 does not accept 12.
echo '## Installing Cuda'
export CONDA_OVERRIDE_CUDA=${CONDA_OVERRIDE_CUDA:-11.6.2} 
conda install -y nvidia/label/cuda-$CONDA_OVERRIDE_CUDA::cuda \
                 nvidia/label/cuda-$CONDA_OVERRIDE_CUDA::cuda-toolkit \
                 nvidia/label/cuda-$CONDA_OVERRIDE_CUDA::cuda-tools \
                 nvidia/label/cuda-$CONDA_OVERRIDE_CUDA::cuda-command-line-tools \
                 nvidia/label/cuda-$CONDA_OVERRIDE_CUDA::cuda-nvrtc \
                 nvidia/label/cuda-$CONDA_OVERRIDE_CUDA::libcufile \
                 nvidia/label/cuda-$CONDA_OVERRIDE_CUDA::cuda-cudart-dev \
                 nvidia/label/cuda-$CONDA_OVERRIDE_CUDA::cuda-compiler \
                 nvidia/label/cuda-$CONDA_OVERRIDE_CUDA::cuda-cuobjdump \
                 nvidia/label/cuda-$CONDA_OVERRIDE_CUDA::cuda-cuxxfilt \
                 nvidia/label/cuda-$CONDA_OVERRIDE_CUDA::cuda-nvcc \
                 nvidia/label/cuda-$CONDA_OVERRIDE_CUDA::cuda-nvprune
conda install -y -c conda-forge gputil
conda install -y -c omnia -c conda-forge openmm openff-forcefields openff-toolkit openmmforcefields
conda install -y -c pytorch -c conda-forge pytorch pytorch-cuda=11.3 torchvision matplotlib pandas 
# For tensorflow-gpu do it in a new env and only via official pip. Too much drama.

conda clean -y -t;
conda clean -y -i;

# echo '## Creating  retro version for CentOS 7'
# CONDA_OVERRIDE_GLIBC=2.17 conda create -n glibc17 python=3.8;
# source $CONDA_PREFIX/etc/profile.d/conda.sh
# conda activate glibc17 # not base!


#chmod -R a+r $CONDA_PREFIX
#find $CONDA_PREFIX -type d -exec chmod 777 {} \;

# echo '## Clean up'
# conda clean -y -t;
# conda clean -y -i;
