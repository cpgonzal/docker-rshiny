#!/usr/bin/with-contenv bash

USER=${USER:=shiny}
PASSWORD=${PASSWORD:=shiny}
USERID=${USERID:=1000}
DATA_ROOT=${DATA_ROOT:=/data}
LIBS_ROOT=${LIBS_ROOT:=/libraries}

echo DATA_ROOT=$DATA_ROOT >> /etc/environment 
echo LIBS_ROOT=$LIBS_ROOT >> /etc/environment

#add R_LIBS variable to Renviron.site
echo "R_LIBS_USER='$LIBS_ROOT'" >> /usr/local/lib/R/etc/Renviron.site 
echo "R_LIBS=\${R_LIBS-'$LIBS_ROOT:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron.site 

if [ "$USERID" -lt 1000 ]
# Probably a macOS user, https://github.com/rocker-org/rocker/issues/205
  then
    echo "$USERID is less than 1000, setting minumum authorised user to 499"
    echo auth-minimum-user-id=499 >> /etc/rstudio/rserver.conf
fi

if [ "$USERID" -ne 1000 ]
## Configure user with a different USERID if requested.
  then
    echo "deleting user shiny"
    userdel shiny
    rm -rf /home/shiny
    echo "creating new $USER with UID $USERID"
    useradd -m $USER -u $USERID
    chown -R $USER /home/$USER
    usermod -a -G staff $USER
elif [ "$USER" != "shiny" ]
  then
    ## cannot move home folder when it's a shared volume, have to copy and change permissions instead
    cp -r /home/shiny /home/$USER
    ## RENAME the user   
    usermod -l $USER -d /home/$USER shiny
    groupmod -n $USER shiny
    usermod -a -G staff $USER
    chown -R $USER:$USER /home/$USER
    echo "USER is now $USER"  
fi

echo     "# Define the user we should use when spawning R Shiny processes " > /etc/shiny-server/shiny-server.conf
echo     "run_as shiny; " >> /etc/shiny-server/shiny-server.conf
echo     "# Define a top-level server which will listen on a port " >> /etc/shiny-server/shiny-server.conf
echo     "server { " >> /etc/shiny-server/shiny-server.conf
echo     "# Instruct this server to listen on port 80. The app at dokku-alt need expose PORT 80, or 500 e etc. See the docs " >> /etc/shiny-server/shiny-server.conf
echo     "listen 3838; " >> /etc/shiny-server/shiny-server.conf
echo     "# Define the location available at the base URL " >> /etc/shiny-server/shiny-server.conf
echo     "location / { " >> /etc/shiny-server/shiny-server.conf
echo     "# Run this location in 'site_dir' mode, which hosts the entire directory " >> /etc/shiny-server/shiny-server.conf
echo     "# tree at '$DATA_ROOT/shiny-server' " >> /etc/shiny-server/shiny-server.conf
echo     "site_dir $DATA_ROOT/shiny-server; " >> /etc/shiny-server/shiny-server.conf
echo     "# Define where we should put the log files for this location " >> /etc/shiny-server/shiny-server.conf
echo     "log_dir /var/log/shiny-server; " >> /etc/shiny-server/shiny-server.conf
echo     "# Should we list the contents of a (non-Shiny-App) directory when the user " >> /etc/shiny-server/shiny-server.conf
echo     "# visits the corresponding URL? " >> /etc/shiny-server/shiny-server.conf
echo     "directory_index on; " >> /etc/shiny-server/shiny-server.conf
echo     "  } " >> /etc/shiny-server/shiny-server.conf
echo     "}" >> /etc/shiny-server/shiny-server.conf

mkdir -p $DATA_ROOT/shiny-server

# Make sure the directory for individual app logs exists
mkdir -p /var/log/shiny-server
chown shiny.shiny /var/log/shiny-server
chown -R shiny.shiny $DATA_ROOT/shiny-server/

exec shiny-server >> /var/log/shiny-server/shiny-server.log 2>&1 &

