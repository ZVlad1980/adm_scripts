#!/usr/bin/env bash

#./launch.sh --version PDH_LOGGERv0.2.4 -- PDH_LOGGER

#./launch.sh  --checkout PDH_LOGGER --targets "NODE" -- PDH_LOGGER

#LOGGER
#./launch.sh --git-local "/home/vzhuravov/projects/pdh/logger" --targets "PROD" --only-scripts -- PDH_LOGGER
#./launch.sh --git-local "/home/vzhuravov/projects/pdh/logger" --targets "PDEV" -- PDH_LOGGER

#GATEWAY
#./launch.sh --git-local "/home/vzhuravov/projects/pdh/gateway" --checkout PDH-733 --targets "QA" --only-scripts -- PDH_GATEWAY
#./launch.sh --git-local "/home/vzhuravov/projects/pdh/gateway" --checkout PDH-733 --targets "PDEV" -- PDH_GATEWAY

#PDH000
#./launch.sh --git-local "/home/vzhuravov/projects/pdh/pdh000" --checkout PDH000 --targets "PDEV" -- PDH000
#./launch.sh --git-local "/home/vzhuravov/projects/pdh/pdh000" --checkout PDH000 --targets "PDEV" --only-scripts -- PDH000
#./launch.sh --git-local "/home/vzhuravov/projects/pdh/pdh000" --checkout PDH000 --targets "DEV,QA,PERF,SIT,PPD,UAT" -- PDH000
#./launch.sh --git-local "/home/vzhuravov/projects/pdh/pdh000" --checkout PDH000 --targets "QA,DEV" -- PDH000

#PDH008 exception report generator
./launch.sh --git-local "/home/vzhuravov/projects/pdh/pdh008" --checkout PDH-472 --targets "PDEV" -- PDH008
#
#./launch.sh --checkout PDH-472 --targets "DEV" -- PDH008

#./launch.sh --git-local "/home/vzhuravov/projects/pdh/pdh008" --checkout PDH-472 --targets "QA" --only-scripts -- PDH008
#./launch.sh --git-local "/home/vzhuravov/projects/pdh/pdh008" --checkout PDH-472 --targets "DEV,QA" -- PDH008

#./launch.sh --git-local "/home/vzhuravov/projects/pdh/pdh803" --checkout PDH-803 --targets "DEV,PERF,SIT,PPD,UAT" --only-scripts -- PDH012
#./launch.sh --git-local "/home/vzhuravov/projects/pdh/pdh803" --checkout PDH-803 --targets "DEV,PERF,SIT,PPD,UAT,QA" -- PDH012
