#!/bin/bash

# Pulls Google map for @covidschoolsCA and @CovidEcoles, parses and 
# converts into tables for downstream use.

outRoot=~/Canada_COVID_tracker

# Masks4Canada Canada-wide school tracker
canadaMidFile=1blA_H3Hv5S9Ii_vyudgDk-j6SfJQil9S
# Quebec tracker
QCMidFile=1S-b-tmhKP1RQeMaIZslrR_hqApM-KERq

dt=`date +%y%m%d`
outDir=${outRoot}/export-${dt}
mkdir -p $outDir

logfile=${outDir}/nightly-build.log
touch $logfile

echo "******************************************************"
echo "Fetching Canada-wide map"
echo "******************************************************"
./setup_datatable.sh $outDir $canadaMidFile CanadaMap > $logfile

echo "******************************************************"
echo "Fetching Quebec map"
echo "******************************************************"
./setup_datatable_quebec2.sh $outDir $QCMidFile COVIDEcolesQuebec >> $logfile

echo "******************************************************" >> $logfile
echo " Merging" >> $logfile
echo "******************************************************" >> $logfile
Rscript mergeQC.R $dt >> $logfile

echo "******************************************************" >> $logfile
echo " Fetching CEQ annotation sheet" >> $logfile
echo "******************************************************" >> $logfile
Rscript fetchQCstats.R
echo "Cleaning" >> $logfile
Rscript qcStats.R

echo "******************************************************" >> $logfile
echo " Fetch auto-generated entries " >> $logfile
echo "******************************************************" >> $logfile
#dt2=`$(date +%Y-%m-%d -d "$(date) + 1 day")`
#baseURL=https://covidschoolboards.s3.ca-central-1.amazonaws.com
#tgtDir=/home/shraddhapai/Canada_COVID_tracker/AutoGen
#inFile=${baseURL}/Peel_${dt2}.csv
#wget $inFile
#mv Peel_${dt}.csv ${tgtDir}/.

echo "******************************************************" >> $logfile
echo " Final cleanup " >> $logfile
echo "******************************************************" >> $logfile
#Rscript cleanMapData.R >> $logfile
#### Call makePlots.R and schoolBoard.R after this.
###
