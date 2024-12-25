#!/bin/bash
# ===========================================================#
# 	**** Script for scat  and tbtrans run ****           # 
#============================================================#
# Please follow the steps : 				       #
# 1) modify this script file as per requirement of your      #
# (don't change the name of file as  well as system name).   #
# It is expected that in ~/bin dir  the  binary/exe file of  #
# transiesta and tbtrans. Make sure tbtrans must be compiled #
# in ~siesta-4.0.2/Util/TBTrans/ and linked with bin directory#
# In presence of proper *.psf file for corresponding elements #
# run this script for electrode using command                 #
#	 $ sh mlv_script_scat                                 #
# The calculation may take long time depending on size of     #
# system and number of nodes(in parallel run )  and will      #
#  generate a scat.TSHS file. and file for IV curve after     #
#  tbtrans run.		        	               #
# Author: Mohan L Verma, Computational Nanomaterial          #  
# Research lab, Department of Applied Physics,               #
#   Shri Shanakaracharya Technical Campus-Junwani            # 
# Bhilai(Chhattisgarh)  INDIA                                #
# Sept 29    ver: 0.1   year: 2014                           #
#============================================================#
cp ../Elec/elec.TSHS .   # copy TSHS file from step-1

mkdir cont   # read the comment at the end of this script.

for i in `seq -w 0.0 0.1 1.8`  
do


cp -r cont $i
cd $i
cp ../*.psf .
 

cat > scat.fdf <<EOF

SolutionMethod  Transiesta

 SystemName    scat                                                                                                                     
SystemLabel    scat

# ---------------------------------------------------------------------------
# Lattice
# ---------------------------------------------------------------------------

LatticeConstant             1.00 Ang

%block LatticeVectors
     5.438063      0.000000      0.000000
     0.000000     20.324000      0.000000
     0.000000      0.000000     15.242090
%endblock LatticeVectors

# ---------------------------------------------------------------------------
# Species and Atoms
# ---------------------------------------------------------------------------

NumberOfSpecies        3
NumberOfAtoms         14

%block ChemicalSpeciesLabel
  1   1  H
  2   6  C
  3  79  Au
%endblock ChemicalSpeciesLabel

# ---------------------------------------------------------------------------
# Atomic Coordinates
# ---------------------------------------------------------------------------

AtomicCoordinatesFormat Ang

%block AtomicCoordinatesAndAtomicSpecies
 3.08373	10.03502	1.32255	3
3.08373	10.05698	3.96754	3
2.71903	10.32400	6.19985	2
4.89503	10.21800	6.36985	1
0.54303	10.21300	6.36985	1
3.94103	10.20600	6.88885	2
1.49703	10.20400	6.88885	2
1.49703	10.11800	8.30485	2
3.94103	10.11900	8.30485	2
0.54303	10.10700	8.82385	1
4.89503	10.11000	8.82485	1
2.71903	10.00000	8.99485	2
3.08373	10.03502	11.27455	3
3.08373	10.05698	13.91954	3
%endblock AtomicCoordinatesAndAtomicSpecies

# K-points

%block kgrid_Monkhorst_Pack
1   0   0   0.0
0   1   0   0.0
0   0   3  0.0
%endblock kgrid_Monkhorst_Pack

PAO.BasisSize    SZP
PAO.EnergyShift  0.005 Ry
==================================================
==================================================
# General variables

ElectronicTemperature  100 K 
MeshCutoff           350. Ry
xc.functional         LDA           # Exchange-correlation functional
xc.authors            CA 
SpinPolarized .false.
SolutionMethod Transiesta 

==================================================
==================================================
# SCF variables

DM.MixSCF1   T
MaxSCFIterations      300           # Maximum number of SCF iter
DM.MixingWeight       0.03          # New DM amount for next SCF cycle
DM.Tolerance          1.d-4         # Tolerance in maximum difference
DM.UseSaveDM          true          # to use continuation files
DM.NumberPulay         5
Diag.DivideAndConquer  no
Diag.ParallelOverK     yes

==================================================
==================================================
# MD variables

MD.FinalTimeStep 1
MD.TypeOfRun CG
MD.NumCGsteps     000
MD.UseSaveXV      .true.

==================================================
==================================================
# Output variables

WriteMullikenPop                1
WriteBands                      .false.
SaveRho                         true 
SaveDeltaRho                    .false.
SaveHS                          .false.
SaveElectrostaticPotential      True 
SaveTotalPotential              no
WriteCoorXmol                   .true.
WriteMDXmol                     .true.
WriteMDhistory                  .false.
WriteEigenvalues                yes

==================================================
==================================================
# Transmission 
TS.TBT.NPoints      101
TS.TBT.Emin        -3.0 eV
TS.TBT.Emax         3.0 eV

TS.TBT.NEigen              3

# Bias voltage
TS.Voltage 0.1 eV
TS.biasContour.NumPoints       10

# Transiesta: electrode definition:
# LEFT ELECTRODE
TS.HSFileLeft ./../Elec/elec.TSHS
TS.ReplicateA1Left    1
TS.ReplicateA2Left    1
TS.NumUsedAtomsLeft   2
TS.BufferAtomsLeft    0
# RIGHT ELECTRODE
TS.HSFileRight ./../Elec/elec.TSHS
TS.ReplicateA1Right   1
TS.ReplicateA2Right   1
TS.NumUsedAtomsRight  2
TS.BufferAtomsRight   0

# SPECIES AND ATOMS
# DYNAMICS
TS.UseBulkInElectrodes  T



EOF

mpirun -np 6 transiesta < scat.fdf | tee  scat.out 
mpirun -np 6 tbtrans < scat.fdf | tee tbt.out  #  &  # if you have more than 19 cpu-core, remove the first # on this line !
cat tbt.out | grep " Voltage, Current(A) =" | awk '{print $4"   "$5}' >> ../IV.dat

cat scat.AVTRANS

awk '{print $1"    "$2}' scat.AVTRANS >> EvsT.dat
awk '{print $1"   "$3}' scat.AVTRANS >> EvsTD.dat
awk '{print $1"   "$4}' scat.AVTRANS >> EvsPD.dat

mkdir data

cp *.dat ./data
cp scat.xyz ./data
cp scat.LDOS ./data
cp scat.RDOS ./data
cp scat.RHO ./data
cp scat.out ./data
cp tbt.out  ./data 


cd ..
rm -rf cont 
mkdir cont

cp  ./$i/scat.TSDE ./$i/scat.TSHS ./$i/scat.DM  cont  # copy these files for continuation of the next bias step.



done

xmgrace IV.dat &

