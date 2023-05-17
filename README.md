# Running from Tarball

## Installation

1. Prepare your hadronizer including "externalLHEproducer" module and put into the `inputs/` folder

2. All gridpack in `inputs/` folder with .tar.xz will be packed at work directory.

3. Modify `submit_slc7.py`, determining where you want to store logs.
```
logpath='/uscmst1b_scratch/lpc1/3DayLifetime/jhong/mTop_log1'
```
And change the exec{year}.sh file, exec2018.sh/exec2017.sh/exec2016.sh/exec2016\_a.sh
```
executable = {0}/exec2018.sh
```

4. Submit the job. (Before submit, you can run in local at work directory by untarring the submit.tgz.)


## Run


```bash
bash monotop_buildInputs.sh year
python submit_slc7.py $work_directory $njobs
```



## Monotop UL 2016
2016 Generation is two version, pre-VFP and post-VFP
1. pre-VFP exec file
```
exec2016_A.sh
```
2. post-VFP exec file
```
exec2016.sh
```




