#!/bin/bash

#this program takes output from admesh and makes a tidy TSV

#to run:

#bash admesh2tsv.bash <admesh output file> 

#bash admesh2tsv.bash admesh.out > admesh.tsv


#These lines grab the information from the admesh output
# grep '^Input file' test.out | sed 's/ //g' | sed 's/Inputfile://g'

# grep '^Min X' test.out |  sed 's/ //g' | sed 's/M[ai][nx]X=//g' | tr "," "\t"
# grep '^Min Y' test.out |  sed 's/ //g' | sed 's/M[ai][nx]Y=//g' | tr "," "\t"
# grep '^Min Z' test.out |  sed 's/ //g' | sed 's/M[ai][nx]Z=//g' | tr "," "\t"

# grep '^Number of facets' test.out |  sed 's/Number of facets  *: *//g' | sed 's/  */\t/g'

# grep 'Volume' test.out |  sed 's/Number of parts *:.*Volume *: *//g'
# grep 'Surface area' test.out |  sed 's/Degenerate facets *:.*Surface area *: *//g'


#this script will convert output from admesh to a tidy tab delimited table
INPUTFILE=$1
TIDYDATAFILE=$2
cat <(echo -e FileName'\t'MinX'\t'MaxX'\t'MinY'\t'MaxY'\t'MinZ'\t'MaxZ'\t'FacetsBefore'\t'FacetsAfter'\t'Volume'\t'SurfArea) \
<(\
paste -d '\t' <(grep '^Input file' $INPUTFILE | sed 's/ //g' | sed 's/Inputfile://g') \
  <(grep '^Min X' $INPUTFILE |  sed 's/ //g' | sed 's/M[ai][nx]X=//g' | tr "," "\t") \
  <(grep '^Min Y' $INPUTFILE |  sed 's/ //g' | sed 's/M[ai][nx]Y=//g' | tr "," "\t") \
  <(grep '^Min Z' $INPUTFILE |  sed 's/ //g' | sed 's/M[ai][nx]Z=//g' | tr "," "\t") \
  <(grep '^Number of facets' $INPUTFILE |  sed 's/Number of facets  *: *//g' | sed 's/  */\t/g') \
  <(grep 'Volume' $INPUTFILE |  sed 's/Number of parts *:.*Volume *: *//g') \
  <(grep 'Surface area' $INPUTFILE |  sed 's/Degenerate facets *:.*Surface area *: *//g')\
) 





