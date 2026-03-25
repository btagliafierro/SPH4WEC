#!/bin/bash 

fail () { 
 echo Execution aborted. 
 read -n1 -r -p "Press any key to continue..." key 
 exit 1 
}

# "name" and "dirout" are named according to the testcase

export case=$2
export name=$1${case}
export dirout=/media/bona/2b9dc0ec-7c7b-4634-b8ab-e8978fefe0f3/run/${name}_out
export diroutdata=${dirout}/data
export dirDataOutput=out_${name}

# "executables" are renamed and called from their directory

export dirbin=~/Downloads/DualSPHysics_v5.4.3/DualSPHysics_v5.4/bin/linux/
export dirbinPost=~/Downloads/DualSPHysics_v5.4.3/DualSPHysics_v5.4/bin/linux/
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${dirbin}
export gencase=~/Downloads/DualSPHysics_v5.4.3/DualSPHysics_v5.4/bin/linux/GenCase_linux64
export dualsphysicscpu="${dirbin}/DualSPHysics5.4CPU_linux64"
export dualsphysicsgpu="${dirbin}/DualSPHysics5.4_linux64"
export boundaryvtk="${dirbinPost}/BoundaryVTK_linux64"
export partvtk="${dirbinPost}/PartVTK_linux64"
export partvtkout="${dirbinPost}/PartVTKOut_linux64"
export measuretool="${dirbinPost}/MeasureTool_linux64"
export computeforces="${dirbinPost}/ComputeForces_linux64"
export isosurface="${dirbinPost}/IsoSurface_linux64"
export flowtool="${dirbinPost}/FlowTool_linux64"
export floatinginfo="${dirbinPost}/FloatingInfo_linux64"
export tracerparts="${dirbinPost}/TracerParts_linux64"

option=-1
 if [ -e $dirout ]; then
 while [ "$option" != 1 -a "$option" != 2 -a "$option" != 3 ] 
 do 

	echo -e "The folder "${dirout}" already exists. Choose an option.
  [1]- Delete it and continue.
  [2]- Execute post-processing.
  [3]- Abort and exit.
"
 read -n 1 option 
 done 
  else 
   option=1 
fi 

if [ $option -eq 1 ]; then
# "dirout" to store results is removed if it already exists
if [ -e ${dirout} ]; then rm -r ${dirout}; fi

# CODES are executed according the selected parameters of execution in this testcase

${gencase} ${name}_Def ${dirout}/${name} -save:all 
if [ $? -ne 0 ] ; then fail; fi

${dualsphysicsgpu} -gpu ${dirout}/${name} ${dirout} -dirdataout data -svres
if [ $? -ne 0 ] ; then fail; fi

fi

if [ $option -eq 2 -o $option -eq 1 ]; then
export dirout2=${dirout}/particles
#${partvtk} -dirin ${diroutdata} -savevtk ${dirout2}/PartFluid -onlytype:-all,+fluid -vars:+press -continue ##-saveenergy ${dirout}/fluidEnergy
if [ $? -ne 0 ] ; then fail; fi

# ${partvtk} -dirin ${diroutdata} -savevtk ${dirout2}/PartFloat -onlytype:-all,+floating,+fixed,+moving -vars:+press -continue
# if [ $? -ne 0 ] ; then fail; fi

# ${partvtkout} -dirin ${diroutdata} -savevtk ${dirout2}/PartFluidOut -SaveResume ${dirout2}/_ResumeFluidOut
# if [ $? -ne 0 ] ; then fail; fi

export dirout2=${dirout}/info
# ${computeforces} -dirin ${diroutdata} -onlymk:60 -savecsv ${dirout2}/force
${measuretool} -dirin ${diroutdata} -pointsdef:ptls[x=-5:1:10,y=0:0:1,z=-0.50:0.001:2000]  -onlytype:-all,+fluid -elevation -savecsv ${dirout2}/ #-savevtk ${dirout2}/wg1
${floatinginfo} -dirdatax ${diroutdata} -onlymk:10-800 -savedata ${dirout2}/

if [ -e $dirDataOutput ]; then rm -r $dirDataOutput; fi
mkdir $dirDataOutput
cp ${dirout2}/*.* ${dirDataOutput}/
cp ${dirout}/Gauges*.csv ${dirDataOutput}/
cp ${dirout}/Run.out ${dirDataOutput}/
cp ${dirout}/moordyn_data/*.csv ${dirDataOutput}/

export dirout2=${dirout}/animation
${boundaryvtk} -loadvtk AutoActual -motiondata ${diroutdata} -savevtkdata ${dirout2}/MotionFloating -onlytype:floating -savevtkdata ${dirout2}/Box.vtk

${isosurface} -dirin ${diroutdata} -saveiso ${dirout2}/Slices
if [ $? -ne 0 ] ; then fail; fi

fi
if [ $option != 3 ];then
 echo All done
 else
 echo Execution aborted
fi

read -n1 -r -p "Press any key to continue..." key
