#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Please consult the project's README for further details.
#
# This script:
# (1) Invokes maven to do a (production) install to your local maven repository.
# (2) Sets up the lib directory suitable for testing.
# (3) Sets up the endorsed library suitable for testing.
# (4) Sets up the metadata sorting stylesheets
#
# In order not to store extraneous artifacts within SVN, the install is a two phase
# process, whereby the dependencies are first setup in the lib directory, before
# some being copied to the endorsed lib and the xslt directories.
#
# Please try NOT to commit lib, endorsed-lib and the metadata sorting stylesheets
# to SVN once they have been set up.
#
# Author: Jeff Lusted (jl99@leicester.ac.uk)
#-----------------------------------------------------------------------------------------------

#===========================================================================
# Clean up the lib, endorsed-lib and xslt directories
# (Only the metadata sorting stylesheets in the latter)
#===========================================================================
rm ./procedures/lib/* >/dev/null 2>/dev/null
rm ./procedures/endorsed-lib/* >/dev/null 2>/dev/null
rm ./procedures/xslt/sort*.xsl >/dev/null 2>/dev/null

#===========================================================================
# Do the 1st phase local install (production version) ...
#===========================================================================
mvn clean install

#===========================================================================
# Setup the lib directory suitable for testing ...
#===========================================================================
cd ./target
unzip ./i2b2-admin-procedures*.zip >/dev/null 2>/dev/null
rm ./i2b2-admin-procedures*.zip
cp ./i2b2-admin-procedures*/lib/* ../procedures/lib
rm -Rf ./i2b2-admin-procedures*
cd ..

#===========================================================================
# Setup the endorsed-lib directory for testing ...
#=========================================================================== 
cp ./procedures/lib/jaxb-api-x.x.jar ./procedures/endorsed-lib
cp ./procedures/lib/stax-api-1.0.1.jar ./procedures/endorsed-lib
cp ./procedures/lib/wstx-asl-3.0.1.jar ./procedures/endorsed-lib

#===========================================================================
# Setup the metadata sorting stylesheets required for a semantic compare...
#===========================================================================
mv ./procedures/lib/metadata-sorting-stylesheets-*.jar ./procedures/xslt/metadata-sorting-stylesheets.zip
cd ./procedures/xslt/
unzip -j metadata-sorting-stylesheets.zip xslt/sort*.xsl
rm metadata-sorting-stylesheets.zip
cd ../..

#===========================================================================
# Do the 2nd phase local install (development version) ...
#===========================================================================
mvn install

echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "===>Local production install complete."
echo "===>Please remember NOT to commit lib, endorsed-lib or sort metadata stylesheet artifacts to SVN."
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
