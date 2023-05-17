#!/bin/bash

export HOME=${PWD}

tar xvaf submit.tgz
cd submit
bash ./runEventGeneration2016_ULpost.sh
cd ${HOME}
rm -r submit/
exit 0
