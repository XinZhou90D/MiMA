#!/bin/csh -f
#Minimal runscript for atmospheric dynamical cores
set echo 
#--------------------------------------------------------------------------------------------------------
# define variables
set platform  = nyu                                     # A unique identifier for your platform
set npes      = 16                                       # number of processors
set template  = $cwd/../bin/mkmf.template.$platform   # path to template for your platform
set mkmf      = $cwd/../bin/mkmf                      # path to executable mkmf
set sourcedir = $cwd/../src                           # path to directory containing model source code
set mppnccombine = $cwd/../bin/mppnccombine.$platform # path to executable mppnccombine
#--------------------------------------------------------------------------------------------------------
set execdir   = $cwd/exec.$platform       # where code is compiled and executable is created
set workdir   = $cwd/workdir              # where model is run and model output is produced
set pathnames = $cwd/path_names           # path to file containing list of source paths
set namelist  = $cwd/namelists            # path to namelist file
set diagtable = $cwd/diag_table           # path to diagnositics table
set fieldtable = $cwd/field_table         # path to field table (specifies tracers)
#--------------------------------------------------------------------------------------------------------
# compile mppnccombine.c, will be used only if $npes > 1
if ( ! -f $mppnccombine ) then
  icc -O -o $mppnccombine -I$NETCDF_INC -L$NETCDF_LIB $cwd/../postprocessing/mppnccombine.c -lnetcdf
endif
#--------------------------------------------------------------------------------------------------------
# setup directory structure
if ( ! -d $execdir ) mkdir $execdir
#if ( -e $workdir ) then
#  echo "ERROR: Existing workdir may contaminate run.  Move or remove $workdir and try again."
#  exit 1
#endif
#mkdir $workdir $workdir/INPUT $workdir/RESTART
#--------------------------------------------------------------------------------------------------------
# compile the model code and create executable
cd $execdir
$mkmf -p fms.x -t $template -c "-Duse_libMPI -Duse_netCDF" -a $sourcedir $pathnames /usr/local/include $NETCDF_INC $sourcedir/shared/mpp/include $sourcedir/shared/include
make -f Makefile -j $npes
#cd $workdir
#--------------------------------------------------------------------------------------------------------

# epg: I'll comment out the rest of the script, as we only want to compile the code

# set run length and time step, get input data and executable
#cat > input.nml <<EOF
# &main_nml
#     days   = 1,
#     dt_atmos = 1800 /
#EOF
#cat $namelist >> input.nml
#cp $diagtable diag_table
#cp $fieldtable field_table
#cp $execdir/fms.x fms.x
#--------------------------------------------------------------------------------------------------------
# run the model with mpirun
#mpirun -np $npes fms.x
#--------------------------------------------------------------------------------------------------------
# combine netcdf files
#if ( $npes > 1 ) then
#  foreach ncfile (`/bin/ls *.nc.0000`)
#    $mppnccombine $ncfile:r
#    if ($status == 0) rm -f $ncfile:r.????
#  end
#endif