# #!/usr/bin/env bash

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

# Load config.ini file
. ${HOME}/.config.ini

_pysetenv_help()
{
    # Echo usage message
    echo -e "" ${RESET}
    echo -e "${YELLOW}"Usage: pysetenv [OPTIONS] [NAME]
    echo -e "${BOLD_YELLOW}"EXAMPLE:
    echo -e "${BOLD_GREEN}"pysetenv -n foo       "${CYAN}"Create virtual environment with name foo
    echo -e "${BOLD_GREEN}"pysetenv foo          "${CYAN}"Activate foo virtual env.
    echo -e "${BOLD_GREEN}"pysetenv bar          "${CYAN}"Switch to bar virtual env.
    echo -e "${BOLD_GREEN}"deactivate            "${CYAN}"Deactivate current active virtual env.
    echo -e "${BOLD_YELLOW}"Optional Arguments:"${BLUE}"
    echo -l, --list                  List all virtual environments.
    echo -n, --new NAME              Create a new Python Virtual Environment.
    echo -r, --run NAME              Run existing project with pysetenv.
    echo -d, --delete NAME           Delete existing Python Virtual Environment.
    echo -e "" ${RESET}
    # echo -e -p, --python PATH        Python binary path.
    # echo -o, --open                  Load project to the activated virtual environment "${RESET}"
    # echo -e "${BOLD_YELLOW}"Load existing project:
    # echo -e "${BLUE}""-o, --open /path/to/project -e NAME Load existing project to""${RESET}"
}

# Creates new virtual environment if ran with -n | --new flag
_pysetenv_create()
{
    if [ -z ${1} ];
    then
        echo -e "${RED}"[!] ERROR!! Please pass virtual environment name!
        _pysetenv_help
    else
        echo -e "${BOLD_GREEN}[*] ${GREEN}Python version: ${BOLD_GREEN}${PYSETENV_PYTHON_VERSION}"
        echo -e "${BOLD_GREEN}[*] ${GREEN}Python Path: "${BOLD_GREEN}$(which python${PYSETENV_PYTHON_VERSION})
        echo -e "${BOLD_GREEN}[+] ${GREEN}Adding new virtual environment: $1 ${RESET}"

        if [ -d $PYSETENV_VIRTUAL_DIR_PATH/$1 ];
        # ovewrite virtual environment if it exist
        then
            echo -e ${YELLOW}
            read -p "[?] Overwrite ${1} virtual environment (Y / N)" yes_no
            echo -e ${YELLOW}
            case $yes_no in
                Y|y) 
                    
                    # check if os is debian or ubuntu we run python with sudo else run without
                    if [ -f /etc/os-release ];
                    then
                        OS_NAME=$(cat /etc/os-release | grep -w NAME | cut -d= -f2 | tr -d '"')
                        if [[ "${OS_NAME}" == *"Debian"* ]] || [[ "${OS_NAME}" == *"Ubuntu"* ]] ;
                        then
                            sudo -H python${PYSETENV_PYTHON_VERSION} -m virtualenv ${PYSETENV_VIRTUAL_DIR_PATH}${1}
                        else
                            python${PYSETENV_PYTHON_VERSION} -m virtualenv ${PYSETENV_VIRTUAL_DIR_PATH}${1}
                        fi
                    else
                        python${PYSETENV_PYTHON_VERSION} -m virtualenv ${PYSETENV_VIRTUAL_DIR_PATH}${1}
                    fi
                    echo -e "${BOLD_GREEN}[*] ${GREEN}Activate python virtual environment using this command: ${BOLD_GREEN}pysetenv ${1}${RESET}"
                    ;;
                N|n) 
                    echo -e "${BOLD_GREEN}[-] ${GREEN}Aborting environment creation!!"
                    return 0;;
                *) 
                    echo -e "${BOLD_GREEN}[?] ${GREEN}Enter either ${BOLD_GREEN}Y/y ${GREEN}for yes or ${BOLD_RED}N/n ${GREEN} for no"${RESET}
                    return 0;;
            esac
        else
            # create virtual environment if it does not exist
            if [ -f /etc/os-release ];
            then
                OS_NAME=$(cat /etc/os-release | grep -w NAME | cut -d= -f2 | tr -d '"')
                if [[ "${OS_NAME}" == *"Debian"* ]] || [[ "${OS_NAME}" == *"Ubuntu"* ]] ;
                then
                    sudo -H python${PYSETENV_PYTHON_VERSION} -m virtualenv ${PYSETENV_VIRTUAL_DIR_PATH}${1}
                else
                    python${PYSETENV_PYTHON_VERSION} -m virtualenv ${PYSETENV_VIRTUAL_DIR_PATH}${1}
                fi
            else
                python${PYSETENV_PYTHON_VERSION} -m virtualenv ${PYSETENV_VIRTUAL_DIR_PATH}${1}
            fi
            echo -e "${BOLD_GREEN}[*] ${GREEN}Python virtual environment with name: ${BOLD_GREEN}${1} ${GREEN}has been created${RESET}"
            echo -e "${BOLD_GREEN}[*] ${GREEN}Python virtual environment path: ${BOLD_GREEN}${PYSETENV_VIRTUAL_DIR_PATH}${1}${RESET}"
            echo -e "${BOLD_GREEN}[*] ${GREEN}Activate python virtual environment using this command: ${BOLD_GREEN}psetenv ${1}${RESET}"
        fi
        
    fi
}


 # Deletes existing virtual environment if ran with -d|--delete flag
