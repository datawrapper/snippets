#!/bin/bash


# take the query (or queries) from the makefile
QUERY=$1

# change start & end year here (2008 ist the last possible year in 2019)
START_YEAR="1930"
END_YEAR="2008"

echo "generating ngrams for $QUERY"


CORPORA=

# the corpora here
for CORPUS in eng_us_2012 eng_gb_2012 fre_2012 ger_2012 heb_2012 rus_2012 spa_2012
do
	# write one csv with each corpus with the ngram.py script
	python ngram.py "$QUERY" -caseInsensitive -noprint -startYear=$START_YEAR -endYear=$END_YEAR -corpus=$CORPUS

	# replace the column headers in the csv, change it from query content to corpus name 
	sed -i '' "s/$QUERY/$CORPUS/g" $CORPUS.csv
	#csvsql --query "select $CORPUS*1000000 AS $CORPUS-2 from '$CORPUS'" $CORPUS.csv
done

# use csvkit to join all the files together and put them in an own csv
csvjoin -c year *_2012.csv > "all-$QUERY.csv"

# delete all the individual corpora files
rm *_2012.csv