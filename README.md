# script-for-transiesta-run-for-older-version-siesta-4.0.2-and-before-
The complete script for transiesta run for the older vesion of siesta-4.0.2 and earlier. 
# ===========================================================#
# 	**** Script for electrode run ****        	             # 
#============================================================#
# Please follow the steps : 				                         #
# 1)make the electrode input file elec.fdf  for your system  #
# (don't change the name of file as  well as system name).   #
# It is expected that in ~/bin dir  the  binary/exe file of  #
# transiesta.						                                      #
# In presence of proper *.psf file for corresponding elements #
# run this script for electrode using command                 #
#	 $ sh elec_script.sh                                       #
# The calculation should complete in a few minutes and will  #
#  generate a elec.TSHS file.		        	                   #
# ===========================================================#
# 	**** Script for scat  and tbtrans run ****               # 
#============================================================#
# Please follow the steps : 				                         #
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
#  tbtrans run.	                                              #
#=============================================================#
