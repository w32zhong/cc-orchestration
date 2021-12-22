n_running=$(squeue | grep '\bR\b' | wc -l)
echo total running: $n_running
squeue | grep -n `whoami`
