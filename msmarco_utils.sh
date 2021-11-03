QRELS=/home/w32zhong/projects/def-jimmylin/w32zhong/msmarco-passage-collection/qrels.all
COLLECTION=/project/6016715/w32zhong/msmarco-passage-collection/collection.tsv
EVAL='python /home/w32zhong/anserini/tools/scripts/msmarco/msmarco_passage_eval.py'
TOPICS=/project/6016715/w32zhong/msmarco-passage-collection/queries.*.tsv

function visualize_for_msmacrofile() {
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
		rank=$(echo $line | awk '{print $3}')
		echo -ne "$rank \t"
		cat $COLLECTION | grep "^$docid\\b"
		cat $QRELS | grep --color "$qid[[:blank:]]0[[:blank:]]$docid"
		echo '-----'
	done < $tmpfile
}

function visualize_for_trecfile() {
	qid=$1
	cat $TOPICS | grep "^$qid\\b"
	[ -z $2 ] && return;
	runfile=$2
	topk=${3-3}
	tmpfile=`mktemp`
	rank=1
	cat $runfile | grep "^$qid\\b" | sort -k4 -n | head -$topk > $tmpfile
	echo '-----'
	while read line; do
		docid=$(echo $line | awk '{print $3}')
		score=$(echo $line | awk '{print $5}')
		echo -ne "$rank \t $score \t"
		cat $COLLECTION | grep "^$docid\\b"
		cat $QRELS | grep --color "$qid[[:blank:]]0[[:blank:]]$docid"
		let 'rank=rank+1'
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
		cat $QRELS | sort -k 1,1 | uniq > $sorted_qrels
		join $run_qids $sorted_qrels > $subset_qrels
		wc -l $run_qids $sorted_qrels $subset_qrels
		$EVAL $subset_qrels $runfile
	;;

	stdeval)
		runfile=$2
		set -x
		$EVAL $QRELS $runfile
		set +x
	;;


	debug)
		visualize_for_msmacrofile $2 $3 $4
	;;

	debug-trec)
		visualize_for_trecfile $2 $3 $4
	;;

	query)
		qid=$2
		cat $TOPICS | grep "^$qid\\b"
	;;

	doc)
		docid=$2
		cat $COLLECTION | grep "^$docid\\b"
	;;

	convert)
		runfile=$2
		cat $runfile | awk '{print $1 "\t" $3 "\t" $4}' > $runfile.msmacro.run
	;;

	*)
		echo $QRELS
		echo $COLLECTION
		echo $TOPICS
	;;
esac
