#!/bin/bash
# This script continuously executes the crm_attribute command, logging the start time, return value, and end time for each iteration.
# The nodeName is automatically set to the hostname of the current machine.
# The attributeName should be replaced with the actual attribute name you want to use.
# If isPermanent is set to 1, the attribute's lifetime is set to "forever". If it's set to 0, the lifetime is set to "reboot".
# If isGet is set to 1, the -G option is added to the crm_attribute command, which makes the command get the current value of the attribute.
# If isVerbose is set to 1, the -VVVVVV option is added to the crm_attribute command, which makes the command output verbose information.
# If isStrace is set to 1, the strace command is used to trace the system calls and signals made by the crm_attribute command.
# If isLogCompressed is set to 1, the log file is compressed using the compression utility specified by the compressionUtil variable.
# The output is logged to a file located in the directory specified by the logDir variable. The filename is generated based on the current date and time.
# If logDir is not a valid directory, it will be created.


nodeName=$(hostname)
attributeName="hana_wq1_roles" # replace with your actual attribute name
isPermanent=0
isGet=1
isVerbose=1
isStrace=1
isLogCompressed=1
compressionUtil="gzip"
compressionUtilParam="-1" # Balance compression and overhead on CPU
scriptName=$(basename $0)
logDir="/tmp/crmattribute_loop"

command="crm_attribute -N $nodeName -n $attributeName"

if [ $isLogCompressed -eq 1 ]
then
  if ! command -v $compressionUtil &> /dev/null
  then
    echo "$scriptName - Error: Compression utility '$compressionUtil' not found." >&2
    exit -1
  fi
fi

if [ ! -d $logDir ]
then
  mkdir -p $logDir
fi

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

  START_DATE=$(date +'%Y-%m-%dT%H:%M:%S.%3N')
  logFile="$logDir/$START_DATE.log"
  echo "$scriptName - Creating $logFile..."

  if [ $isStrace -eq 1 ]
  then
    strace -ff -tt -s 256 -T -o $logFile $command 1>/dev/null
  else
    echo "$scriptName - $START_DATE - Executing $command" >> $logFile
    $command >> $logFile 2>&1
    END_DATE=$(date +'%Y-%m-%dT%H:%M:%S.%3N')
    echo "$scriptName - $END_DATE: Return value: $?" >> $logFile
  fi

  if [ $isLogCompressed -eq 1 ]
  then
    $compressionUtil $compressionUtilParam $logFile*
  fi
 
  sleep 1
done