_pysetenv_delete()
{
    if [ -z ${1} ];
    then
        echo -e "${RED}"[!] ERROR!! Please pass virtual environment name!
        _pysetenv_help
    else
        if [ -d ${PYSETENV_VIRTUAL_DIR_PATH}${1} ];
        then
            echo -e ${YELLOW}
            read -p "[?] Confirm you want to delete ${1} virtual environment (Y / N)" yes_no
            echo -e ${RESET}
            case $yes_no in
                Y|y) sudo -H rm -rvf ${PYSETENV_VIRTUAL_DIR_PATH}${1};;
                N|n) echo "${BOLD_GREEN}[-] ${GREEN}Aborting environment deletion";;
                *) echo -e "${BOLD_GREEN}[?] ${GREEN}Enter either ${BOLD_GREEN}Y/y ${GREEN}for yes or ${BOLD_RED}N/n ${GREEN} for no"${RESET}
                    return 0;;
            esac
        else
            echo -e ${BOLD_RED}"[!] ${RED}ERROR!! No virtual environment exists by the name: ${BOLD_RED}${1}"${RESET}
        fi
    fi
}


# Lists all virtual environments if ran with -l|--list flag
_pysetenv_list()
{
    echo -e ${BOLD_YELLOW}"[*] "${CYAN}"List of virtual environments you have under"${PYSETENV_VIRTUAL_DIR_PATH}${BLUE}
    for v in $(ls -l ${PYSETENV_VIRTUAL_DIR_PATH} | egrep '^d' | awk -F " " '{print $NF}' )"${RESET}"
    do
        echo -e ${BOLD_YELLOW}"-" ${YELLOW}${v} ${RESET}
    done
}


