#!/bin/zsh

cleanup() {
    local elapsed_time=$(($(date +%s) - $start_time))
    local b="Elapsed time: $(($elapsed_time / 60)) minutes and $(($elapsed_time % 60)) seconds"
    echo "$b"
    exit 1
}

# Check if two arguments are provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <full/path/to/file.m> <args>"
    exit 1
fi

# Store the .m path
matlab_file="$1"

# Extract the function name by removing the directory path and .m extension
function_name=$(basename "$matlab_file" .m)
folder_path=$(dirname "$matlab_file")
echo $function_name
echo $folder_path

# Shift the arguments to get the rest of the arguments
shift

# Print the date that this was run.
# date "+Date: %A, %B, %d, %Y    Time: %I:%M:%S %p"

# Get the starting time
start_time=$(date +%s)

# Set up a trap to catch SIGINT (Ctrl+C)
trap cleanup SIGINT SIGTERM

# Check if the scripts exist
if [ ! -f "$matlab_file" ]; then
    echo "Error: $matlab_file does not exist"
    exit 1
fi

# Combine the remaining arguments into a comma-separated list for MATLAB
args=$(printf "'%s', " "$@")
args=${args%, } # Remove the trailing comma and space
echo $args

# Run MATLAB with the specified function and pass the remaining arguments
matlab_exec="/Applications/MATLAB_R2024a.app/bin/matlab"
"$matlab_exec" -nodisplay -nosplash -nodesktop -r "try, cd('$folder_path'), ${function_name}($args), catch e, disp(getReport(e)), exit(1), end, exit(0);"
matlab_pid=$!

# Wait for MATLAB to finish
wait $matlab_pid

elapsed_time=$(($(date +%s) - $start_time))
echo "Elapsed time: $(($elapsed_time / 60)) minutes and $(($elapsed_time % 60)) seconds"

# Check if MATLAB ran successfully
matlab_exit_status=$?
if [ $matlab_exit_status -ne 0 ]; then
    echo "Error: MATLAB execution failed. Check $log_file for details."
    exit 1
fi

