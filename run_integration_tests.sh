#!/bin/sh

# Adapted from Prof. Edwards' test script for MicroC.

QL="compiler/qlc"
PASS=0
FAIL=0
# Time limit for operations
ulimit -t 100

globalerror=0
globallog=run_tests.log
rm -f $globallog
error=0

make all &> /dev/null

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

  Run $QL $1 "Test"  &&
  touch ${basename}-gen.out &&
  javac -classpath build/json-simple-1.1.1.jar:. Test.java &&
  java -classpath build/json-simple-1.1.1.jar:. Test > ${basename}-gen.out &&
  generatedfiles="$generatedfiles ${basename}-gen.out"
  Compare ${basename}-gen.out ${basename}-exp.out ${basename}.i.diff

  if [ $error -eq 0 ] ; then
    echo "OK"
    echo "###### SUCCESS" 1>&2
    rm ${basename}-gen.out
    rm ${basename}.i.diff
    let PASS+=1
  else
    echo "###### FAILED" 1>&2
    let FAIL+=1
    globalerror=$error
  fi

  rm Test.java
}

shift `expr $OPTIND - 1`

if [ $# -ge 1 ]
then
  files=$@
else
  files="tests/integration-*.ql"
fi

make all >& /dev/null

for file in $files
do
  Check $file 2>> $globallog
done

echo "Tests passed: $PASS. Tests failed: $FAIL."

exit $globalerror
