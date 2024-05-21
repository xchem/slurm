# slurm

> Scripts for running SLURM scripts on the STFC/IRIS HPC

## Connecting and running jobs

Assuming you have a three-letter FedID you can use the terminal (Unix, so WLS needs activating in Windows) to ssh in:

- `ssh ssh.diamond.ac.uk -l <your_FedId>` 
- `ssh cepheus-slurm.diamond.ac.uk`
 
From there you can submit jobs via Slurm job manager

## Recommended job constraints

Constraints for SLURM jobs can be specified in the header of the submission script, or from the command line.

- Partition: `partition=main` is CPU, while `partition=gpu` is GPU.
- gres: to get a A100 (ie. juicy 80GB of VRAM) node set `--gres=gpu:a100:4`

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
