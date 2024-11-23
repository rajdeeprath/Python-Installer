#!/bin/bash

CYAN='\033[0;36m'
BOLD_GREEN="\033[1;32m"
RED="\e[0;31m"
BOLD_RED='\033[1;31m'
BLUE="\e[0;34m"
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD_YELLOW='\033[1;33m'
RESET="\033[0m"

echo ""
echo ""
echo -e ${YELLOW}"***********************************************************"${RESET}


# Copy config.ini to ${HOME} directory
if [ -f ${HOME}/.config.ini ];
then
    sudo rm -rf ${HOME}/.config.ini &> /dev/null
    sudo cp -vp ./config.ini ${HOME}/.config.ini &> /dev/null
else
    sudo cp -vp ./config.ini ${HOME}/.config.ini &> /dev/null
fi

# Load config.ini file
. ./config.ini

# add virtual venv path function
_add_paths(){
    if [ -f ${HOME}/.py_setup.sh ];
    then
        sudo rm -rf ${HOME}/.py_setup.sh &> /dev/null
    fi

    if hash python${PYSETENV_PYTHON_VERSION} 2> /dev/null;
    then
        echo -e ${BOLD_YELLOW}"[+] ${CYAN}Creating directory to hold all Python virtual environments"${RESET}
        mkdir -p $HOME/virtualenvs
        echo -e ${BOLD_YELLOW}"[*] ${CYAN}Configuring pysetenv"${RESET}

        sudo cp -vp ./py_setup.sh ${HOME}/.py_setup.sh
        sudo chmod +x ${HOME}/.py_setup.sh
        # curl -# https://raw.githubusercontent.com/connessionetech/python-installer/master/config.ini -o ${HOME}/.config.ini

        if [ -e "${HOME}/.zshrc" ];
        then
            echo -e ${BOLD_GREEN}"[+] ${CYAN}Adding py_setup to ${GREEN}~/.zshrc"${RESET}
            echo "source ~/.py_setup.sh" >> ${HOME}/.zshrc

        elif [ -e "${HOME}/.bashrc" ];
        then
            echo -e ${BOLD_GREEN}"[+] ${CYAN}Adding py_setup to ${GREEN}~/.bashrc"${RESET}
            echo -e "source ~/.py_setup.sh" >> ${HOME}/.bashrc

        elif [ -e "${HOME}/.bash_profile" ];
        then
            echo -e ${BOLD_GREEN}"[+] ${CYAN}Adding py_setup to ${GREEN}~/.bash_profile"${RESET}
            sudo echo -e "source ~/.py_setup.sh" >> ${HOME}/.bash_profile

        fi

        # installation complete
        echo -e ${BOLD_YELLOW}"[*] ${CYAN}Installation Completed Successfully!"

        # Usage Info
        echo -e "${GREEN} Type: ${BOLD_GREEN}source ~/.bashrc ${CYAN}to activate pysetenv or open a new terminal and start using pysetenv"
        echo -e "${GREEN} Usage: ${BOLD_GREEN}pysetenv --new VIRTUAL_ENVIRONMENT_NAME ${CYAN}to create new virtual environment"
        echo -e "${GREEN} Usage: ${BOLD_GREEN}pysetenv VIRTUAL_ENVIRONMENT_NAME ${CYAN}to activate the new virtual environment"
        echo -e "${YELLOW}***********************************************************${RESET}"
        echo ""
        echo ""
    else
        # install python if does not exist
        echo -e ${BOLD_RED}"[!!] ${RED}Python not installed on your System"
        _install
    fi
}


