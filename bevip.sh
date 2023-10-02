#!/bin/bash

function banner()
{   clear 2>/dev/null
    printf "\n BEVIP - This program will enumerate linux system information and append it to a textfile.\n"
}

function sys_enum()
{       banner
    printf "\n\nSystem Enumeration"
    printf "\nInformation that will be enumerated:

    1. User IDs, login history, & /etc/passwd 
    2. OS details, mounted disks, & kernel version
    3. Network information
    4. Cron job & process information
    5. System logs \n\n"

    read -p 'Proceed? Y/n : ' choice
    if [[ $choice == 'n' ]]; then
        echo "Cancelled Enumeration"
        main
    fi

    printf "\n\nWhat path would you like to save the output file?\nEXAMPLE: /tmp/output.txt\n"
    read -p 'Path to logfile: ' logfile
    echo "-----------" | tee -a $logfile
    echo "|B|E|V|I|P|" | tee -a $logfile
    echo "-----------" | tee -a $logfile
    
    printf "\nUser IDs\n" | tee -a $logfile
    user=$(whoami) && printf "Current user: $user\n" | tee -a $logfile

    printf "Other Users:\n" | tee -a $logfile
    cat /etc/passwd | tee -a $logfile 1>&2
    printf "\n\n" | tee -a $logfile
    cat /etc/shadow | tee -a $logfile 1>&2
    printf "\n\n" | tee -a $logfile
    id | tee -a $logfile 1>&2
    printf "\n\n" | tee -a $logfile
    last | tee -a $logfile !>&2
    sleep 0.5 && clear 2>/dev/null

    printf "\n\nOS details, kernel version & mounted disks"
    printf "\nOS Details:\n" | tee -a $logfile
    uname -a | tee -a $logfile 1>&2
    printf "\nKernel Version:\n" | tee -a $logfile
    dpkg -l linux-image-\* | grep ^ii | tee -a $logfile 1>&2 #debian
    pacman -Q | grep ^linux | tee -a $logfile 1>&2 #arch
    rpm -qa | grep -i kernel | tee -a $logfile 1>&2 #redhat/suse
    printf "\n\nMounted Disks:" | tee -a $logfile
    df -h | tee -a $logfile 1>&2
    sleep 0.5 && clear 2>/dev/null

    printf "\nFinished!"
    sleep 1
    main
}


function main()
{       banner
    PS3='Choose an option: '
    options=("System Enumeration" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "System Enumeration")
                sys_enum
                ;;
            "Quit")
                exit 1
                ;;
            *) echo invalid option ;;
        esac
    done
}

main
