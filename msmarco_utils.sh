QRELS=/home/w32zhong/projects/def-jimmylin/w32zhong/msmarco-passage-collection/qrels.all
COLLECTION=/project/6016715/w32zhong/msmarco-passage-collection/collection.tsv
EVAL='python /home/w32zhong/anserini/tools/scripts/msmarco/msmarco_passage_eval.py'
TOPICS=/project/6016715/w32zhong/msmarco-passage-collection/queries.*.tsv

function visualize_query_and_hits() {
	qid=$1
	cat $TOPICS | grep "^$qid\\b"
	[ -z $2 ] && return;
	runfile=$2
	topk=${3-3}
	tmpfile=`mktemp`
	cat $runfile | grep "^$qid\\b" | sort -k3 -n | head -$topk > $tmpfile
	echo '-----'
	while read line; do
		docid=$(echo $line | awk '{print $2}')
		score=$(echo $line | awk '{print $3}')
		echo "score: $score"
		cat $COLLECTION | grep "^$docid\\b"
		cat $QRELS | grep --color "$qid[[:blank:]]0[[:blank:]]$docid"
		echo '-----'
	done < $tmpfile
}

case $1 in
	eval)
		runfile=$2
		run_qids=`mktemp`
		sorted_qrels=`mktemp`
		subset_qrels=`mktemp`
		cat $runfile | awk '{print $1}' | sort -u > $run_qids
		cat $QRELS | sort -k 1 | uniq > $sorted_qrels
		join $run_qids $sorted_qrels 2> /dev/null > $subset_qrels
		wc -l $sorted_qrels $run_qids $subset_qrels
		$EVAL $subset_qrels $runfile
	;;

	debug)
		visualize_query_and_hits $2 $3 $4
	;;

	*)
		echo "bad args. [eval or debug]"
	;;
esac
