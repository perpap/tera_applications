#!/usr/bin/env bash

# Declare an associative array used for error handling
declare -A ERRORS

# Define the "error" values
ERRORS[INVALID_OPTION]=1
ERRORS[INVALID_ARG]=2
ERRORS[OUT_OF_RANGE]=3
ERRORS[NOT_AN_INTEGER]=4
ERRORS[PROGRAMMING_ERROR]=5

# Define a "delimiter" to simulate multidimensional associative arrays
delimiter=":"

# Define mappings for H1_SIZE and MEM_BUDGET for each benchmark and EXEC_CORES
declare -A CONFIG_MAP=(
	["LinearRegression${delimiter}1"]="64:160"
	["LinearRegression${delimiter}2"]="64:160"
	["LinearRegression${delimiter}4"]="64:160"
	["LinearRegression${delimiter}8"]="64:160"
	["LinearRegression${delimiter}16"]="64:160"
	["LinearRegression${delimiter}20"]="64:160"
	["LinearRegression${delimiter}32"]="64:160"
	["LinearRegression${delimiter}40"]="64:160"
	["LinearRegression${delimiter}60"]="64:160"
	["LinearRegression${delimiter}80"]="64:160"
	["LinearRegression${delimiter}100"]="64:160"
	["LinearRegression${delimiter}120"]="64:160"
	["LinearRegression${delimiter}140"]="64:160"
	["LinearRegression${delimiter}160"]="64:160"
	["LogisticRegression${delimiter}1"]="64:160"
	["LogisticRegression${delimiter}2"]="64:160"
	["LogisticRegression${delimiter}4"]="64:160"
	["LogisticRegression${delimiter}8"]="64:160"
	["LogisticRegression${delimiter}16"]="64:160"
	["LogisticRegression${delimiter}20"]="64:160"
	["LogisticRegression${delimiter}32"]="64:160"
	["LogisticRegression${delimiter}40"]="64:160"
	["LogisticRegression${delimiter}60"]="64:160"
	["LogisticRegression${delimiter}80"]="64:160"
	["LogisticRegression${delimiter}100"]="64:160"
	["LogisticRegression${delimiter}120"]="64:160"
	["LogisticRegression${delimiter}140"]="64:160"
	["LogisticRegression${delimiter}160"]="64:160"
	["PageRank${delimiter}1"]="64:160"
	["PageRank${delimiter}2"]="64:160"
	["PageRank${delimiter}4"]="64:160"
	["PageRank${delimiter}8"]="64:160"
	["PageRank${delimiter}16"]="64:160"
	["PageRank${delimiter}20"]="64:160"
	["PageRank${delimiter}32"]="64:160"
	["PageRank${delimiter}40"]="64:160"
	["PageRank${delimiter}60"]="64:160"
	["PageRank${delimiter}80"]="64:160"
	["PageRank${delimiter}100"]="64:160"
	["PageRank${delimiter}120"]="64:160"
	["PageRank${delimiter}140"]="64:160"
	["PageRank${delimiter}160"]="64:160"
	["ConnectedComponent${delimiter}1"]="64:160"
	["ConnectedComponent${delimiter}2"]="64:160"
	["ConnectedComponent${delimiter}4"]="64:160"
	["ConnectedComponent${delimiter}8"]="64:160"
	["ConnectedComponent${delimiter}16"]="64:160"
	["ConnectedComponent${delimiter}20"]="64:160"
	["ConnectedComponent${delimiter}32"]="64:160"
	["ConnectedComponent${delimiter}40"]="64:160"
	["ConnectedComponent${delimiter}60"]="64:160"
	["ConnectedComponent${delimiter}80"]="64:160"
	["ConnectedComponent${delimiter}100"]="64:160"
	["ConnectedComponent${delimiter}120"]="64:160"
	["ConnectedComponent${delimiter}140"]="64:160"
	["ConnectedComponent${delimiter}160"]="64:160"
)

