#!/usr/bin/env bash

pairs_file=$1

ME_BIN=`basename "$0"`

JQ_BIN=`which jq`

GIT_BIN=`which git`

let ii=0

printToError() {
	local msg="${@}"
	#echo ${msg} > /dev/stderr
	echo ${msg} 1>&2
}

printWarning() {
	local msg="${@}"
	printToError "WARNING: ${msg}"
}

printError() {
	local msg="${@}"
	printToError "ERROR: ${msg}"
}

printFatalError() {
	local msg="${@}"
	printToError "FATAL ERROR: ${msg} - aborting"
}

abort() {
	printFatalError $@
	exit 1
}

usage() {
	echo    "Usage:"
	echo    "======"
	echo -e "\t${ME_BIN} \"<path to pairs file>\"\n"
}

abortWithUsage() {
	printFatalError $@

#	usage > /dev/stderr
	usage 1>&2

	exit 1
}

printDoubleLine() {
	echo "====================================="
}

handleItem() {
	local item="$1"

	local source=`echo ${item} | ${JQ_BIN} -r ".source"`
	test "$source" = "null" && abort "'source' not found in item ${ii}"

	local destination=`echo ${item} | ${JQ_BIN} -r ".destination"`
	test "$destination" = "null" && abort "'destination' not found in item ${ii}"

	local lfs=`echo ${item} | ${JQ_BIN} -r ".lfs"`
	test "$lfs" = "null" && lfs="false"
	test "$lfs" = "true" && lfs="ssh://${destination}"

	local branch=`echo ${item} | ${JQ_BIN} -r ".branch"`
	test "$branch" = "null" && branch="master"

	printDoubleLine
	echo -n "Fetching from '${source}': "

	cd "${tempdir}"

	# clone it to local path
	local git_params="clone -q --bare"
	if [ "${branch}" != "*" ]; then
		git_params="${git_params} --single-branch --branch \"${branch}\""
	fi


	ex="${GIT_BIN} ${git_params} \"${source}\""
	eval ${ex}
	RC=$?

	if [ ${RC} -ne 0 ]; then
		printError "Error cloning repository to local path"
		return
	fi

	echo "OK"

	echo -e -n "\tChecking local path: "
	local dest_dir=""${tempdir}"/`basename "${source}"`"
	test -d "${dest_dir}" || abort "Missing destination dir '${dest_dir}'"

	echo "OK"

	cd "${dest_dir}"

	# fetch lfs
	if [ "${lfs}" != "false" ]; then
		echo -n -e "\tFetching lfs objects: "
		echo "(not working yet)"
#		local result=`${GIT_BIN} lfs fetch --all`
#		RC=$?
#		if [ ${RC} -ne 0 ]; then
#			printWarning "${result}"
#		    printWarning "Fetching lfs objects did not work"
#	    else
#	        echo "OK"
#	    fi
#    else
#        echo "(not enabled)"
	fi

	# push to destination repository
	echo -e -n "\tPushing to \"${destination}\": "
	${GIT_BIN} push --mirror -q "${destination}"
	RC=$?
	if [ ${RC} -eq 0 ]; then
		echo "OK"
	else
	    printError "Error pushing to \"${destination}\""
	    return
    fi

	# push lfs objects
	if [ "${lfs}" != "false" ]; then
		echo -n -e "\tPushing lfs objects to \"${lfs}\": "
		echo "(not working yet)"
#		local result=`${GIT_BIN} lfs push --all "${lfs}"`
#		RC=$?
#		if [ ${RC} -ne 0 ]; then
#			printWarning "${result}"
#		    printWarning "Pushing lfs objects did not work"
#	    else
#	        echo "OK"
#	    fi
#    else
#        echo "(not enabled)"
	fi

	cd "${curdir}"
}

main() {

	pairs_content=`cat "${pairs_file}"`
	RC=$?
	test ${RC} -eq 0 || abort "Could not read '${pairs_file}'"


	while [ 1 -eq 1 ]; do
		x=`echo ${pairs_content} | ${JQ_BIN} ".[${ii}]"`
		RC=$?
		test ${RC} -eq 0 || abort "Error parsing '${pairs_file}'"

		if [ "$x" = "null" ]; then
			break;
		fi
		let ii++
		handleItem "$x"

	done
	printDoubleLine
}

finish() {
	#echo "Deleting $tempdir"
	rm -rf "$tempdir"
	cd "${curdir}"
}

test -z "${JQ_BIN}" && abort "binary fo jq not found"

test -z "${pairs_file}" && abortWithUsage "parameter for pairs_file empty"

curdir=`pwd`

pairs_content=""

#tempdir="/tmp/gitsync"; rm -rf "$tempdir" ; mkdir -p $tempdir
tempdir=`mktemp -d -t "${ME_BIN}.XXXXXXXXXX"`
trap finish EXIT

unset SSH_AUTH_SOCK
unset KRB5CCNAME

main

