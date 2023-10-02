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

function output()
{
    printf "\n\n[${G}?${N}]What path would you like to save the output file?
    ${G}EXAMPLE: /tmp/output.txt${N}\n\n"
    read -p '[?]Path to logfile? ' logfile
}

function sys_enum()
{       banner
    printf "\n[${G}+${N}]System Enumeration"
    printf "\n[${G}+${N}]Information that will be saved to a log file:

    1. User IDs, login history, & /etc/passwd 
    2. OS details, mounted disks, & kernel version
    3. Network information
    4. Cron job & process information
    5. System logs \n\n"

    read -p '[?]Proceed? Y/n: ' answer
    if [[ $answer == 'n' ]]; then
        main
    fi

    output

    echo "-----------" | tee -a $logfile
    echo "|B|E|V|I|P|" | tee -a $logfile
    echo "-----------" | tee -a $logfile
    echo "bootlegwifi" | tee -a $logfile
    echo "-----------" | tee -a $logfile

    printf "\n[+]Windows Key:\n" | tee -a $logfile
    strings /sys/firmware/acpi/tables/MSDM | tee -a $logfile 1>&2

    user=$(whoami) && printf "\n[+]Current User: $user" | tee -a $logfile
    printf "\n[+]User ID:" | tee -a $logfile
    id | tee -a $logfile 1>&2
    printf "\n" | tee -a $logfile

    sudoperms=$(echo '' | sudo -S -l -k 2>/dev/null)
    if [ "$sudoperms" ]; then
        printf "\n[+]Passwordless Sudo Permissions: $sudoperms\n" | tee -a $logfile
    fi
    printf "\n" | tee -a $logfile
    
    printf "[+]Other Users:\n" | tee -a $logfile
    cat /etc/passwd | tee -a $logfile 1>&2
    printf "\n" | tee -a $logfile
    cat /etc/shadow | tee -a $logfile 1>&2
    printf "\n" | tee -a $logfile
    last | tee -a $logfile 1>&2
    sleep 0.5 && clear 2>/dev/null

    printf "\n\n[+]OS Details:\n" | tee -a $logfile
    uname -a | tee -a $logfile 1>&2
    printf "\n" | tee -a $logfile
    dpkg -l linux-image-\* | grep ^ii | tee -a $logfile 1>&2 #debian
    pacman -Q | grep ^linux | tee -a $logfile 1>&2 #arch
    rpm -qa | grep -i kernel | tee -a $logfile 1>&2 #redhat/suse
    
    printf "\n\n[+]Mounted Disks:\n" | tee -a $logfile
    df -h | tee -a $logfile 1>&2
    sleep 0.5 && clear 2>/dev/null

    printf "\n\n[+]Network Information:\n" | tee -a $logfile
    ip -s a | tee -a $logfile 1>&2
    printf "\n" | tee -a $logfile
    arp -e | tee -a $logfile 1>&2
    printf "\n" | tee -a $logfile
    netstat -antp | tee -a $logfile 1>&2
    printf "\n" | tee -a $logfile
    nodes=&(lsof -i) && printf "\n[+]Nodes Listening: $nodes\n" | tee -a $logfile 1>&2
    printf "\n" | tee -a $logfile
    iptables -L | tee -a $logfile 1>&2
    ufw status verbose | tee -a $logfile 1>&2
    sleep 0.5 && clear 2>/dev/null

    printf "\n\n[+]Process Information:\n" | tee -a $logfile
    ps -df | tee -a $logfile 1>&2

    printf "\n\n[+]Cron Jobs:\n" | tee -a $logfile
    for cronuser in $(cat /etc/passwd | cut -f1 -d: ); do echo $cronuser; crontab -u $cronuser -l; done | tee -a $logfile 1>&2
    echo "[+]Daily:" | tee -a $logfile
    ls -al /etc/cron.daily/ | tee -a $logfile 1>&2
    echo "[+]Weekly:" | tee -a $logfile
    ls -al /etc/cron.weekly/ | tee -a $logfile 1>&2
    echo "[+]Monthly:" | tee -a $logfile
    ls -al /etc/cron.monthly/ | tee -a $logfile 1>&2
    sleep 0.5 && clear 2>/dev/null

    printf "\n[+]System Logs:\n" | tee -a $logfile
    find / -name "*.log" | tee -a $logfile 1>&2

    
    all_binaries

    printf "\n[!]Finished!\n\n" | tee -a $logfile
    sleep 1
    main
}

