#!/bin/bash

# This file (and the whole project) is under CECILL open source license
# For more information see file LICENSE
# Author: Alexandre Dey

/bin/pleiade-user-configurator.sh $@ > /home/pleiade_installer/client_configs/"$1"/config/user.cfg

/bin/tar -czf /home/pleiade_installer/client_configs/"$1"/config.tar.gz /home/pleiade_installer/client_configs/"$1"/config
