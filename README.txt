script optimization checklist
-----------------------------
* stub

    * correct and up to date information

    * confirm supported platform (as much as possible)

    * good description

* usage

    * = usage() {

    * test $# = 0 || echo $@

    * adequate usage line

    * usage line does not use basename $0 but simply $0

    * good brief description

    * list of options

	* comprehensive

	* good explanation

	* help option -h, --help

    ! exit 1 in the end !

* command line parser

    * new style negation --no-FLAG

    * sample lines (optional if there are real examples)
    
	* flag
	
	* param

    * no unnecessary "--" parsing (comment out)

    * = shift; while test "$1"; do args="$args \"$1\""; shift; done; break ;;

    * do not parse *) unnecessarily (comment out)

* pre-main

    * default values

    * flag checks: on | off

    * comment out or remove eval "set -- $args" if not needed

    * zero argument check: test "$1" || usage "possibly a message"

* main : general flaws

    * taking care of filenames with spaces

    * cleaning up using trap. 
      but should use it when a script creates temporary files, esp using $$

    * differences in command flags across different OS-es

    * use date +%F instead of date --iso

    * use $() instead of ``

    * use ">/dev/null 2>&1 ;" instead of &>

    * do not put space after " >"

    * exit codes: make sure it's 1 on failure. and in traps.