# Run python script with virtual environment
_pysetenv_run(){
    # global regex for Uppercase and Lowercase Alphabet
    re='[a-zA-Z]'

    _select_env(){
        echo -e ""
        echo -e ${BOLD_YELLOW}"[?] "${YELLOW}"Select virtual environment to run your script with: "${RESET}

        # list of available virtualenv
        venvs=$(ls -l ${PYSETENV_VIRTUAL_DIR_PATH} | egrep '^d' | awk -F " " '{print $NF}' )
        
        # check if virtualenv exists
        if [[ "$venvs" =~ $re ]];
        then
            select v in $venvs
            do
                echo -e ""
                v_venv=$v
                echo -e ${BOLD_GREEN}"[*] "${GREEN}"Running with python environment: "${BOLD_GREEN}${v_venv}${RESET}
                break
            done
        else
            echo -e ${BOLD_YELLOW}"[!] No virtual environment existing !!!"${RESET}
            echo -e ${BOLD_GREEN}"[*] "${GREEN}"Use: "${BOLD_GREEN}"pysetenv --new <venv name>"${GREEN}" to create new environment"${RESET}
            echo -e ""
            return 1
        fi
    }

    # scan root folder as python file for file reuirements.txt
    _scan_for_requirements(){
        if [ -f $SCRIPT_ROOT_PATH/requirements.txt ];
        then
            echo -e ${BOLD_GREEN}"[+] "${GREEN}"found requirements.txt"
            req_txt="${SCRIPT_ROOT_PATH}/requirements.txt"

        elif [ -f $script_dir/requirements.txt ];
            then
                echo -e ${BOLD_GREEN}"[+] "${GREEN}"found requirements.txt"
                req_txt=${script_dir}/requirements.txt

        elif [ -f ${script_dir}requirements/requirements.txt ];
            then
                echo -e ${BOLD_GREEN}"[+] "${GREEN}"found requirements.txt"
                req_txt=${script_dir}requirements/requirements.txt            

        else
            echo -e ${BOLD_YELLOW}"[!] "${YELLOW}"requirements.txt not found"${BOLD_GREEN}
            read -p "[?] Add requirements.txt path (Y / N) " yes_no

            case $yes_no in
                y|Y)
                    echo -e ${BOLD_YELLOW}"[?] "${YELLOW}"Enter absolute path to requirements.txt: "${CYAN}
                    read -p "Absolute path: " r_txt
                    # To do check if it exist
                    if [ -f "${r_txt}" ];
                    then
                        req_txt=${r_txt}
                    else
                        echo -e ${BOLD_YELLOW}"[!] "${YELLOW}"Specified File not found "${BOLD_YELLOW}"!!!"${RESET}
                        req_txt=""
                        _scan_for_requirements
                    fi
                    ;;
                n|N)
                    req_txt=""
                    ;;
                *)
                    req_txt=""
                    _scan_for_requirements
                    ;;
            esac

        fi
    }

    # Run script 
    _run_script(){
        # _select_run_mode
        echo -e ${BOLD_GREEN}"[*] "${GREEN}"Running script using: "${BOLD_GREEN}${v_venv}${GREEN}" Virtual environment"${RESET}
        echo -e ${BOLD_GREEN}"[*] "${GREEN}"path to virtual environment: "${BOLD_GREEN}${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}${RESET}
        _scan_for_requirements

        if [[ "$req_txt" =~ $re ]];
        then            
            if hash ${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}/bin/python${PYSETENV_PYTHON_VERSION} 2> /dev/null;
            then
                echo -e ${BOLD_GREEN}"[*] "${GREEN}"requirements.txt path: "${BOLD_GREEN}${req_txt}${RESET}
                echo -e ${BOLD_GREEN}"[*] "${GREEN}"Install dependancies from: "${BOLD_GREEN}${req_txt}"?"${RESET}
                read -p " (Y | N) " no_yes
                case $no_yes in 
                    y|Y)
                        echo -e ${BOLD_GREEN}"[*] "${GREEN}"Installing dependancies from: "${BOLD_GREEN}${req_txt}${RESET}
                        sudo ${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}/bin/pip${PYSETENV_PYTHON_VERSION} install -r $req_txt
                        
                        # check if os is debian or ubuntu we run python with sudo else run without
                        if [ -f /etc/os-release ];
                        then
                            OS_NAME=$(cat /etc/os-release | grep -w NAME | cut -d= -f2 | tr -d '"')
                            if [[ "${OS_NAME}" == *"Debian"* ]] || [[ "${OS_NAME}" == *"Ubuntu"* ]] ;
                            then
                                sudo -H ${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}/bin/pip${PYSETENV_PYTHON_VERSION} install -r $req_txt
                            else
                                ${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}/bin/pip${PYSETENV_PYTHON_VERSION} install -r $req_txt
                            fi
                        else
                            ${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}/bin/pip${PYSETENV_PYTHON_VERSION} install -r $req_txt --user
                        fi
                        ;;
                    n|N)
                        echo -e ${BOLD_RED}"[!] "${RED}"ABORTED"${BOLD_RED}"!!!"${RESET}
                        return 0
                        ;;
                    *)
                esac
            else
                echo -e ${BOLD_YELLOW}"[!] Specified virtual environment python does not exist !!!"${RESET}
                echo -e ${BOLD_GREEN}"[*] "${GREEN}"Use: "${BOLD_GREEN}"psetenv --new <venv name>"${GREEN}" to create new environment"${RESET}
            fi
        fi
        echo -e ${BOLD_GREEN}"[?] "${GREEN}"Run: "${BOLD_GREEN}${my_script}${GREEN}" with: "${BOLD_GREEN}${v_venv}${GREEN}" Virtual environment"${RESET}
        echo -e "    "${GREEN}"Using: "${BOLD_GREEN}${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}/bin/python${PYSETENV_PYTHON_VERSION}${GREEN}
        echo -e ${RESET}""

        read -p " ( Y | N ) " no_yes
        case $no_yes in 
            y|Y)
                echo -e ${RESET}""
                sudo ${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}/bin/python${PYSETENV_PYTHON_VERSION} ${my_script}
                echo -e ${RESET}""
                ;;
            n|N)
                echo -e ${BOLD_RED}"[!] "${RED}"ABORTED"${BOLD_RED}"!!!"${RESET}
                ;;
            *)
                _run_script
        esac
    }

    # Run script as a service
    _run_service(){
        # _select_run_mode
        echo -e ${BOLD_GREEN}"[*] "${GREEN}"Running script as a service using: "${BOLD_GREEN}${v_venv}${GREEN}" Virtual environment"${RESET}
        echo -e ${BOLD_GREEN}"[*] "${GREEN}"path to virtual environment: "${BOLD_GREEN}${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}${RESET}
        _scan_for_requirements

        # check if there's requirements.txt and install using $v_venv python
        if [[ "$req_txt" =~ $re ]];
        then
            if hash ${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}/bin/python${PYSETENV_PYTHON_VERSION} 2> /dev/null;
            then
                echo -e ${BOLD_GREEN}"[*] "${GREEN}"Requirements.txt path: "${BOLD_GREEN}${req_txt}${RESET}
                echo -e ${BOLD_GREEN}"[*] "${GREEN}"Install dependancies from: "${BOLD_GREEN}${req_txt}" ?"${RESET}
                read -p " (Y | N ) " no_yes
                case $no_yes in 
                    y|Y)
                        echo -e ${BOLD_GREEN}"[*] "${GREEN}"Installing dependancies "${BOLD_GREEN}"..."${RESET}
                        
                        # check if os is debian or ubuntu we run python with sudo else run without
                        if [ -f /etc/os-release ];
                        then
                            OS_NAME=$(cat /etc/os-release | grep -w NAME | cut -d= -f2 | tr -d '"')
                            if [[ "${OS_NAME}" == *"Debian"* ]] || [[ "${OS_NAME}" == *"Ubuntu"* ]] ;
                            then
                                sudo -H ${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}/bin/pip${PYSETENV_PYTHON_VERSION} install -r $req_txt
                            else
                                ${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}/bin/pip${PYSETENV_PYTHON_VERSION} install -r $req_txt
                            fi
                        else
                            ${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}/bin/pip${PYSETENV_PYTHON_VERSION} install -r $req_txt --user
                        fi
                        ;;
                    n|N)
                        echo -e ${BOLD_RED}"[-] "${RED}"ABORTED"${BOLD_RED}"!!!"${RESET}
                        req_txt=""
                        return 0
                        ;;
                    *)
                        _run_service
                esac
            else
                echo -e ${BOLD_YELLOW}"[!] Specified virtual environment python does not exist !!!"${RESET}
                echo -e ${BOLD_GREEN}"[*] "${GREEN}"Use: "${BOLD_GREEN}"psetenv --new <venv name>"${GREEN}" to create new environment"${RESET}
            fi
        fi

        echo -e ${BOLD_GREEN}"[?] "${GREEN}"Set: "${BOLD_GREEN}${my_script}${GREEN}" as a Service"
        echo -e "    "${GREEN}"Using: "${BOLD_GREEN}${PYSETENV_VIRTUAL_DIR_PATH}${v_venv}/bin/python${PYSETENV_PYTHON_VERSION}" Virtual Environment?"${BOLD_YELLOW}
        # Prompt whether to run the script as a service
        read -p "" no_yes
        case $no_yes in 
            y|Y)
                echo -e ${RESET}""
                
                # check if os is debian or ubuntu we run python with sudo else run without
                if [ -f /etc/os-release ];
                then
                    OS_NAME=$(cat /etc/os-release | grep -w NAME | cut -d= -f2 | tr -d '"')
                    if [[ "${OS_NAME}" == *"Debian"* ]] || [[ "${OS_NAME}" == *"Ubuntu"* ]] ;
                    then
                        if [ -f /lib/systemd/system/$script_name.service ];
                        then
                            sudo rm -rf /lib/systemd/system/$script_name.service &> /dev/null
                        fi
                        sudo touch /lib/systemd/system/$script_name.service
                        echo -e "[Unit]" | sudo tee -a /lib/systemd/system/${script_name}.service
                        echo -e "Description=Pysetenv Service" | sudo tee -a /lib/systemd/system/${script_name}.service
                        echo -e "After=multi-user.target" | sudo tee -a /lib/systemd/system/${script_name}.service
                        echo -e "Conflicts=getty@tty1.service" | sudo tee -a /lib/systemd/system/${script_name}.service
                        echo -e "[Service]" | sudo tee -a /lib/systemd/system/${script_name}.service
                        echo -e "Type=simple" | sudo tee -a /lib/systemd/system/${script_name}.service
                        echo -e "ExecStart=${PYSETENV_PYTHON_PATH} ${my_script}" | sudo tee -a /lib/systemd/system/${script_name}.service
                        echo -e "StandardInput=tty-force" | sudo tee -a /lib/systemd/system/${script_name}.service
                        echo -e "[Install]" | sudo tee -a /lib/systemd/system/${script_name}.service
                        echo -e "WantedBy=multi-user.target" | sudo tee -a /lib/systemd/system/${script_name}.service
                        sudo systemctl daemon-reload
                    else
                        sudo mkdir -p /etc/systemd/system/${my_script}.service.d
                        sudo "" >> /lib/systemd/system/${my_script}.service.d
                        sudo systemctl daemon-reload
                    fi
                else
                    sudo touch /lib/systemd/system/$script_name.service
                    echo -e "[Unit]" | sudo tee -a /lib/systemd/system/${script_name}.service
                    echo -e "Description=Pysetenv Service" | sudo tee -a /lib/systemd/system/${script_name}.service
                    echo -e "After=multi-user.target" | sudo tee -a /lib/systemd/system/${script_name}.service
                    echo -e "Conflicts=getty@tty1.service" | sudo tee -a /lib/systemd/system/${script_name}.service
                    echo -e "[Service]" | sudo tee -a /lib/systemd/system/${script_name}.service
                    echo -e "Type=simple" | sudo tee -a /lib/systemd/system/${script_name}.service
                    echo -e "ExecStart=${PYSETENV_PYTHON_PATH} ${my_script}" | sudo tee -a /lib/systemd/system/${script_name}.service
                    echo -e "StandardInput=tty-force" | sudo tee -a /lib/systemd/system/${script_name}.service
                    echo -e "[Install]" | sudo tee -a /lib/systemd/system/${script_name}.service
                    echo -e "WantedBy=multi-user.target" | sudo tee -a /lib/systemd/system/${script_name}.service
                    sudo systemctl daemon-reload
                fi

                echo -e ${BOLD_GREEN}"[*] "${GREEN}${my_script}" set as a service"
                echo -e ${BOLD_GREEN}"[*] "${GREEN}" to start service use"${BOLD_GREEN}" sudo service ${script_name} start"${GREEN}" to start ${script_name}"
                echo -e ${BOLD_GREEN}"[*] "${GREEN}" to start service use"${BOLD_GREEN}" sudo service ${script_name} stop"${GREEN}" to stop ${script_name}"${RESET}
                ;;
            n|N)
                echo -e ${BOLD_RED}"[-] "${RED}"ABORTED"${BOLD_RED}"!!!"${RESET}
                echo -e ""
                return 0
                ;;
            *)
                _run_service
        esac
    }

    _select_run_mode(){
        echo -e ""${RESET}
        echo -e ${BOLD_YELLOW}"[?] "${YELLOW}"Select how you want to run your script: "${RESET}
        select m in Script Service
        do
            case $m in
                Script)
                    run_mode=$m
                    break
                    ;;

                Service)
                    run_mode=$m
                    break
                    ;;
                *)
                    echo -e ${BOLD_GREEN}"[+] "${GREEN}"Invalid selection. Use number to select"${RESET}
                    _select_run_mode
            esac
        done
    }
    
    
    if [ $# -eq 0 ]; # If no argument show help
    then
        echo -e ""
        echo -e ${BOLD_RED}"[!] "${RED}"You have not specified file or folder"
        echo -e ${BOLD_YELLOW}"[*] "${GREEN}"USAGE: ${BOLD_GREEN}pysetenv -r <absolute/path/to/python/script>"${RESET} 
        echo -e ""
        return 1
    elif [ -f ${1} ]; # check if ${1} is a file
    then
        if [ -x ${1} ]; # check if ${1} is executable python script
        then
            my_script=$1
            script_dir=$(dirname "$1")
            script_basename=$(basename "$my_script")
            script_name=`echo "$script_basename" | cut -d'.' -f1`
            
            echo -e ${BOLD_GREEN}"[*] "${1}${GREEN}"is a python executable file"
            echo -e ${BOLD_GREEN}"[*] "${GREEN}"Root dir: "${BOLD_GREEN}${script_dir}${RESET}
            
            _select_env
            if [[ "$v_venv" =~ $re ]];
            then
                _select_run_mode

                # check runmode selected
                if [ $run_mode == "Script" ];
                then
                    echo -e ""
                    echo -e ${BOLD_GREEN}"[*] "${GREEN}"Running the script as "${BOLD_GREEN}${run_mode}${RESET}
                    _run_script

                elif [ $run_mode == "Service" ];
                then
                    echo -e ""
                    echo -e ${BOLD_GREEN}"[*] "${GREEN}"Running the script as "${BOLD_GREEN}${run_mode}${RESET}
                    _run_service
              
                else
                    _select_run_mode
                fi
            else
                return 1
            fi
        else
            echo -e ${BOLD_YELLOW}"[*] "${1}${YELLOW}" is not an executable file"
            echo -e ${BOLD_YELLOW}"[*] "${YELLOW}"Run "${BOLD_GREEN}"sudo chmod +x" ${1}${YELLOW}" to make it executable file"${RESET}
            
        fi

    else
        echo -e ""
        echo -e ${BOLD_YELLOW}"[!] "${YELLOW}"Invalid python script path specified"
        echo -e ${BOLD_YELLOW}"[*] "${GREEN}"USAGE: pysetenv -r ${BOLD_GREEN}<absolute/path/to/python/script>"${RESET} 
        echo -e ""
        return 0
    fi
}

# Main function
pysetenv()
{
    if [ $# -eq 0 ]; # If no argument show help
    then
        _pysetenv_help
    elif [ $# -le 5 ];
    then
        case "${1}" in
            -n|--new) _pysetenv_create ${2};;
            -d|--delete) _pysetenv_delete ${2};;
            -l|--list) _pysetenv_list;;
            -r|--run) _pysetenv_run ${2} ${3};;
            *) if [ -d ${PYSETENV_VIRTUAL_DIR_PATH}${1} ];
               then
                   source ${PYSETENV_VIRTUAL_DIR_PATH}${1}/bin/activate
                else
                    echo -e ${BOLD_RED}"[!] ERROR!!" ${RED}"virtual environment with name ${1} does not exist"
                    _pysetenv_help
                fi
                ;;
        esac
    fi
}