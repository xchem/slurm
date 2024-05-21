#!/bin/bash

# The submitter node is cepheus-slurm.diamond.ac.uk (cs05r-sc-cloud-30.diamond.ac.uk)
# cs05r-sc-cloud-29.diamond.ac.uk is for slurm testing
# wilson is something else?
# submit via `sbatch hello_world.slurm.sh`
# or modify `sbatch --partition=gpu --gres=gpu:1 --job-name=gputest ...`

#SBATCH --job-name=hello_world
#SBATCH --chdir=/opt/xchem-fragalysis-2/mferla
#SBATCH --output=/opt/xchem-fragalysis-2/mferla/slurm-error_%x_%j.log
#SBATCH --error=/opt/xchem-fragalysis-2/mferla/slurm-error_%x_%j.log
# gpu partition is `gpu`
#SBATCH --partition=main
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00

# extras
##SBATCH --nodes=1
##SBATCH --exclusive
##SBATCH --mem=<memory>
##SBATCH --mem-per-cpu=<memory>
##SBATCH --gres=gpu:1
##SBATCH --constraint=<constraint>
# this does nothing
#SBATCH --mail-type=END
#SBATCH --mail-user=matteo.ferla@stats.ox.ac.uk

# -------------------------------------------------------

export SUBMITTER_HOST=$HOST
export HOST=$( hostname )
export USER=${USER:-$(users)}
export HOME=$HOME
source /etc/os-release;

echo "Running $SLURM_JOB_NAME ($SLURM_JOB_ID) as $USER in $HOST which runs $PRETTY_NAME submitted from $SUBMITTER_HOST"
echo "Request had cpus=$SLURM_JOB_CPUS_PER_NODE mem=$SLURM_MEM_PER_NODE tasks=$SLURM_NTASKS jobID=$SLURM_JOB_ID partition=$SLURM_JOB_PARTITION jobName=$SLURM_JOB_NAME"
echo "Started at $SLURM_JOB_START_TIME"
echo "job_pid=$SLURM_TASK_PID job_gid=$SLURM_JOB_GID topology_addr=$SLURM_TOPOLOGY_ADDR home=$HOME cwd=$PWD"

# -------------------------------------------------------

# Place here whatever...

ls /opt/xchem-fragalysis-2

printenv

free -h

lscpu

df -h

nvidia-smi

# -------------------------------------------------------

echo 'complete'

exit 0