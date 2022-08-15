#!/bin/bash


first_sim="10.207.49.5"
second_sim="10.229.116.43"



test_file_existed(){
    file=$1
    if test -f "$file"; then
        #echo "$file exists."
        file_existed=1
    else
        #echo "$file is not existed."
        file_existed=0
    fi
    echo $file_existed
}

execute_command(){
    command=$1
    timeout=$2

    echo "execute command $1"
    eval $1
    ret=$?
    echo "ret=$ret"
    # if test -f "$file"; then
    #     echo "$file exists."
    #     file_existed=1
    # else
    #     echo "$file is not existed."
    #     file_existed=0
    # fi
    return $ret
}

parse_command_line(){
    line=$1
    #echo "input:"$line
    IFS=','
    read -ra arr <<< "$line"

    #echo "test""$ret"


    command_str="${arr[0]}"
    success_str="${arr[1]}"
    behavior_str="${arr[2]}"
    timeout_str="${arr[3]}"
    # echo "command_str:"$command_str
    # echo "success_str:"$success_str
    # echo "behavior_str:"$behavior_str
    # echo "timeout_str:"$timeout_str
    #echo $command_str $success_str $behavior_str $timeout_str
}

command_str=""
success_str=""
behavior_str=""
timeout_str=""

if [ ! -n "$1" ] ;then
    echo "Please input task list file name!"
    exit 1
fi

task_list_existed=$( test_file_existed $1 )
#test_file_existed $1
#task_list_existed=$?

if [[ $task_list_existed != 1 ]]; then
    echo "task list file $1 is not existed."
    exit 1
else
    :
    #echo "task list file $1 is existed."
fi

while IFS= read -r line
do
    old_ifs="$IFS"
    update_line=`echo $line | xargs echo -n`
    [[ $update_line = \#* ]] && continue
    [[ $update_line = "" ]] && continue
    echo "input string:""$update_line"
    #arr_ret=$(parse_command_line "$update_line")
    #echo "$arr_ret"
    parse_command_line "$update_line"

    echo "command_str:"$command_str
    echo "success_str:"$success_str
    echo "behavior_str:"$behavior_str
    echo "timeout_str:"$timeout_str

    echo ""
    #execute_command $command_str $success_str $behavior_str $timeout_str
    execute_command $command_str
    ret=$?
    echo "ret_out=$ret"

    if [[ $success_str == $ret || ($success_str == "" && $ret == 0) ]]; then
        echo "$command_str succeeded!"
    else
        echo "$command_str failed!"
    fi
    echo "=================================================================================="
    echo ""

    IFS="$old_ifs"

done < "$1"

exit 0


wait_starttime=$(date +%s)
image_ready=0
while [ $image_ready -eq 0 ]
do
    #check image is ready?
    sleep 2m
    FILE=/etc/resolv.conf
    if test -f "$image"; then
        echo "$image exists."
        image_ready=1
    else
        echo "$image is not ready."
    fi
done

wait_endtime=$(date +%s)
TIME_DIFF=$(( $wait_endtime - $wait_starttime ))
hours=$(( $TIME_DIFF / 3600 ))
wait_cost_str=" $(( $TIME_DIFF / 3600 )) hours $(( ($TIME_DIFF - $hours*3600) / 60 )) minutes $(( $TIME_DIFF % 60 )) seconds"
echo "wait cost time: $wait_cost_str"


if [ $image_ready -eq 1 ]; then
    #echo "$image"
    echo "Let's start to reinit: auto_install_upgrade.sh -a $ipaddress -i '$image' -p"

    reinit_starttime=$(date +%s)
    echo "auto_install_upgrade.sh -a $ipaddress -i '$image' -p"
    auto_install_upgrade.sh -a $ipaddress -i "$image" -p
    #sleep 1s
    reinit_endtime=$(date +%s)
    TIME_DIFF=$(( $reinit_endtime - $reinit_starttime ))
    hours=$(( $TIME_DIFF / 3600 ))
    reinit_cost_str="build time: $(( $TIME_DIFF / 3600 )) hours $(( ($TIME_DIFF - $hours*3600) / 60 )) minutes $(( $TIME_DIFF % 60 )) seconds"

    echo "Reinit finished: (auto_install_upgrade.sh -a $ipaddress -i '$image' -p), reinit cost time: $reinit_cost_str"

else
    echo "failed"
fi

time=$(date "+%Y-%m-%d %H:%M:%S")
echo "Finished at: $time, wait cost time: $wait_cost_str, reinit cost time: $reinit_cost_str"%   
