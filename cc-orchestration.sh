#!/bin/bash
USER=w32zhong
PROJ=def-jimmylin

ping_host()
{
	NODE=${1-cedar}.computecanada.ca
	HOURS=${2-12}
	echo -e "\n \t\t\t $NODE \n"
	ssh $USER@$NODE 'bash -s' <<-EOF
	export SBATCH_ACCOUNT=$PROJ
	export SALLOC_ACCOUNT=$PROJ
	export PATH=\$PATH:/opt/software/slurm/bin

	echo "My current Running Tasks"
	squeue -u $USER

	h=${HOURS}
	curtime=\$(TZ=America/New_York date --iso-8601=hours)
	echo "Tasks of mine newer than \$h hours ago [now: \$curtime]"
	sacct -u $USER \
		--format=jobid,jobname%15,Submit,elapsed,state,exitcode,reqtres%60 \
		-S \$(date -d "\$h hours ago" +%D-%R)
	
	echo "Newly executing jobs [now: \$curtime]"
	sacct --allusers --state=running \
		--format=user,jobid,jobname,account,Submit%20,State,elapsed,reqtres%60 \
		| grep 'gpu\|-----\|ReqTRES'  | (head -3; echo; tail -10)

	echo '===== Cluster Stats ====='
	r=\$(squeue --noheader --states=running | grep gpu | wc -l)
	p=\$(squeue --noheader --states=pending | grep gpu | wc -l)
	echo "$USER@$NODE: around \$r running, \$p pending (GPU jobs)"
	sinfo -o "Nodes=%40N  CPU=%10c  MEM=%10m  GPU=%10G" | grep gpu
	EOF
}

ping_all_hosts()
{
	HOURS=${1-12}
	ping_host cedar $HOURS
	ping_host beluga $HOURS
	ping_host graham $HOURS
}

cancel_job()
{
	NODE=${1-cedar}.computecanada.ca
	JOB=${2}
	echo -e "\n \t\t\t $NODE \n"
	ssh $USER@$NODE 'bash -s' <<-EOF
	export SBATCH_ACCOUNT=$PROJ
	export SALLOC_ACCOUNT=$PROJ
	export PATH=\$PATH:/opt/software/slurm/bin

	if [ -n "$JOB" ]; then
		echo "Cancel $JOB ..."
		scancel $JOB
	else
		sacct -u $USER
		echo "Which job to cancel?"
	fi
	EOF
}

tail_log()
{
	NODE=${1-cedar}.computecanada.ca
	LOG=${2}
	PROJ=${3-/home/$USER/projects/rrg-jimmylin/w32zhong}
	ssh $USER@$NODE 'bash -s' <<-EOF
	cd $PROJ
	tail -n 50 -f job-$LOG*.out
	EOF
}

head_log()
{
	NODE=${1-cedar}.computecanada.ca
	LOG=${2}
	PROJ=${3-/home/$USER/projects/rrg-jimmylin/w32zhong}
	ssh $USER@$NODE 'bash -s' <<-EOF
	cd $PROJ
	head -50 job-$LOG*.out
	EOF
}

list_files()
{
	NODE=${1-cedar}.computecanada.ca
	PROJ=${2-/home/$USER/projects/rrg-jimmylin/w32zhong}
	ssh $USER@$NODE 'bash -s' <<-EOF
	set -x
	cd $PROJ
	ls -l
	EOF
}

cancel_job()
{
	NODE=${1-cedar}.computecanada.ca
	JOB_ID=${2-0}
	ssh $USER@$NODE 'bash -s' <<-EOF
	export PATH=\$PATH:/opt/software/slurm/bin
	scancel $JOB_ID
	EOF
}

list_jobs()
{
	NODE=${1-cedar}.computecanada.ca
	echo "$NODE"
	ssh $USER@$NODE 'bash -s' <<-EOF
	export PATH=\$PATH:/opt/software/slurm/bin
	squeue -u $USER
	EOF
}

list_all_jobs()
{
	list_jobs cedar
	list_jobs beluga
	list_jobs graham
}
