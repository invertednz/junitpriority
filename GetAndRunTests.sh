
finalTestNames=""

delete_reports () {
if [[ $reporttype == "directory" ]] ; then directorToDelete=$report'*.xml' ; rm $directorToDelete ; fi
if [[ $reporttype == "file" ]] ; then rm $report ; fi
}

#./GetAndRunTests.sh: line 18: syntax error in conditional expression: unexpected token `;'
#./GetAndRunTests.sh: line 18: syntax error near `;'
#./GetAndRunTests.sh: line 18: `if [[ $reporttype == "directory"]] ; then rm '$report*.xml' ; fi'

execute_tests () {
echo "here 2"
if [[ $deletereports == "true" ]] ; then delete_reports ; fi
$startrun$1$endrun
echo $startrun$1$endrun
. ./PushResultsToAppsurify.sh #"$1" "$2" "$3" "$4" "$commitId" "$report"
}

get_tests () {
finalTestNames=""
json=`curl --header "token: $apiKey" "$url/api/external/prioritized-tests/?project_name=$project&priority=$1&full_name=$fullname&test_suite_name=$testsuite&commit=$commitId" | sed 's/\"//g'`
#echo $json
prop="name"
values=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' |tr "," "\n" | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop | sed 's/\[//g' | sed 's/\]//g' | sed 's/name://g' `
if [[ $json != *"name"* ]] ; then echo "No test found" ; values="" ; fi
return $values
}

#could do something smart where we check to see if these are medium and rerun to only rerun medium tests not high and medium
rerun_tests_execute () {
get_tests 5
count=0

for testName in $?; do count=$((count+1));  echo $count; if [ $(( $count % $maxtests )) -eq "0" ]; then count=0; finalTestNames=$finalTestNames`echo $testseparator$prefixtest$testName$postfixtest`; finalTestNames=`echo $finalTestNames | sed 's/,$//g'`; execute_tests $finalTestNames ; finalTestNames=""; elif [ count == 1 ];  then finalTestNames=$prefixtest$testName$postfixtest; else finalTestNames=$finalTestNames`echo $testseparator$prefixtest$testName$postfixtest`; fi;done
finalTestNames=`echo $finalTestNames | sed 's/,$//g'`
if [[ $finalTestNames != "" ]] ; then execute_tests $finalTestNames ; fi
}

rerun_tests () {
if [[ $rerun == "true" ]]; then 
    numruns=0;
    while [ $numruns -lt $maxrerun ]
    do
        rerun_tests_execute
        (( numruns++ ))
    done ; fi
}

failfast_tests () {
if [[ $failfast == "true" ]] ; then
    rerun_tests $1
    . ./GetResultsFromAppsurify.sh ; fi       
}


##try to be smarter and fail as soon as a group of tests has failed and be rerun, so add the reruns to here somehow?
get_and_run_tests () {
#get_tests $1



###################
#then echo $values
#if [[ $json != *"name"* ]] ; then echo "No test found" ; values="" ; fi
#for testName in $values; do count=$((count+1));  echo $count; if [ $(( $count % $maxtests )) -eq "0" ]; then finalTestNames=$finalTestNames`echo $starttests$testName,`; finalTestNames=`echo $finalTestNames | sed 's/,$//g'`; mvn -Dtest=$finalTestNames test ; finalTestNames=""; else finalTestNames=$finalTestNames`echo $starttests$testName,`; fi;done
#finalTestNames=`echo $finalTestNames | sed 's/,$//g'` ; fi
#if [[ $finalTestNames != "" ]] ; then mvn -Dtest=$finalTestNames test ; fi

count=0

#for testName in $?; do count=$((count+1));  echo $count; if [ $(( $count % $maxtests )) -eq "0" ]; then count=0; finalTestNames=$finalTestNames`echo $testseparator$prefixtest$testName$postfixtest`; finalTestNames=`echo $finalTestNames | sed 's/,$//g'`; execute_tests $finalTestNames ; failfast_tests ; finalTestNames=""; elif [ count == 1 ];  then finalTestNames=$prefixtest$testName$postfixtest; else finalTestNames=$finalTestNames`echo $testseparator$prefixtest$testName$postfixtest`; fi;done
#finalTestNames=`echo $finalTestNames | sed 's/,$//g'`
#if [[ $finalTestNames != "" ]] ; then execute_tests $finalTestNames ; failfast_tests ; fi
execute_tests "sample.junit.PriorityTest#Test1,sample.junit.PriorityTest#Test2"
}



#mvn test

###
#if tests == all just run tests
if [[ $teststorun == "all" ]] ; then execute_tests "" 0 ; fi

index=0
if [[ $teststorun == *high* ]] ; then testtypes[index]=1 ; ((index++)) ; fi
if [[ $teststorun == *medium* ]] ; then testtypes[index]=2 ; ((index++)) ; fi
if [[ $teststorun == *low* ]] ; then testtypes[index]=3 ; ((index++)) ; fi
if [[ $teststorun == *unassigned* ]] ; then testtypes[index]=4 ; ((index++)) ; fi
#if [[ $teststorun == *rerun* ]] ; then testtypes[index]=5 ; ((index++)) ; fi
if [[ $teststorun == *open* ]] ; then testtypes[index]=6 ; ((index++)) ; fi
if [[ $teststorun == *ready* ]] ; then testtypes[index]=7 ; ((index++)) ; fi


####start loop
for i in "${testtypes[@]}"
do
   echo "$i"
   get_and_run_tests $i
   
   

   # or do whatever with individual element of the array
done

if [[ $failfast == "false" && $rerun == "true" ]] ; then rerun_tests ; fi

. ./GetResultsFromAppsurify.sh #"$1" "$2" "$3" "$4" "$commitId" "$report"
#if not then get tests

#run tests

#push results

#if fail fast rerun tests

#check results and fail if fail fast

#####end loop

#check results

#run_id="this is the runid"