BENCHMARKS=(LinearRegression LogisticRegression PageRank ConnectedComponent)
#BENCHMARKS=("LinearRegression")
EXECUTOR_CORES=(8 4 2 1)
#EXECUTOR_CORES=(160 80 40 32 20 16 8 4 2 1)
#STORAGE_LEVELS=("MEMORY_ONLY" "MEMORY_AND_DISK")
#STORAGE_LEVELS=("MEMORY_AND_DISK" "MEMORY_ONLY")
#STORAGE_LEVELS=("MEMORY_AND_DISK")
STORAGE_LEVELS=("MEMORY_ONLY")
RESULTS_PATH="/spare2/perpap/spark_results"
ITERATIONS=1
EXECUTION_MODES=("f" "flexheap" "n" "native")
EXECUTION_MODE="flexheap"

# Backup original conf.sh
cp conf.sh conf.sh.backup

# Function to display usage message
function usage() {
	echo "Usage: $0 [options]"
	echo "Options:"
	echo
	echo "  -m, --mode <mode>                                     Specify f|flexheap or n|native for the \"execution mode\". When -m|--mode is not used, then the default execution mode is 'flexheap'"
	echo "  -o, --output <path>      	                        Specify the path of SparkBench's results. eg. /spare/perpap/spark_results"
	echo "  -i, --iterations                                      Specify the number of iterations for running the benchmarks."
	echo "  -h, --help                                            Display this help message and exit."
	echo
	echo "Examples:"
	echo
	echo "./run_batch.sh                 			 	Run 1 iterations of each benchmark and save the results in a default directory."
	echo "./run_batch.sh -i 3            			 	Run 3 iterations of each benchmark and save the results in a default directory."
	echo "./run_batch.sh -o /spare/perpap/spark_results    	Run 1 iterations of each benchmark and save the results in /spare/perpap/spark_results"
	echo "./run_batch.sh -o /spare/perpap/spark_results -i 3	Run 3 iterations of each benchmark and save the results in /spare/perpap/spark_results."
}

function run_benchmarks() {
	# Outer loop - BENCHMARKS
	for BENCHMARK in "${BENCHMARKS[@]}"; do
		sed -i "s/^BENCHMARKS=(.*)/BENCHMARKS=(\"$BENCHMARK\")/" conf.sh
		# Middle loop - STORAGE_LEVELS
		for STORAGE_LEVEL in "${STORAGE_LEVELS[@]}"; do
			sed -i "s/^S_LEVEL=(.*)/S_LEVEL=(\"$STORAGE_LEVEL\")/" conf.sh
			if [[ $STORAGE_LEVEL == "MEMORY_AND_DISK" ]]; then
				#sed -i "s/^MY_JAVA_HOME=.*/MY_JAVA_HOME=${NATIVE_JDK17_AARCH64}/" conf.sh
				#sed -i "s/MY_JAVA_HOME=.*/MY_JAVA_HOME=\"$NATIVE_JDK17_AARCH64\"/" conf.sh
				export MY_JAVA_HOME=$NATIVE_JDK17_AARCH64
			else
				#sed -i "s/^MY_JAVA_HOME=.*/MY_JAVA_HOME=${TERA_JDK17_AARCH64_RELEASE}/" conf.sh
				#sed -i "s/MY_JAVA_HOME=.*/MY_JAVA_HOME=\"$TERA_JDK17_AARCH64_RELEASE\"/" conf.sh
				export MY_JAVA_HOME=$TERA_JDK17_AARCH64_RELEASE
			fi

			# Inner loop - EXECUTOR_CORES
			for MUTATOR_THREADS in "${EXECUTOR_CORES[@]}"; do
				# Construct the key for fetching the configuration
				key="${BENCHMARK}${delimiter}${MUTATOR_THREADS}"
				# Fetch the configuration using the constructed key
				config="${CONFIG_MAP[$key]}"
				# Split the configuration into H1_SIZE and MEM_BUDGET
				IFS=':' read -r H1_SIZE MEM_BUDGET <<<"$config"
				# Update H1_SIZE, MEM_BUDGET, BENCHMARKS and EXEC_CORES in conf.sh
				sed -i "s/^H1_SIZE=(.*)/H1_SIZE=( $H1_SIZE )/" conf.sh
				sed -i "s/^MEM_BUDGET=.*/MEM_BUDGET=${MEM_BUDGET}G/" conf.sh
				sed -i "s/^EXEC_CORES=(.*)/EXEC_CORES=($MUTATOR_THREADS)/" conf.sh

				if [[ $MUTATOR_THREADS -le 8 ]]; then
					GC_THREADS=$MUTATOR_THREADS
				else
					# Compute GC_THREADS based on MUTATOR_THREADS using bc, properly rounding to the nearest integer
					GC_THREADS=$(echo "$MUTATOR_THREADS * 5 / 8" | bc -l)
					# Round the result by adding 0.5 and then truncating the decimal part
					GC_THREADS=$(echo "$GC_THREADS + 0.5" | bc)
					# Since bc does not automatically drop the decimal part when scale is not set, explicitly truncate the decimal part
					GC_THREADS=$(echo "$GC_THREADS / 1" | bc)
				fi
				sed -i "s/^GC_THREADS=.*/GC_THREADS=$GC_THREADS/" conf.sh

				# Execute run.sh with conditional flags based on STORAGE_LEVEL
				if [ $STORAGE_LEVEL == "MEMORY_ONLY" ]; then
					echo "[TERAHEAP]Execution of $BENCHMARK using $MUTATOR_THREADS mutator threads and $GC_THREADS GC threads."
					./run.sh -n $ITERATIONS -o $RESULTS_PATH -t
				else
					echo "[NATIVE]Execution of $BENCHMARK using $MUTATOR_THREADS mutator threads and $GC_THREADS GC threads."
					./run.sh -n $ITERATIONS -o $RESULTS_PATH -s
				fi
			done
		done
	done
}

