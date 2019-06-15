#url
#url="http://appsurify.dev.appsurify.com"
url=$1
#API Key
#apiKey="MTpEbzhXQThOaW14bHVQTVdZZXNBTTVLT0xhZ00"
apiKey=$2
#Project
#project="2"
project=$3
#Test Suite
#testsuite="1"
testsuite=$4
#get commit
commitId=$5
report=$6
#importtype="junit"



if [[ $reporttype == "directory" ]] ; then
    for fileName in `ls -1 $report*.xml`
        do
            echo "call api for $fileName" 
            import=`curl -X POST "$url/api/external/import/" -H 'content-type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW' -H "token: $apiKey" -F "file=@$fileName" -F 'project_name'="$project" -F 'test_suite_name'="$testsuite" -F 'type'=$importtype -F 'commit'=$commitId`
            echo "here 4"
            echo $import
            #get testrun id
            var=`echo $import | sed 's/\\\\\//\//g' | sed 's/[{}]//g' |tr "," "\n" | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' |  sed '10p;d' `
            echo $var
            if [[ $run_id == "" ]] ; then run_id=`echo $var | sed 's/test_run_id:/test_run\=/g' ` ; fi
            #print testrun name
            echo $run_id
        done ; fi

if [[ $reporttype == "file" ]] ; then
    import=`curl -X POST "$url/api/external/import/" -H 'content-type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW' -H "token: $apiKey" -F "file=@$report" -F 'project_name'="$project" -F 'test_suite_name'="$testsuite" -F 'type'=$importtype -F 'commit'=$commitId`
    echo $import
    #get testrun id
    var=`echo $import | sed 's/\\\\\//\//g' | sed 's/[{}]//g' |tr "," "\n" | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' |  sed '10p;d' `
    echo $var
    if [[ $run_id == "" ]] ; then run_id=`echo $var | sed 's/test_run_id:/test_run\=/g' ` ; fi
    #print testrun name
    echo $run_id ; fi


#import=`curl -X POST "$url/api/external/import/" -H 'content-type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW' -H "token: $apiKey" -F "file=@$report" -F 'project_name'="$project" -F 'test_suite_name'="$testsuite" -F 'type'=$importtype -F 'commit'=$commitId`
#echo $import
#get testrun id
#var=`echo $import | sed 's/\\\\\//\//g' | sed 's/[{}]//g' |tr "," "\n" | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' |  sed '10p;d' `#
#echo $var
#if [[ $run_id == "" ]] ; then run_id=`echo $var | sed 's/test_run_id:/test_run\=/g' ` ; fi
#print testrun name
#echo $run_id

	  
