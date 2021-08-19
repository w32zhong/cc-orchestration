#!/bin/bash
USER=w32zhong
PROJ=def-jimmylin
set -e

ping_host()
{
	NODE=${1-cedar}.computecanada.ca
	HOURS=${2-12}
	echo -e "\n \t\t\t $NODE \n"
	ssh $USER@$NODE 'bash -s' <<-EOF
	export SBATCH_ACCOUNT=$PROJ
	export SALLOC_ACCOUNT=$PROJ
	export PATH=$PATH:/opt/software/slurm/bin

	h=${HOURS}
	echo "Tasks of mine newer than \$h hours ago [\$(TZ=America/New_York date)]"
	sacct -u $USER \
		--format=jobid,jobname%15,Submit,elapsed,state,exitcode,reqtres%60 \
		-S \$(date -d "\$h hours ago" +%D-%R)
	
	echo "New executing jobs [\$(TZ=America/New_York date --iso-8601=hours)]"
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

ping_host cedar
ping_host beluga
ping_host graham
