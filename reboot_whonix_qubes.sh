#!/bin/bash

# This script is made to fix the issue that when suspending Qubes, Whonix VMs time is out of sync on resume and Whonix Gateway cannot connect to the Tor network (see https://www.whonix.org/wiki/Post_Install_Advice#Network_Time_Syncing). This script solves this by shutting down and restarting those qubes on suspend/resume. The script should be placed in /usr/lib/systemd/system-sleep/ with permissions 755.

# The {1} variable is set by systemd to indicate -pre or -post sleep state/ 
if [ "${1}" == "pre"]; then

    # Option 1: Read the dependant qubes from the error output of 'qvm-shutdown'. A bit ugly but less error prone.
    # qvm-shutdown sys-whonix |& sed -e s/'sys-whonix: Shutdown error: There are other VMs connected to this VM: '// -e s/','// > /tmp/whonix_qubes
    # Option 2: Read the dependant qubes from qvm-ls. This output should be correct, but if it is not the script will fail.
    qvm-ls | grep -E 'Running.*sys-whonix' | cut -d ' ' -f 1 > /tmp/whonix_qubes
    if [ -s /tmp/whonix_qubes ]
    then
        for i in $/tmp/whonix_qubes
        do
            qvm-shutdown $i
        done
    fi
    qvm-shutdown sys-whonix
elif [ "${1}" == "post"]; then
    if [ -s /tmp/whonix_qubes ]
    then
        for i in $/tmp/whonix_qubes
        do
            qvm-start $i
        done
        rm /tmp/whonix_qubes
    fi
fi
