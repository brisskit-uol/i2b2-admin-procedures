#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Installs an Onyx project and uploads its meta data.
#
# Mandatory: the I2B2_ADMIN_PROCS_HOME environment variable to be set.
# Optional : the I2B2_ADMIN_PROCS_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the procedures' home.
#  
# Prerequisites: Settings within the directory I2B2_ADMIN_PROCS_HOME/config/DB_TYPE 
# You are advised to review these settings carefully.
#
# Some tailoring can be achieved via the defaults.sh script.
#
# Author: Jeff Lusted (jl99@leicester.ac.uk)
#-----------------------------------------------------------------------------------------------
source $I2B2_ADMIN_PROCS_HOME/bin/common/setenv.sh
source $I2B2_ADMIN_PROCS_HOME/bin/common/functions.sh

#
# Retrieve job-name into its variable...
JOB_NAME=$ONYX_ONLY_INSTALL

#
# It is possible to set your own procedures workspace.
# But if it doesn't exist, we create one for you within the procedures home...
if [ -z $I2B2_ADMIN_PROCS_WORKSPACE ]
then
	I2B2_ADMIN_PROCS_WORKSPACE=$I2B2_ADMIN_PROCS_HOME/work
fi

#
# Establish a log file for the job...
LOG_FILE=$I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME/$JOB_NAME

#
# If required, create a working directory for this job step.
WORK_DIR=$I2B2_ADMIN_PROCS_WORKSPACE/$JOB_NAME
if [ ! -d $WORK_DIR ]
then
	mkdir -p $WORK_DIR
	exit_if_bad $? "Failed to create working directory. $WORK_DIR"
fi

#------------------------------------------------
# Install the project
#------------------------------------------------
cd $I2B2_ADMIN_PROCS_HOME/bin/project-installs
./1-install-onyx-without-ontology.sh $JOB_NAME
./2-update-datasources.sh $JOB_NAME

#------------------------------------------------
# Install the project's ontology
#------------------------------------------------
cd $I2B2_ADMIN_PROCS_HOME/ontologies/onyx/ontology
mkdir $WORK_DIR/$REFINED_METADATA_DIRECTORY
cp -r * $WORK_DIR/$REFINED_METADATA_DIRECTORY

cd $I2B2_ADMIN_PROCS_HOME/ontologies/onyx/ontology-enums
mkdir $WORK_DIR/$REFINED_METADATA_ENUMS_DIRECTORY
cp -r * $WORK_DIR/$REFINED_METADATA_ENUMS_DIRECTORY

cd $I2B2_ADMIN_PROCS_HOME/bin/apps/onyx/ontology-prep
./6-xslt-refined-2ontcell.sh $JOB_NAME
./7-xslt-refined-2ontdim.sh $JOB_NAME
./8-xslt-refined-enum2ontcell.sh $JOB_NAME 
./9-xslt-refined-enum2ontdim.sh $JOB_NAME

cd $I2B2_ADMIN_PROCS_HOME/bin/apps/onyx/meta-upload 
./metadata-upload-sql.sh $JOB_NAME