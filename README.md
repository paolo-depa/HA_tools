# CRM Attribute Loop Script

This project contains a shell script that continuously runs the `crm_attribute` command and logs the start time, return value, and end time for each iteration.

## Features

- The script uses the hostname of the current machine as the node name.
- The attribute name is customizable.
- The lifetime of the attribute can be set to either "forever" or "reboot".
- The script can be configured to use the -G option with the `crm_attribute` command.
- The script can be configured to use the -VVVVVV option for verbose output with the `crm_attribute` command.
- The output can be logged to a file. If no file is specified, the output will be printed to the console.

## Usage

1. Replace the `attributeName` variable with your actual attribute name.
2. Set the `isPermanent`, `isGet`, and `isVerbose` variables as needed.
3. If you want to log the output to a file, set the `logFile` variable to the path of your log file.
4. Run the script.

## Example

```shellscript
./crmattribute_loop.sh