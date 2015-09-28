#!/bin/bash

ifile=$1
ofile=$2
soda_levels="5.01,15.07,25.28,35.76,46.61,57.98,70.02,82.92,96.92,112.32,129.49,148.96,171.4,197.79,229.48,268.46,317.65,381.39,465.91,579.31,729.35,918.37,1139.15,1378.57,1625.7,1875.11,2125.01,2375,2625,2875,3125,3375,3625,3875,4125,4375,4625,4875,5125,5375"

cmd="cdo intlevel,$soda_levels $ifile $ofile"
echo $cmd
$cmd