# Check os and install python function
_install(){
    if [ -f /etc/os-release ];
    then
        # Get Os details
        OS_NAME=$(cat /etc/os-release | grep -w NAME | cut -d= -f2 | tr -d '"')
        OS_VERSION=$(cat /etc/os-release | grep -w VERSION_ID | cut -d= -f2 | tr -d '"')
        DISTRO=$(cat /etc/os-release | grep -w ID_LIKE | cut -d= -f2 | tr -d '=')

        echo -e ${YELLOW}"[*] ${GREEN}Operating System:${BOLD_GREEN}" ${OS_NAME} ${GREEN}"Version: "${BOLD_GREEN}${OS_VERSION}${RESET}
        echo -e ${YELLOW}"[*] ${GREEN}Path to virtual environment directory:${BOLD_GREEN}" ${PYSETENV_VIRTUAL_DIR_PATH}${RESET}
        echo -e ${YELLOW}"[*] ${GREEN}Python Version On Config.ini:${BOLD_GREEN}" ${PYSETENV_PYTHON_VERSION}${RESET}

        # Add Python on RedHat 7
        if [[ "$OS_NAME" == *"Red Hat"* ]];
        then
        
        # install python from source
        echo -e ${YELLOW}
        read -p "install python${PYSETENV_PYTHON_VERSION} on the system (Y/N)" y_n
        echo -e ${RESET}
        case $y_n in
            Y|y)
                sudo yum install gcc openssl-devel bzip2-devel sqlite-devel -y
                cd /usr/src
                case $PYSETENV_PYTHON_VERSION in
                    "3.1")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.1.5/Python-3.1.5.tgz
                        ;;
                    "3.2")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.2.6/Python-3.2.6.tgz
                        ;;
                    "3.3")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.3.7/Python-3.3.7.tgz
                        ;;
                    "3.4")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.4.9/Python-3.4.9.tgz
                        ;;
                    "3.5")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.5.9/Python-3.5.9.tgz
                        ;;
                    "3.6")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.6.9/Python-3.6.9.tgz
                        ;;
                    "3.7")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz
                        ;;
                    "3.8")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.8.6/Python-3.8.6.tgz
                        ;;
                    "3.9")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz
                        ;;
                    *)
                        echo python version not found. please change version on config.ini
                        exit
                esac
                sudo yum install tar -y #install for RedHat 8
                sudo yum install make -y #install for RedHat 8
                sudo tar xzf python.tgz
                cd Python-3*
                sudo ./configure --enable-optimizations
                sudo make altinstall
                sudo rm /usr/src/python.tgz
                sudo rm -rf /usr/src/Python-3*
                cd ~
                python${PYSETENV_PYTHON_VERSION} -m pip install --upgrade pip --user
                python${PYSETENV_PYTHON_VERSION} -m pip install virtualenv --user
                _add_paths ;;

            N|n)
                echo -e ${BOLD_RED}"[!] ${RED}Aborting ! ! !"${RESET}
                echo ""
                exit ;;

            *)
                echo -e ${YELLOW}"[*] ${BOLD_YELLOW}Enter either Y|y for yes or N|n for no"
                echo ""${RESET}

                _install ;;

        esac
        fi


        # Add Python on CentOS 7
        if [[ "$OS_NAME" == *"CentOS"* ]];
        then
        
        # install python from source
        echo -e ${YELLOW}
        read -p "install python${PYSETENV_PYTHON_VERSION} on the system (Y/N)" y_n
        echo -e ${RESET}
        case $y_n in
            Y|y)
                sudo yum install gcc openssl-devel bzip2-devel sqlite-devel -y
                cd /usr/src
                case $PYSETENV_PYTHON_VERSION in
                    "3.1")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.1.5/Python-3.1.5.tgz
                        ;;
                    "3.2")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.2.6/Python-3.2.6.tgz
                        ;;
                    "3.3")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.3.7/Python-3.3.7.tgz
                        ;;
                    "3.4")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.4.9/Python-3.4.9.tgz
                        ;;
                    "3.5")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.5.9/Python-3.5.9.tgz
                        ;;
                    "3.6")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.6.9/Python-3.6.9.tgz
                        ;;
                    "3.7")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz
                        ;;
                    "3.8")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.8.6/Python-3.8.6.tgz
                        ;;
                    "3.9")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz
                        ;;
                    *)
                        echo python version not found. please change version on config.ini
                        exit
                esac
                yum install tar -y #install for CentOS 8
                yum install make -y #install for CentOS 8

                tar xzf python.tgz
                cd Python-3*
                ./configure --enable-optimizations
                make altinstall
                rm /usr/src/python.tgz
                rm -rf /usr/src/Python-3*
                cd ~
                python${PYSETENV_PYTHON_VERSION} -m pip install --upgrade pip
                python${PYSETENV_PYTHON_VERSION} -m pip install virtualenv
                _add_paths ;;

            N|n)
                echo -e ${BOLD_RED}"[!] ${RED}Aborting ! ! !"${RESET}
                echo ""
                exit ;;

            *)
                echo -e ${YELLOW}"[*] ${BOLD_YELLOW}Enter either Y|y for yes or N|n for no"
                echo ""${RESET}

                _install ;;

        esac
        fi


        # Add Python on Debian
        if [[ "${OS_NAME}" == *"Debian"* ]] ;
        then
            
            echo -e ${YELLOW}
            read -p "install python${PYSETENV_PYTHON_VERSION} on the system (Y/N)" y_n
            echo -e ${RESET}
            case $y_n in
                Y|y) 
                # make build-essential libssl-dev zlib1g-dev libbz2-dev libsqlite3-dev
                    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev
                    sudo apt-get install -y libbz2-dev libsqlite3-dev curl
                    # sudo apt-get install -y libncurses5-dev  libncursesw5-dev xz-utils tk-dev
                    cd /usr/src
                                
                    case $PYSETENV_PYTHON_VERSION in
                        "3.1")
                            sudo curl -o python.tgz https://www.python.org/ftp/python/3.1.5/Python-3.1.5.tgz
                            ;;
                        "3.2")
                            sudo curl -o python.tgz https://www.python.org/ftp/python/3.2.6/Python-3.2.6.tgz
                            ;;
                        "3.3")
                            sudo curl -o python.tgz https://www.python.org/ftp/python/3.3.7/Python-3.3.7.tgz
                            ;;
                        "3.4")
                            sudo curl -o python.tgz https://www.python.org/ftp/python/3.4.9/Python-3.4.9.tgz
                            ;;
                        "3.5")
                            sudo curl -o python.tgz https://www.python.org/ftp/python/3.5.9/Python-3.5.9.tgz
                            ;;
                        "3.6")
                            sudo curl -o python.tgz https://www.python.org/ftp/python/3.6.9/Python-3.6.9.tgz
                            ;;
                        "3.7")
                            sudo curl -o python.tgz https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz
                            ;;
                        "3.8")
                            sudo curl -o python.tgz https://www.python.org/ftp/python/3.8.6/Python-3.8.6.tgz
                            ;;
                        "3.9")
                            sudo curl -o python.tgz https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz
                            ;;


                        *) 
                            echo python version not found. please change version on config.ini
                            exit ;;
                    esac
                    sudo tar xzf python.tgz
                    cd Python-3*
                    sudo ./configure --enable-optimizations
                    sudo make altinstall
                    sudo rm /usr/src/python.tgz
                    sudo rm -rf /usr/src/Python-3*
                    cd ~
                    # sudo apt install python${PYSETENV_PYTHON_VERSION}-pip
                    sudo -H python${PYSETENV_PYTHON_VERSION} -m pip install --upgrade pip
                    sudo -H pip${PYSETENV_PYTHON_VERSION} install virtualenv
                    _add_paths
                        ;;
                N|n) 
                    echo -e ${BOLD_RED}"[!] ${RED}Aborting ! ! !"${RESET}
                    echo ""
                    exit ;;
                *) 
                    echo -e ${YELLOW}"[*] ${BOLD_YELLOW}Enter either Y|y for yes or N|n for no"
                    echo ""${RESET}
                    _install ;;
            esac
        fi
        

        # Add Python PPA on Ubuntu
        if [[ "$OS_NAME" == *"Ubuntu"* ]];
        then     
            
            echo -e ${YELLOW}
            read -p "install python${PYSETENV_PYTHON_VERSION} on the system (Y/N)" y_n
            echo -e ${RESET}
            case $y_n in
                Y|y) 
                    sudo apt-get update
                    sudo add-apt-repository ppa:deadsnakes/ppa -y
                    sudo apt-get update
                    sudo apt-get install -y python${PYSETENV_PYTHON_VERSION}
                    sudo apt-get install python${PYSETENV_PYTHON_VERSION}-distutils -y
                    sudo apt-get install python${PYSETENV_PYTHON_VERSION}-dev -y
                    # sudo apt-get install python${PYSETENV_PYTHON_VERSION}-venv -y
                    sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
                    sudo -H python${PYSETENV_PYTHON_VERSION} get-pip.py
                    sudo -H pip${PYSETENV_PYTHON_VERSION} install virtualenv
                    sudo apt-get autoremove -y
                    sudo rm -v get-pip.py
                    _add_paths ;;
                N|n) 
                    echo -e ${BOLD_RED}"[!] ${RED}Aborting ! ! !"${RESET}
                    echo ""
                    exit ;;
                *) 
                    echo -e ${YELLOW}"[*] ${BOLD_YELLOW}Enter either Y|y for yes or N|n for no"
                    echo ""${RESET}
                    _install ;;
            esac
        fi

    elif [ -f /etc/system-release ];
    then
        # Get Os details
        OS_NAME=$(cat /etc/system-release | cut -d ' ' -f1)
        OS_VERSION=$(cat /etc/system-release | cut -d ' ' -f3)

        echo -e ${YELLOW}"[*] ${GREEN}Operating System:${BOLD_GREEN}" ${OS_NAME} ${GREEN}"Version: "${BOLD_GREEN}${OS_VERSION}${RESET}
        echo -e ${YELLOW}"[*] ${GREEN}Path to virtual environment directory:${BOLD_GREEN}" ${PYSETENV_VIRTUAL_DIR_PATH}${RESET}
     
        echo ${YELLOW}
        read -p "install python${PYSETENV_PYTHON_VERSION} on the system (Y/N)" y_n
        echo ${RESET}
        case $y_n in
            Y|y)
                # add python on CentOs 6
                sudo yum install gcc openssl-devel bzip2-devel sqlite-devel -y
                cd /usr/src
                case $PYSETENV_PYTHON_VERSION in
                    "3.1")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.1.5/Python-3.1.5.tgz
                        ;;
                    "3.2")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.2.6/Python-3.2.6.tgz
                        ;;
                    "3.3")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.3.7/Python-3.3.7.tgz
                        ;;
                    "3.4")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.4.9/Python-3.4.9.tgz
                        ;;
                    "3.5")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.5.9/Python-3.5.9.tgz
                        ;;
                    "3.6")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.6.9/Python-3.6.9.tgz
                        ;;
                    "3.7")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz
                        ;;
                    "3.8")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.8.6/Python-3.8.6.tgz
                        ;;
                    "3.9")
                        sudo curl -o python.tgz https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz
                        ;;
                    *) 
                        echo python version not found. please change version on config.ini
                        exit ;;
                esac
                sudo tar xzf python.tgz
                cd Python-3*
                sudo ./configure --enable-optimizations
                sudo make altinstall
                sudo rm /usr/src/python.tgz
                sudo rm -rf /usr/src/Python-3*
                cd ~
                python${PYSETENV_PYTHON_VERSION} -m pip install --upgrade pip --user
                python${PYSETENV_PYTHON_VERSION} -m pip install virtualenv --user
                _add_paths
                    ;;

            N|n)
                echo -e ${BOLD_RED}"[!] ${RED}Aborting ! ! !"${RESET}
                echo ""
                exit ;;

            *)
                echo -e ${YELLOW}"[*] ${BOLD_YELLOW}Enter either Y|y for yes or N|n for no"
                echo ""${RESET}
                _install ;;

        esac
    else
        echo -e ${YELLOW}"Exiting ! ! !"${RESET}
        return 0
    fi
}


# install python version specified on config.ini
if hash python${PYSETENV_PYTHON_VERSION} 2> /dev/null;
    then
        echo -e ${BOLD_YELLOW}"[*] ${CYAN}Checking python version installed currently on the system..."${RESET}
        echo -e ${BOLD_YELLOW}"[*] "${BOLD_GREEN}"$(python${PYSETENV_PYTHON_VERSION} -V) ${GREEN} already installed on the system"${RESET}
        echo -e ${BOLD_YELLOW}"[*] ${GREEN}Python Path: "${BOLD_GREEN}$(which python${PYSETENV_PYTHON_VERSION}) ${RESET}
        _add_paths
    else
        # install python if does not exist
        _install
fi