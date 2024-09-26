#!/bin/zsh

cleanup() {
    local elapsed_time=$(($(date +%s) - $start_time))
    local b="Elapsed time: $(($elapsed_time / 60)) minutes and $(($elapsed_time % 60)) seconds"
    echo "$b"
    echo "$b" >> $log_file
    exit 1
}

# Check if two arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <path/to/RunCode.m> <path/to/script_to_run.m>"
    exit 1
fi

# Store the script paths
SCRIPT1="$1"
SCRIPT2="$2"

# Get the folder path to store the log file in.
foldername=${SCRIPT1:h}
chmod 777 $foldername
echo "Project Folder = $foldername"

# Make it a file name
filename="logfile_$(date +%Y%m%d_%H%M%S).log"
log_folder="${foldername}/logs"
log_file="${log_folder}/${filename}"

# Print the date that this was run.
date "+Date: %A, %B, %d, %Y    Time: %I:%M:%S %p" | tee -a "$log_file"

# Get the starting time
start_time=$(date +%s)

# Set up a trap to catch SIGINT (Ctrl+C)
trap cleanup SIGINT SIGTERM

# Check if the scripts exist
for script in "$SCRIPT1" "$SCRIPT2"; do
    if [ ! -f "$script" ]; then
        echo "Error: $script does not exist"
        exit 1
    fi
done

# Check if we can create the log folder
if ! mkdir -p "$log_folder" 2>/dev/null; then
    echo "Error: Cannot create logs folder at $logs_folder"
    echo "Current permissions:"
    ls -ld "$foldername"
    echo "Error: Cannot create log file at $log_file"
    exit 1
fi

if ! touch "$log_file" 2>/dev/null; then
    echo "Error: Cannot create log file at $log_file"
    echo "Logs folder permissions:"
    ls -ld "$log_folder"
    echo "Current user: $(whoami)"
    echo "Available space:"
    df -h "$log_folder"
    exit 1
fi

# Run both MATLAB scripts in a single session
echo "Running $SCRIPT1 and $SCRIPT2 in a single MATLAB session..." | tee -a "$log_file"
matlab_exec="/Applications/MATLAB_R2024a.app/bin/matlab"
"$matlab_exec" -nodisplay -nosplash -nodesktop -r "try, run('$SCRIPT1'), run('$SCRIPT2'), catch e, disp(getReport(e)), exit(1), end, exit(0);" 2>&1 | tee -a "$log_file" &
matlab_pid=$!

# Wait for MATLAB to finish
wait $matlab_pid

elapsed_time=$(($(date +%s) - $start_time))
echo "Elapsed time: $(($elapsed_time / 60)) minutes and $(($elapsed_time % 60)) seconds" | tee -a "$log_file"

# Check if MATLAB ran successfully
matlab_exit_status=$?
if [ $matlab_exit_status -ne 0 ]; then
    echo "Error: MATLAB execution failed. Check $log_file for details."
    exit 1
fi