function common_binaries()
{   
    printf "\n[${G}+${N}]Commonly Installed Binaries: \n" | tee -a $logfile
    which curl 2>/dev/null | tee -a $logfile
    which gcc 2>/dev/null | tee -a $logfile
    which mknod 2>/dev/null | tee -a $logfile
    which netcat 2>/dev/null | tee -a $logfile
    which nmap 2>/dev/null | tee -a $logfile
    which perl 2>/dev/null | tee -a $logfile
    which python 2>/dev/null | tee -a $logfile
    which ssh 2>/dev/null | tee -a $logfile
    which tcpdump 2>/dev/null | tee -a $logfile
    which telnet 2>/dev/null | tee -a $logfile
    which wget 2>/dev/null | tee -a $logfile
}

function all_binaries()
{
    printf "\n[${G}+${N}]All Insatlled Binaries: \n" | tee -a $logfile
    ls -alh /usr/bin | tee -a $logfile 1>&2
    ls -alh /usr/local/bin | tee -a $logfile 1>&2
    ls -alh /opt/ | tee -a $logfile 1>&2
    sleep 0.5 && clear 2>/dev/null
}

function binaries()
{       banner
        common_binaries
        printf "\n[${R}!${N}]Would you like to save installed binaries to a log file? \n"
    read -p '[?]Proceed? Y/n/A(all binaries): ' saveanswer
    if [[ $saveanswer == 'y' ]]; then
        output
        common_binaries
        elif [[ $saveanswer == 'a' ]]; then
            output
            all_binaries
        else
            echo ""
    fi
    main
}

function user_passwords()
{       banner
    printf "\n[${G}?${N}]Would you like to look for username & passwords in clear text files and save them to an output file?\n[${G}+${N}]Currently will search .php .sql & .txt files\n\n"
    read -p '[?]Proceed? Y/n: ' answer
    if [[ $answer == 'n' ]]; then
        main
    else
        output

        printf "\n[+]PHP Files\n" | tee -a $logfile
        find / -name "*.php" -print0 | xargs -0 grep -i -n "var password" | tee -a $logfile 1>&2
        find / -name "*.php" -print0 | xargs -0 grep -i -n "var user" | tee -a $logfile 1>&2
        sleep 0.5 && clear 2>/dev/null
        
        printf "\n[+]SQL Files\n" | tee -a $logfile
        find / -name "*.sql" -print0 | xargs -0 grep -i -n "password" | tee -a $logfile 1>&2
        find / -name "*.sql" -print0 | xargs -0 grep -i -n "user" | tee -a $logfile 1>&2
        sleep 0.5 && clear 2>/dev/null
        
        printf "\n[+]SQL Files\n" | tee -a $logfile
        find / -name "*.txt" -print0 | xargs -0 grep -i -n "password" | tee -a $logfile 1>&2
        find / -name "*.txt" -print0 | xargs -0 grep -i -n "username" | tee -a $logfile 1>&2
        sleep 0.5 && clear 2>/dev/null
        main
    fi
    main
}

function main()
{       banner
    PS3='Choose an option: '
    options=("System Enumeration" "Installed Binaries" "User:Passwords" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "System Enumeration")
                sys_enum
                ;;
            "Installed Binaries")
                binaries
                ;;
            "User:Passwords")
                user_passwords
                ;;
            "Quit")
                exit 1
                ;;
            *) echo invalid option ;;
        esac
    done
}

main
