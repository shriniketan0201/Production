#!/bin/bash
export TARBALLDIR="/nfs_scratch/sacharya/Wgamma_Production/CMSSW_10_6_19/src/ForStudentrunTarBallMiniAODv2"

for FILE in inputs/*.tar.xz
do
    echo  $FILE
    PROCESS=$(echo ${FILE} | cut -d "/" -f 2 | sed 's/\_tarball.tar.xz//')
    echo ${PROCESS}
    export BASEDIR=${PWD}
    rm -r work${1}_${PROCESS}
    mkdir work${1}_${PROCESS}
    export SUBMIT_WORKDIR=${PWD}/work${1}_${PROCESS}
    year=${1}
    if [ ${year} -eq 2016 ]; then
        cp  inputs/SUS-RunIISummer20UL17wmLHEGEN-00041.py inputs/SUS-RunIISummer20UL17wmLHEGEN-00041_1.pyy
    fi
    if [ ${year} -eq 2017 ]; then
        cp  inputs/SUS-RunIISummer20UL17wmLHEGEN-00041.py inputs/SUS-RunIISummer20UL17wmLHEGEN-00041.py
    fi
    if [ ${year} -eq 2018 ]; then
        cp  inputs/SUS-RunIISummer20UL17wmLHEGEN-00041.py inputs/SUS-RunIISummer20UL17wmLHEGEN-00041_1.py
    fi
    sed -i "s/processname/${PROCESS}/"  inputs/${PROCESS}_hadronizer.py
    dirname_tmp=${PROCESS}
    dirname_tem=$(echo ${dirname_tmp} | cut -d "/" -f 2 | sed 's/\_slc7_amd64_gcc700_CMSSW_10_6_19//')
    echo $dirname_tem

    #dirname=$(echo ${dirname_tem} | cut -d "/" -f 2 | sed 's/Vector_MonoTop_NLO_//')
    dirname=$dirname_tem
    echo "Final Directory Name  :    " $dirname 

    #echo "TARBALL=${PROCESS}_tarball.tar.xz" > ./submit/inputs.sh
    echo "HADRONIZER=SUS-RunIISummer20UL17wmLHEGEN-00041.py  " >> ./submit/inputs.sh
    echo "PROCESS=${PROCESS}" >> ./submit/inputs.sh
    echo "dirname=${dirname}" >> ./submit/inputs.sh
    echo "USERNAME=${USER}" >> ./submit/inputs.sh    
    

    if [ -z "$2" ]
    then
	echo "MERGE=0" >> ./submit/inputs.sh
	echo "You want to produce events for $1. Good luck!"
    else
	echo "MERGE=1" >> ./submit/inputs.sh
	echo "You want to merge the T2 files for $1? Ok."
    fi
    
    
    if [ ${year} -eq 2016 ]; then
	mkdir -p ./submit/input/
	#cp ${TARBALLDIR}/inputs/${PROCESS}_tarball.tar.xz ./submit/input/
	cp ${TARBALLDIR}/inputs/${PROCESS}_hadronizer.py ./submit/input/
	cp ${BASEDIR}/exec2016HIPM.sh $SUBMIT_WORKDIR
	cp ${BASEDIR}/exec2016post.sh $SUBMIT_WORKDIR
    fi
    
    if [ ${year} -eq 2017 ]; then
	mkdir -p ./submit/input/
	#cp ${TARBALLDIR}/inputs/${PROCESS}_tarball.tar.xz ./submit/input/
	cp ${TARBALLDIR}/inputs/SUS-RunIISummer20UL17wmLHEGEN-00041.py ./submit/input/
	cp ${BASEDIR}/exec2017.sh $SUBMIT_WORKDIR
    fi
    
    if [ ${year} -eq 2018 ]; then
	mkdir -p ./submit/input/
	#cp ${TARBALLDIR}/inputs/${PROCESS}_tarball.tar.xz ./submit/input/
	cp ${TARBALLDIR}/inputs/${PROCESS}_hadronizer.py ./submit/input/
	cp ${BASEDIR}/exec2018.sh $SUBMIT_WORKDIR
    fi
    
    
    #creating tarball
    echo "Tarring up submit..."
    tar -chzf submit.tgz submit 
    rm -r ${BASEDIR}/submit/input/*
    
    mv submit.tgz $SUBMIT_WORKDIR
    
    rm -rf submit/inputs.sh
    #does everything look okay?
    ls -lh $SUBMIT_WORKDIR
done



