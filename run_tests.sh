#!/bin/sh

# Adapted from Prof. Edwards' test script for MicroC.

QL="compiler/ql"
# Time limit for operations
ulimit -t 100

globalerror=0
globallog=run_tests.log
rm -f $globallog
error=0

SignalError() {
  if [ $error -eq 0 ] ; then
    echo "FAILED"
    error=1
  fi
  echo "  $1"
}

# Compare <outfile> <reffile> <difffile>
# Compares the outfile with reffile.  Differences, if any, written to difffile
Compare() {
  generatedfiles="$generatedfiles $3"
  echo diff -b $1 $2 ">" $3 1>&2
  diff -b "$1" "$2" > "$3" 2>&1 || {
    SignalError "$1 differs"
    echo "FAILED $1 differs from $2" 1>&2
  }
}

Run() {
  echo $* 1>&2
  eval $* || {
    SignalError "$1 failed on $*"
    return 1
  }
}

Check() {
  error=0

  # strip ".ql" off filename
  basename=`echo $1 | sed 's/.ql//'`

  echo "$basename..."

  echo 1>&2
  echo "###### Testing $basename" 1>&2

  Run $QL "<" $1 &&
  javac Test.java &&
  touch ${basename}-gen.out &&
  java Test > ${basename}-gen.out &&
  generatedfiles="$generatedfiles ${basename}-gen.out"
  Compare ${basename}-gen.out ${basename}-exp.out ${basename}.i.diff

  if [ $error -eq 0 ] ; then
    echo "OK"
    echo "###### SUCCESS" 1>&2
    rm ${basename}-gen.out
  else
    echo "###### FAILED" 1>&2
    globalerror=$error
  fi

  rm Test.java
}

shift `expr $OPTIND - 1`

if [ $# -ge 1 ]
then
  files=$@
else
  files="tests/test-*.ql"
fi

make all >& /dev/null

for file in $files
do
  Check $file 2>> $globallog
done

make clean >& /dev/null

exit $globalerror
