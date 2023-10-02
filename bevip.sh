#!/bin/bash

R='\033[0;31m'
G='\033[0;32m'
N='\033[0m'

function banner()
{   clear 2>/dev/null
    echo "    ___  _____   _________  "
    echo "   / _ )/ __/ | / /  _/ _ \ "
    echo "  / _  / _/ | |/ // // ___/ "
    echo " /____/___/ |___/___/_/(ico)"
    printf "BashEnumerationVulnerbilityIdentificationPrivildgeEscalationToolkit\n[${G}GITHUB:bootlegwifi${N}]\n"
}

function sys_enum()
{       banner
    printf "\n\n[${G}+${N}]System Enumeration"
    printf "\n[${G}+${N}]Information that will be enumerated:

    1. User IDs, login history, & /etc/passwd 
    2. OS details, mounted disks, & kernel version
    3. Network information
    4. Cron job & process information
    5. System logs \n\n"

    read -p '[?]Proceed? Y/n: ' choice
    if [[ $choice == 'n' ]]; then
        main
    fi

    printf "\n\n[${G}?${N}]What path would you like to save the output file?
    ${G}EXAMPLE: /tmp/output.txt${N}\n\n"
    read -p '[?]Path to logfile? ' logfile
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
