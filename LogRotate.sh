###############################################################################
#------------------------------ LOG ROTATATION -------------------------------#
###############################################################################
#-----------------------Details ----------------------------------------------#
# Platform Unix:[Linux]                                                       #
# Purpose : Rotate the log files                                              #
#           - Time based generation of log files can be done one file per day #
#           - Size based generation of log files can be done when size >10MB  #
# ----------------------------------------------------------------------------#
# ----------------------------------------------------------------------------#
# DATE: 21 Sep 2022                                                           #
# BY: TANMAYEE PATIL                                                          #
###############################################################################

SCRIPT_VERSION=1.0
SCRIPT_PATH=`pwd`
HOST_NAME=`hostname -f`
CURRENT_DATE=$(date +%Y%m%d_%H%M%S)
SCRIPT_LOG_DIR=$SCRIPT_PATH/LogRotate.log

source $SCRIPT_PATH/LogRotate.properties  

usage()
{
    echo -e "\e[93m\nSCRIPT USAGE:"
    echo -e "LogRotate.sh <Type of rotation> <Absolute path to file>"
    echo -e "Types of rotation : timebased (-tb) or sizebased (-sb)\e[0m"
}

checkInputes()
{
    if [ ! -z $TYPE_ROTATION ] && [ ! -z $LOG_PATH ];then
       echo -e "\n[INFO]     : Input Recevied - Rotation Type: $TYPE_ROTATION & Log Path: $LOG_PATH" | tee -a $SCRIPT_LOG_DIR
       if [ $TYPE_ROTATION == "-tb" ] || [ $TYPE_ROTATION == "-sb" ] || [ $TYPE_ROTATION == "timebased" ] || [ $TYPE_ROTATION == "sizebased" ];then
          echo -e "[INFO]     : Type of rotation check PASS" | tee -a $SCRIPT_LOG_DIR
       else
          echo -e "\n[ERROR]    : Incorrect type of rotation." | tee -a $SCRIPT_LOG_DIR
          echo -e "[ERROR]    : Expected - Type of rotation: TimeBased or SizeBased"
          echo -e "[ACTION]   : Execution Terminated" | tee -a $SCRIPT_LOG_DIR
          return 0;
       fi
       if [ -d $LOG_PATH ];then
          echo -e "[INFO]     : Log path check PASS" | tee -a $SCRIPT_LOG_DIR
       else
          echo -e "\n[ERROR]    : Incorrect log directory path. Please check the path and pass the absolute path." | tee -a $SCRIPT_LOG_DIR
          echo -e "[ACTION]   : Execution Terminated" | tee -a $SCRIPT_LOG_DIR
       fi
    else
       echo -e "\n[ERROR]    : Please provide "Type of rotation" and "path of the log file" to the script." | tee -a $SCRIPT_LOG_DIR
       echo -e "[ACTION]   : Execution Terminated" | tee -a $SCRIPT_LOG_DIR
    fi
}

function TimeBasedFunction()
{
# Reading out files from the log directory
for files in $LOG_PATH
do
    while read file ;
    do
        if [ ! -z $file ];then
            dirname="${file%/*}/"
            basename="${file:${#dirname}}"
            if [ ! -z $dirname ] && [ ! -z $basename ];then
                echo -e "[INFO]     : Recived $file to rotate." | tee -a $SCRIPT_LOG_DIR
                mv $LOG_PATH/$basename $LOG_PATH/$basename.$CURRENT_DATE
                if [ -s $LOG_PATH/$basename.$CURRENT_DATE ];then
                    echo -e "[INFO]     : File $file rotated successfully." | tee -a $SCRIPT_LOG_DIR
                    touch $LOG_PATH/$basename
                    if [ -f $LOG_PATH/$basename ];then
                        echo -e "[INFO]     : New $file created." | tee -a $SCRIPT_LOG_DIR
                    else
                        echo -e "[ERROR]    : Failed to create new $file."  | tee -a $SCRIPT_LOG_DIR
                    fi
                else
                    echo -e "[ERROR]    : Failed to rotate $file file." | tee -a $SCRIPT_LOG_DIR
                fi
            else
                echo -e "[ERROR]    : Failed to find dirname and basename."  | tee -a $SCRIPT_LOG_DIR
            fi
        else
            echo -e "[INFO]     : No file found to rotate in $LOG_PATH"  | tee -a $SCRIPT_LOG_DIR
        fi
    done < <(find "$files" \( -name '*.log' -o -name '*.logs' -o -name '*.out' \) -mtime -$ReadTime -type f -print 2>/dev/null);
done
}

function SizeBasedFunction()
{
# Reading out files from the log directory
for files in $LOG_PATH
do
    while read file ;
    do
        if [ ! -z $file ];then
            dirname="${file%/*}/"
            basename="${file:${#dirname}}"
            if [ ! -z $dirname ] && [ ! -z $basename ];then
                echo -e "[INFO]     : Recived $file to rotate." | tee -a $SCRIPT_LOG_DIR
                mv $LOG_PATH/$basename $LOG_PATH/$basename.$CURRENT_DATE
                if [ -s $LOG_PATH/$basename.$CURRENT_DATE ];then
                    echo -e "[INFO]     : File $file rotated successfully." | tee -a $SCRIPT_LOG_DIR
                    touch $LOG_PATH/$basename
                    if [ -f $LOG_PATH/$basename ];then
                        echo -e "[INFO]     : New $file created." | tee -a $SCRIPT_LOG_DIR
                    else
                        echo -e "[ERROR]    : Failed to create new $file."  | tee -a $SCRIPT_LOG_DIR
                    fi
                else
                    echo -e "[ERROR]    : Failed to rotate $file file." | tee -a $SCRIPT_LOG_DIR
                fi
            else
                echo -e "[ERROR]    : Failed to find dirname and basename."  | tee -a $SCRIPT_LOG_DIR
            fi
        else
            echo -e "[INFO]     : No file found to rotate in $LOG_PATH"  | tee -a $SCRIPT_LOG_DIR
        fi
    done < <(find "$files" \( -name '*.log' -o -name '*.logs' -o -name '*.out' \) -size +$FileSizeLimit -type f -print 2>/dev/null);
done
}


###################################### Main Section ######################################
echo -e "\n---------------------------------------------------------------------------------------------" | tee -a $SCRIPT_LOG_DIR
echo -e "\e[4;96mDATE: $(date)\e[0m" | tee -a $SCRIPT_LOG_DIR
echo -e "\e[93mLogRetention :: [ START ]\e[0m" | tee -a $SCRIPT_LOG_DIR

TYPE_ROTATION=$1
LOG_PATH=$2

#Checking inputs
checkInputes

case $TYPE_ROTATION in
-tb|timebased)
                    TimeBasedFunction
                    ;;
-sb|sizebased)
                    SizeBasedFunction
                    ;;
help|-h)
        usage
        ;;
*)  
        usage  
        ;; 
esac  
echo -e "\n---------------------------------------------------------------------------------------------" | tee -a $SCRIPT_LOG_DIR
