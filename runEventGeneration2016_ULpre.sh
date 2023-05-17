#!/bin/bash
###########
# setup
export BASEDIR=`pwd`
############# inputs
export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
source $VO_CMS_SW_DIR/cmsset_default.sh
source inputs.sh

############# make a working area

echo " Start to work now"
pwd
mkdir -p ./work
cd    ./work
export WORKDIR=`pwd`

############## generate LHEs

RANDOMSEED=`od -vAn -N4 -tu4 < /dev/urandom`
RANDOMSEED=`echo $RANDOMSEED | rev | cut -c 3- | rev` #Sometimes the RANDOMSEED is too long for madgraph

#Run
TempNumber=${RANDOMSEED}
outfilename_tmp="$PROCESS"'_'"$RANDOMSEED"
outfilename="${outfilename_tmp//[[:space:]]/}"

echo $PROCESS
echo $dirname

#
#############
#############
# Generate GEN-SIM
export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_6_27/src ] ; then
 echo release CMSSW_10_6_27 already exists
else
scram p CMSSW CMSSW_10_6_27
fi
cd CMSSW_10_6_27/src
eval `scram runtime -sh`
mkdir -p Configuration/GenProduction/python/
cd Configuration/GenProduction/python/
cp ${BASEDIR}/input/${HADRONIZER} ./
echo  ${HADRONIZER}
echo ${TARBALL}
echo $PWD
cp ${BASEDIR}/input/${TARBALL} ./
sed -i "s@XY-Hadronzer_Path@$(pwd)@" ${HADRONIZER}
cd ../../../
scram b -j 8
cd ../../

# cmsDriver command
cmsDriver.py Configuration/GenProduction/python/${HADRONIZER} --python_filename ${outfilename}_gensim.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --fileout file:${outfilename}_gen.root --conditions 106X_mcRun2_asymptotic_preVFP_v8 --beamspot Realistic25ns13TeV2016Collision --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(212)" \\nprocess.RandomNumberGeneratorService.externalLHEProducer.initialSeed="int(${RANDOMSEED})" --step LHE,GEN --geometry DB:Extended --era Run2_2016_HIPM --no_exec --mc -n 2000


#Run
cmsRun ${outfilename}_gensim.py

#SIM Step
export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_6_17_patch1/src ] ; then
  echo release CMSSW_10_6_17_patch1 already exists
else
  scram p CMSSW CMSSW_10_6_17_patch1
fi
cd CMSSW_10_6_17_patch1/src
eval `scram runtime -sh`
scram b
cd ../..

# cmsDriver command
cmsDriver.py step2  --python_filename ${outfilename}_sim.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:${outfilename}_sim.root  --conditions 106X_mcRun2_asymptotic_preVFP_v8 --beamspot Realistic25ns13TeV2016Collision --step SIM --geometry DB:Extended --filein file:${outfilename}_gen.root --era Run2_2016_HIPM --runUnscheduled --no_exec --mc -n 9999


#Run
cmsRun ${outfilename}_sim.py

#DIGI (premix): 
#cmsDriver.py step3 --python_filename ${outfilename}_1_cfg.py --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI --fileout file:${outfilename}_step1.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL16_106X_mcRun2_asymptotic_v13-v1/PREMIX" --conditions 106X_mcRun2_asymptotic_preVFP_v8 --step DIGI,DATAMIX,L1,DIGI2RAW --procModifiers premix_stage2 --geometry DB:Extended --filein file:${outfilename}_sim.root --datamix PreMix --era Run2_2016_HIPM --runUnscheduled --no_exec --mc -n 9999

