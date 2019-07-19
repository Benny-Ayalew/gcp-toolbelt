<#
.SYNOPSIS
    Name: posh2gcs.ps1
    The purpose of this script is to invoke the gsutil command and sync the contents of a given folderon a windows file system to a Google Cloud bucket.
.DESCRIPTION
    This script will take a given local directory and transfer it a destination in a Google Cloud bucket
.PARAMETER $PathtoStagedData
    A source directory for data that is staged to be transferred to a Google Cloud bucket
.INPUTS
    Directory to copy
.OUTPUTS
    Log files stored at the desired location for $PathtoLogDir
.NOTES
    version: 0.3
    Author: bennya@google.com
    Creation Date: 2019-06-26
    Updated Date: 2019-07-18
    Purpose/Change: Unified logging for both md5 checksum manifest and transfer logs into a single file  
.EXAMPLE
  C:\pscode\sync2gcs.ps1 C:\filepush\Payload\20190629
#>

param ($PathtoStagedData)

#Step 0 set your paths to staged data and Google Cloud bucket locations

#$PathtoStagedData = 'C:\filepush\payload\*' #Change the value to match your environment - expects lowerst directory
$bucket = 'gs://bennya-xfer' #Change the value to match your environment

#Step 1 set your paths to where you wish to have log files created 

$PathtoLogDir = 'C:\filepush\logs\' #Change the value to match your environment
$cplog = 'gsutilcplog_'+ (Get-Date -Format "MM-dd-yyyy_hh_mm_ss")+'.txt' #get current system time and date for initial copy with gsutil

#use copy as it generates a single line per file copied from source to destination
gsutil -m -q cp -r -J -L $PathtoLogDir\$cplog $PathtoStagedData $bucket

#append a timestamp to mark completion of copy
Add-Content $PathtoLogDir\$cplog $("Copy completed at:"+ (Get-date -Format "MM-dd-yyyy_hh_mm_ss") )

#step 2 write End of Transmission marker file for use with automation signaling 
$eotdatetime = 'EndOfTransmission_' + (Get-Date -Format "MM-dd-yyyy_hh_mm_ss")+'.txt' #get current system time and date

New-Item $PathtoLogDir\$eotdatetime -ItemType file

#push logs to GCS
gsutil -q cp $PathtoLogDir\$cplog $bucket
gsutil -q cp $PathtoLogDir\$eotdatetime $bucket
