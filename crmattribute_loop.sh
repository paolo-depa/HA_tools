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
# usFrequency determines the frequency of command execution in microseconds. For example, 1000000 is 1 second and 250000 is 0.25 second.
# compressionUtilParam is the parameter passed to the compression utility to balance compression and overhead on CPU.
# logDir is the directory where the log files will be stored.
# logSuccessful determines whether to keep the log file when the command execution is successful. If it's set to 0, the successful log file will be discarded.


nodeName=$(hostname)
attributeName="hana_m05_roles" # replace with your actual attribute name
isPermanent=0
isGet=1
isVerbose=1
isStrace=1
isLogCompressed=1
#usFrequency=1000000 # 1 second
usFrequency=250000 # 0.25 second
compressionUtil="gzip"
compressionUtilParam="-1" # Balance compression and overhead on CPU
logDir="/tmp/crmattribute_loop"
logSuccessful=0

scriptName=$(basename $0)
command="crm_attribute -N $nodeName -n $attributeName"
logFilesCounter=0
echo "$scriptName - $logFilesCounter log files created so far."

if [[ $isLogCompressed -eq 1 ]]
then
  if ! command -v $compressionUtil &> /dev/null
  then
    echo "$scriptName - Error: Compression utility '$compressionUtil' not found." >&2
    exit -1
  fi
fi

if [[ ! -d $logDir ]]
then
  mkdir -p $logDir
fi

if [[ $isPermanent -eq 1 ]]
then
  command="$command -l forever"
else
  command="$command -l reboot"
fi

if [[ $isGet -eq 1 ]]
then
  command="$command -G"
fi

if [[ $isVerbose -eq 1 ]]
then
  command="$command -VVVVVV"
fi

while true
do

  START_DATE=$(date +'%Y-%m-%dT%H:%M:%S.%3N')
  logFile="$logDir/$START_DATE.log"

  if [[ $isStrace -eq 1 ]]
  then
    strace -ff -tt -s 256 -T -o $logFile $command 1> /dev/null 2>&1
    RETVAL=$?
  else
    echo "$scriptName - $START_DATE - Executing $command" >> $logFile
    $command >> $logFile 2>&1
    RETVAL=$?
    END_DATE=$(date +'%Y-%m-%dT%H:%M:%S.%3N')
    echo "$scriptName - $END_DATE: Return value: $?" >> $logFile
  fi
  
  if [[ $RETVAL -eq 0 && $logSuccessful -eq 0 ]]
  then
    rm $logFile*
    logFile=""
  else
    logFilesCounter=$((logFilesCounter+1))
    echo "$scriptName - Creating $logFile..."
    echo "$scriptName - $logFilesCounter log files created so far."
    if [[ $isLogCompressed -eq 1 ]]
    then
      $compressionUtil $compressionUtilParam $logFile*
    fi
 fi
  usleep $usFrequency
done