function parse_script_arguments() {
	local OPTIONS=m:o:i:h
	local LONGOPTIONS=mode:,output:,iterations:,help

	# Use getopt to parse the options
	local PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")

	# Check for errors in getopt
	if [[ $? -ne 0 ]]; then
		return ${ERRORS[INVALID_OPTION]} 2>/dev/null || exit ${ERRORS[INVALID_OPTION]}
	fi

	# Evaluate the parsed options
	eval set -- "$PARSED"

	while true; do
		case "$1" in
		-o | --output)
			RESULTS_PATH="$2"
			shift 2
			;;
		-i | --iterations)
			ITERATIONS="$2"
			validateIterations
			shift 2
			;;
		-h | --help)
			usage
			exit 0
			;;
		--)
			shift
			break
			;;
		*)
			echo "Programming error"
			return ${ERRORS[PROGRAMMING_ERROR]} 2>/dev/null || exit ${ERRORS[PROGRAMMING_ERROR]} # This will return if sourced, and exit if run as a standalone script
			;;
		esac
	done
}

validateExecutionMode() {
	for EXECUTION_MODE in "${EXECUTION_MODES[@]}"; do
		if [[ $EXECUTION_MODE == "f" || $EXECUTION_MODE == "flexheap" ]]; then
			EXECUTION_MODE="t"
		elif [[ $EXECUTION_MODE == "n" || $EXECUTION_MODE == "native" ]]; then
			EXECUTION_MODE="s"
		else
			echo "execution mode:$EXECUTION_MODE is not valid. Valid execution modes: f|flexheap, n|native"
			return ${ERRORS[INVALID_ARG]} 2>/dev/null || exit ${ERRORS[INVALID_ARG]} # This will return if sourced, and exit if run as a standalone script
		fi
	done
}

validateIterations() {
	if [[ ! $ITERATIONS =~ ^[0-9]+$ ]]; then # Validate if iterations is an integer
		echo "iterations:$ITERATIONS is not an integer."
		return ${ERRORS[NOT_AN_INTEGER]} 2>/dev/null || exit ${ERRORS[NOT_AN_INTEGER]} # This will return if sourced, and exit if run as a standalone script
	elif [[ $ITERATIONS -lt 1 || $ITERATIONS -gt 5 ]]; then                         # Check if the iterations is within the range 1 to 5
		echo "iterations:$ITERATIONS is not within the range 1 to 5."
		return ${ERRORS[OUT_OF_RANGE]} 2>/dev/null || exit ${ERRORS[OUT_OF_RANGE]} # This will return if sourced, and exit if run as a standalone script
	fi
}

parse_script_arguments "$@"
run_benchmarks

# Restore the original conf.sh to leave no side effects
cp conf.sh.backup conf.sh
rm conf.sh.backup
