# slurm

> Scripts for running SLURM scripts on the STFC/IRIS HPC

## Connecting to the cluster

Assuming you have a three-letter FedID you can use the terminal (Unix, so WLS needs activating in Windows) to ssh in:

- `ssh ssh.diamond.ac.uk -l <your_FedId>` 
- `ssh cepheus-slurm.diamond.ac.uk`
 
From there you can submit jobs via Slurm job manager

## Inspecting/monitoring the cluster

- `sinfo` overview of partitions available and the state of their nodes
- `squeue` view the queue of RUNNING and PENDING jobs for all users
- `squeue -u USER -t STATE` view the queue for a USER with the given STATE
- `sacct -u USER` view the history for a given USER

## Submitting jobs

Jobs are submitted with the `sbatch` command

### Interactive jobs

Request an interactive bash session: `srun bash`

It will usually start immediately but it won't have a prompt so might look weird

### Running scripts

Job scripts need to start with the bash shebang: `#!/bin/bash`, and then include SLURM commands/directives prepended with `#SBATCH`.

## Recommended job constraints

Constraints for SLURM jobs can be specified in the header of the submission script with the prefix `#SBATCH`, or from the command line.

- job-name: name of the job
- chdir: root directory for the job (default is where `sbatch` was run from)
- output: path to file where STDOUT will be directed
- error: path to file where STDERR will be directed
- ntasks: number of tasks/threads for the job
- cpus-per-task: CPUs to assign to each task
- time: wall-time limit for the job
- nodes: number of nodes to request for the job
- exclusive: allow others to request/schedule unallocated resources on your node(s)
- mem: total memory to request
- mem-per-cpu: memory to request per CPU
- constraint: specify extra constraints on hardware
- mail-type: specify when to send an email
- mail-user: specify where to send the email to
- partition: `partition=main` is CPU, while `partition=gpu` is GPU.
- gres: to get a A100 (ie. 80GB of VRAM) node set `--gres=gpu:a100:4`

[SLURM cheatsheet](https://slurm.schedmd.com/pdfs/summary.pdf)
[SLURM homepage](https://slurm.schedmd.com/documentation.html)

## File systems
 
The “shared” drive (mounted CephFS) is mounted as `/opt/xchem-fragalysis-2`.
Someone such as godson.alex@diamond.ac.uk or christopher.reynolds@diamond.ac.uk will likely need to add your username to the extended permissions.

## Shared software
 
In ` opt/xchem-fragalysis-2/shared` folder are some stuff of use.
Stuff that expires yearly:
CSD licence is from richard.cooper@chem.ox.ac.uk (university licence), while Open-Eye is from John Chodera’s folk (ASAP) use only.

## Singularity / CUDA driver headaches

Traditionally there was need for Singularity and some major headaches. Now the compute nodes run Rocky Linux 8.9 (Green Obsidian) and Nvidia driver 550.54.15 with CUDA 12.4. This is the shiniest version. But if you are reading this in the _future_ remember `conda install cuda_compat` which makes any version of newer CUDA toolkits (up to the cuda_compat release) play nicely with older drivers (albeit spottily with CUDA 11, hence our past woes as a nightly driver version was installed in Dec 2022 that only liked CUDA 11.6).

## Links

- Jupyterlab notebook on a compute node [Matteo's blog post](https://www.blopig.com/blog/2023/10/ssh-the-boss-fight-level-jupyter-notebooks-from-compute-nodes/)
