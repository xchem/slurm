# slurm

> Scripts for running SLURM scripts on the STFC/IRIS HPC

### Contents

- [Connecting to the cluster](#connecting-to-the-cluster)
- [Inspecting/monitoring the cluster](#inspectingmonitoring-the-cluster)
- [Submitting jobs](#submitting-jobs)
- [Recommended job constraints](#recommended-job-constraints)
- [Setting up conda](#setting-up-conda)
- [Running a Jupterlab server in a SLURM job](#running-a-jupterlab-server-in-a-slurm-job)
- [Shared software](#shared-software)
- [Singularity / CUDA driver headaches](#singularity--cuda-driver-headaches)
- [Links](#links)

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

### Using sq.sh

sq.sh from [MShTools](https://github.com/mwinokan/MShTools) combines many of the above commands into a more human readable format. To use it add the following to your login profile (e.g. `~/.bashrc_user`:

```
export MSHTOOLS=/opt/xchem-fragalysis-2/maxwin/MShTools
export PATH=$PATH:$MSHTOOLS
alias sq='sq.sh -u YOUR_FED_ID'
```

Then you can use the `sq` alias to monitor your running, pending, and previous jobs:

![Screenshot 2024-05-22 at 14 39 14](https://github.com/xchem/slurm/assets/36866506/0716f3fc-6867-4281-9526-c445dd05d893)

Other features at a glance

- `sq -i` list all the idle nodes
- `sq -q` list all the pending jobs (for all users)
- `sq -a` list all the jobs that are ending soon (if you are waiting for resources)
- `sq --hist '1 hour'` list all your jobs from the past hour (the time period can be changed at will, e.g. "3 months")
- `sq -j JOB_ID` see information about a specific job (most useful with active jobs)
- `sq -h` show a help screen

### Other MShTools scripts

You may also find the following scripts useful

- `sb.sh` A pretty wrapper for sbatch (suggested alias: `alias sb=sb.sh`)
- `jd.sh` Change to the job directory a job is running in (suggested alias: `alias jd='source jd.sh'`)

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

## Setting up conda

The install_conda.sh script in this repository can be submitted as a job to create a new conda environment with the following procedure:

### Create a working directory in /opt/xchem-fragalysis-2

If you don't have one already you should create a working directory for yourself within `/opt/xchem-fragalysis-2`:

```
mkdir /opt/xchem-fragalysis-2/YOUR_DIRECTORY_NAME
```

### Submit the install script

```
cd /opt/xchem-fragalysis-2/YOUR_DIRECTORY_NAME
sbatch /opt/xchem-fragalysis-2/maxwin/slurm/install_conda.sh YOUR_DIRECTORY_NAME YOUR_CONDA_DIRECTORY
```

N.B. `YOUR_CONDA_DIRECTORY` should be the directory name for your conda installation within YOUR_DIRECTORY_NAME.

**Warning: this script will overwrite an existing installation in YOUR_DIRECTORY_NAME/YOUR_CONDA_DIRECTORY so give it a new name to any existing installations!**

Monitor the status of the job with `squeue` or `sq.sh`, it will take about 20 minutes.

## Running a Jupterlab server in a SLURM job

Once you have a conda environment set up you can configure and then run a jupyterlab notebook server in a SLURM job that you can access via the browser on your local workstation.

The script for this is `notebook.sh` in this repository and is provided at `/opt/xchem-fragalysis-2/maxwin/slurm/notebook.sh` for convenience.  

### Configure jupyter

To configure the notebook server run the following:

```
sbatch /opt/xchem-fragalysis-2/maxwin/slurm/notebook.sh -p PORT -d YOUR_DIRECTORY_NAME -cd YOUR_CONDA_DIRECTORY -jc JUPYTER_CONFIG_DIR -js PASSWORD
```

- `PORT` is the port the notebook will be accessible on, **N.B. scientific computing has only whitelisted ports from 9500 to 9510.**
- `JUPYTER_CONFIG_DIR` will specify where the jupyter config is stored within `YOUR_DIRECTORY_NAME`, e.g. `jupyter_slurm`.
- `PASSWORD` will be the password for your jupyter notebook
- Run `bash /opt/xchem-fragalysis-2/maxwin/slurm/notebook.sh --help` For extra details on the CLI

This job will only take around ~10 seconds to complete.

### Run the jupyter notebook job

Similarly to launch the actual notebook server run the following:

```
sbatch /opt/xchem-fragalysis-2/maxwin/slurm/notebook.sh -p PORT -d YOUR_DIRECTORY_NAME -cd YOUR_CONDA_DIRECTORY -jc JUPYTER_CONFIG_DIR
```

N.B. the omission of the `-js` argument.

This will start a non-exclusive job with only one task/CPU on the main paritition. This can be customised, e.g.:

```
sbatch --exclusive --ntasks=30 --partition=gpu /opt/xchem-fragalysis-2/maxwin/slurm/notebook.sh -p PORT -d YOUR_DIRECTORY_NAME -cd YOUR_CONDA_DIRECTORY -jc JUPYTER_CONFIG_DIR
```

to request an exclusive job on one of the gpu nodes.

### Accessing the notebook job

Inspect the log file for the running job, and make note of the ip-address at the start of the log. Then from a new terminal on your local workstation:

```
ssh -L 8080:IP_ADDRESS:PORT cepheus-slurm.diamond.ac.uk
```

The above assumes that you have already set up your identityfile and proxyjump in your `.ssh/config`.

Once connected navigate to `localhost:8080` in your browser to access the notebook.

## Shared software
 
In `/opt/xchem-fragalysis-2/shared` folder are some stuff of use.
Stuff that expires yearly:
CSD licence is from richard.cooper@chem.ox.ac.uk (university licence), while Open-Eye is from John Chodera’s folk (ASAP) use only.

## Singularity / CUDA driver headaches

Traditionally there was need for Singularity and some major headaches. Now the compute nodes run Rocky Linux 8.9 (Green Obsidian) and Nvidia driver 550.54.15 with CUDA 12.4. This is the shiniest version. But if you are reading this in the _future_ remember `conda install cuda_compat` which makes any version of newer CUDA toolkits (up to the cuda_compat release) play nicely with older drivers (albeit spottily with CUDA 11, hence our past woes as a nightly driver version was installed in Dec 2022 that only liked CUDA 11.6).

## Links

- Jupyterlab notebook on a compute node [Matteo's blog post](https://www.blopig.com/blog/2023/10/ssh-the-boss-fight-level-jupyter-notebooks-from-compute-nodes/)
