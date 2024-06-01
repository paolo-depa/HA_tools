#!/bin/bash
# This script runs the crm_attribute command in a loop, printing the start time, return value, and end time for each iteration.
# The nodeName is set to the hostname of the current machine.
# The attributeName should be replaced with the actual attribute name.
# The lifetime is set to "reboot".
# If isGet is set to 1, the -G option is added to the crm_attribute command.
# The output is logged to a file specified by the logFile variable.
# If logFile is empty, the output will not be redirected and will only be printed to the console.

nodeName=$(hostname)
attributeName="hana_m05_roles" # replace with your actual attribute name
isPermanent=0
isGet=1
isVerbose=1
scriptName=$(basename $0)
logFile="/var/log/crmattribute_loop.log"
#logFile=""

command="crm_attribute -N $nodeName -n $attributeName"

if [ $isPermanent -eq 1 ]
then
  command="$command -l forever"
else
  command="$command -l reboot"
fi

if [ $isGet -eq 1 ]
then
  command="$command -G"
fi

if [ $isVerbose -eq 1 ]
then
  command="$command -VVVVVV"
fi

while true
do
  
  if [ -n "$logFile" ]
  then
    echo "$scriptName - $(date +'%Y-%m-%d %H:%M:%S.%3N') - Executing $command" >> $logFile
    $command >> $logFile 2>&1
    echo "$scriptName - $(date +'%Y-%m-%d %H:%M:%S.%3N'): Return value: $?" >> $logFile
  else
    echo "$scriptName - $(date +'%Y-%m-%d %H:%M:%S.%3N') - Executing $command"
    $command
    echo "$scriptName - $(date +'%Y-%m-%d %H:%M:%S.%3N'): Return value: $?"
  fi
  sleep 1
done