cmsDriver.py step3 --python_filename ${outfilename}_1_cfg.py --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI --fileout file:${outfilename}_step1.root --pileup_input '/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270000/3149A5A2-BDD9-054D-A0EF-530253E43D50.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270000/7700C7DF-CDE8-7643-BC44-8F7283413B29.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270000/DE3D95A3-9084-B64B-BE82-482850CBFD1E.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270001/311F67D3-59D0-564F-9521-3B573FDEFF81.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270001/68164B0F-B114-194D-A622-513712FBA58E.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270001/6C51D898-95B9-F144-9CDB-223AAB8EF030.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270002/71EEB940-2FB1-064C-9C8F-01DEB6B2F066.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270002/C522D070-D514-964D-82C3-90B5360FD715.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270002/C82C275D-2D0B-164C-939E-E579C9559E38.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270003/281CB497-B31B-B249-B368-3FE27E22EC9A.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270003/7CBFF413-FFD2-9145-B11A-65837A071F1D.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270003/993A637E-6C27-F040-9141-D211EC47FD75.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270004/5ED83328-08B9-C049-AE90-9F466EDA7DB3.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270004/EB3836AF-060A-3743-999D-88B8FFF4529F.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270006/0EDB3D3E-CA4D-1D4A-B112-065A9EC590E0.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270006/58873B9D-B97F-6545-9A3A-A5EA9071F647.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270007/6C49905B-C1F3-0848-B842-8C7A6EEA762F.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270008/29690C21-7840-9542-969D-AD77A5ACDCA3.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270008/5FE5DAC9-8F1C-1143-96B6-AA36AE4B7EB0.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270008/B0E480C1-B8A2-CB43-A2EC-BC2840A57F8F.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270009/04A75CE3-35E5-4847-9239-00349E84D137.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270009/3E1B7C07-6159-1C44-A7CF-1B657626367A.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270009/B2563770-80DD-7744-8521-88585F85324C.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270009/B7EF4824-27B0-2940-BE26-A5C38DD7FC46.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270009/CD4D6D46-CB25-B547-88C6-27C0C6A500D7.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270010/42232CD8-5AB1-6646-A602-9F06C60F5445.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270010/DF3519CB-4A09-F64F-891F-A3D2EF7B0A50.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270011/2A2FAF53-9AFE-7E44-877E-3ACC45F38D56.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270011/3E41F60B-9697-FF4B-B85F-FB6880089620.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270011/4A1F08F4-8995-BC4B-9ADE-8FE764D1D149.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270012/0C8E8664-2232-8948-80A6-B56A774C0E43.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270012/1D8E4C3D-915E-A645-8BE8-956F5B45323C.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270012/2E736932-5723-DF42-8CB1-2EBA8EC4489A.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270012/55A26A16-7155-874E-9DCB-B26C821EEB73.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270012/89385E0E-AD0B-CE4D-BB9E-6AFFDB14E5ED.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270012/F1AF5F56-BEB4-674B-8542-86C8C88362F6.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270013/10604A23-3C4B-344A-97D1-ECB26BE03D83.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270013/118D8EE8-C654-284B-8D83-1E115ED2DEBA.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270013/1E70561C-684E-0244-8955-6459BB0C13E9.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270013/23E872A7-373F-8649-9526-2BFE838BCFE5.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270013/46651D0E-2CBC-F747-85D0-129A73F78E8D.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270013/8CC0B129-EE10-A94F-83F8-E0A2A6FFF3AD.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270014/1FBFF0E5-BE08-4949-9885-9AD5F8157666.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270014/740F9147-3C7C-F04E-9087-F347F361B61E.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270015/D126F6E8-FD22-D74C-B220-1309C8438843.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270016/6B34B57D-A4A2-0E43-9256-61A775917CDA.root','/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/270016/C76AEBDE-F8D6-7F48-ADAD-55C89CA4B81B.root' --conditions 106X_mcRun2_asymptotic_preVFP_v8 --step DIGI,DATAMIX,L1,DIGI2RAW --procModifiers premix_stage2 --geometry DB:Extended --filein file:${outfilename}_sim.root --datamix PreMix --era Run2_2016_HIPM --runUnscheduled --no_exec --mc -n 9999






############
# Generate PreMIX

#cp ${BASEDIR}/input/pu_files2017UL.py .
#cp ${BASEDIR}/input/aod_template2017UL.py .
#sed -i 's/XX-GENSIM-XX/'${outfilename}'/g' aod_template2017UL.py
#sed -i 's/XX-AODFILE-XX/'${outfilename}'/g' aod_template2017UL.py
#mv aod_template2017UL.py ${outfilename}_1_cfg.py

cmsRun ${outfilename}_1_cfg.py


##############
#HLT 
echo "Starting  the HLT Step"
export SCRAM_ARCH=slc7_amd64_gcc530
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_8_0_33_UL/src ] ; then
 echo release CMSSW_8_0_33_UL already exists
else
scram p CMSSW CMSSW_8_0_33_UL
fi
cd CMSSW_8_0_33_UL/src
eval `scram runtime -sh`
scram b -j8
cd ../../


cmsDriver.py step4 --python_filename ${outfilename}_hlt_cfg.py --eventcontent RAWSIM --outputCommand "keep *_mix_*_*,keep *_genPUProtons_*_*" --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --inputCommands "keep *","drop *_*_BMTF_*","drop *PixelFEDChannel*_*_*_*" --fileout file:${outfilename}_HLT.root --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:25ns15e33_v4 --geometry DB:Extended --filein file:${outfilename}_step1.root --era Run2_2016 --no_exec --mc -n 99999

#Run
cmsRun ${outfilename}_hlt_cfg.py

###########
# Generate RECOAOD 
export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_6_17_patch1/src ] ; then
 echo release CMSSW_10_6_17_patch1 already exists
else
scram p CMSSW CMSSW_10_6_17_patch1
fi
cd CMSSW_10_6_17_patch1/src
eval `scram runtime -sh`
scram b -j8
cd ../../

cmsDriver.py step5  --python_filename ${outfilename}_reco_cfg.py --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:${outfilename}_RECO.root --conditions 106X_mcRun2_asymptotic_preVFP_v8 --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --filein file:${outfilename}_HLT.root --era Run2_2016_HIPM --runUnscheduled --no_exec --mc -n 9999



cmsRun ${outfilename}_reco_cfg.py

##########
#MiniAOD 
export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_6_25/src ] ; then
 echo release CMSSW_10_6_25 already exists
else
scram p CMSSW CMSSW_10_6_25
fi
cd CMSSW_10_6_25/src
eval `scram runtime -sh`
scram b -j8
cd ../../

cmsDriver.py step6 --python_filename ${outfilename}_miniaod_cfg.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:${outfilename}_miniaod.root --conditions 106X_mcRun2_asymptotic_preVFP_v11 --step PAT --procModifiers run2_miniAOD_UL --geometry DB:Extended --filein file:${outfilename}_RECO.root --era Run2_2016_HIPM --runUnscheduled --no_exec --mc -n 9999



#Run
cmsRun ${outfilename}_miniaod_cfg.py


###########
# Stage out #v1
echo "Copying the  MiniAOD  to KNU storage"
#xrdcp  ${outfilename}_miniaod.root  root://cmseos.fnal.gov//store/group/lpcmetx/mPhoton/${dirname}/${outfilename}_miniaod.root
xrdcp ${outfilename}_miniaod.root   root://cluster142.knu.ac.kr//store/user/sdogra/Znunugamma/2016HIPM/MC_${dirname}_${TempNumber}_miniaod.root
echo "Copy  DONE."
