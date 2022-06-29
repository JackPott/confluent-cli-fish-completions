# Confluent CLI completions for fish, based entirely on the completions file 
# generated by podman. 
# https://docs.podman.io/en/v3.3.0/markdown/podman-completion.1.html#fish
# Adapted by Chris Austin github.com/JackPott/confluent-cli-fish-completions



function __confluent_debug
    set file "$BASH_COMP_DEBUG_FILE"
    if test -n $file
        echo $argv >> $file
    end
end


function __confluent_perform_completion
    __confluent_debug "Starting __confluent_perofmr_completion with: $argv"

    set args (string split -- " " "$argv")
    set lastArg "$args[-1]"

    __confluent_debug "args: $args"
    __confluent_debug "last arg: $lastArg"

    set emptyArg "" 
    if test -z "$lastArg"
        __confluent_debug "Setting emptyArg"
        # This line breaks syntax highlighting for the rest of the doc
        set emptyArg \"\" 
    end
    __confluent_debug "emptyArg: $emptyArg"

    set requestComp "$args[1] __complete $args[2..-1] $emptyArg"
    __confluent_debug "Calling $requestComp"

    set results (eval $requestComp 2> /dev/null)
    set comps $results[1..-2]
    set directiveLine $results[-1]

    # For Fish, when completing a flag with an = (e.g., <program> -n=<TAB>)
    # completions must be prefixed with the flag
    set flagPrefix (string match -r -- '-.*=' "$lastArg")

    __confluent_debug "Comps: $comps"
    __confluent_debug "DirectiveLine: $directiveLine"
    __confluent_debug "flagPrefix: $flagPrefix"

    for comp in $comps
        printf "%s%s\n" "$flagPrefix" "$comp"
    end

    printf "%s\n" "$directiveLine"
end
 
function __confluent_prepare_completions
    # Start fresh
    set --erase __confluent_comp_do_file_comp
    set --erase __confluent_comp_results 

    # Check if command-line is already provided.  This is useful for testing.
    if not set --query __confluent_comp_commandLine
        # Use the -c flag to allow for completion in the middle of the line
        set __confluent_comp_commandLine (commandline -c)
    end
    __confluent_debug "commandLine is: $__confluent_comp_commandLine"

    set results (__confluent_perform_completion "$__confluent_comp_commandLine")
    set --erase __confluent_comp_commandLine
    __confluent_debug "Completion results: $results"

    if test -z "$results"
        __confluent_debug "No completion, probably due to a failure"
        # Do file completion in case it helps
        set --global __confluent_comp_do_file_comp 1
        return 1
    end

    set directive (string sub --start 2 $results[-1])
    set --global __confluent_comp_results $results[1..-2]

    __confluent_debug "Completions are: $__confluent_comp_results"
    __confluent_debug "Directive is: $directive"

    set shellCompDirectiveError 1
    set shellCompDirectiveNoSpace 2
    set shellCompDirectiveNoFileComp 4
    set shellCompDirectiveFilterFileExt 8
    set shellCompDirectiveFilterDirs 16

    if test -z "$directive"
        set directive 0
    end

    set compErr (math (math --scale 0 $directive / $shellCompDirectiveError) % 2)
    if test $compErr -eq 1
        __confluent_debug "Received error directive: aborting."
        # Might as well do file completion, in case it helps
        set --global __confluent_comp_do_file_comp 1
        return 1
    end

    set filefilter (math (math --scale 0 $directive / $shellCompDirectiveFilterFileExt) % 2)
    set dirfilter (math (math --scale 0 $directive / $shellCompDirectiveFilterDirs) % 2)
    if test $filefilter -eq 1; or test $dirfilter -eq 1
        __confluent_debug "File extension filtering or directory filtering not supported"
        # Do full file completion instead
        set --global __confluent_comp_do_file_comp 1
        return 1
    end

    set nospace (math (math --scale 0 $directive / $shellCompDirectiveNoSpace) % 2)
    set nofiles (math (math --scale 0 $directive / $shellCompDirectiveNoFileComp) % 2)

    __confluent_debug "nospace: $nospace, nofiles: $nofiles"

    # Important not to quote the variable for count to work
    set numComps (count $__confluent_comp_results)
    __confluent_debug "numComps: $numComps"

    if test $numComps -eq 1; and test $nospace -ne 0
        # To support the "nospace" directive we trick the shell
        # by outputting an extra, longer completion.
        __confluent_debug "Adding second completion to perform nospace directive"
        set --append __confluent_comp_results $__confluent_comp_results[1].
    end

    if test $numComps -eq 0; and test $nofiles -eq 0
        __confluent_debug "Requesting file completion"
        set --global __confluent_comp_do_file_comp 1
    end

    # If we don't want file completion, we must return true even if there
    # are no completions found.  This is because fish will perform the last
    # completion command, even if its condition is false, if no other
    # completion command was triggered
    return (not set --query __confluent_comp_do_file_comp)  
end
    
# Since Fish completions are only loaded once the user triggers them, we trigger them ourselves
# so we can properly delete any completions provided by another script.
# The space after the the program name is essential to trigger completion for the program
# and not completion of the program name itself.
complete --do-complete "confluent " > /dev/null 2>&1
# Using '> /dev/null 2>&1' since '&>' is not supported in older versions of fish.

# Remove any pre-existing completions for the program since we will be handling all of them.
complete -c confluent -e

# The order in which the below two lines are defined is very important so that __confluent_prepare_completions
# is called first.  It is __confluent_prepare_completions that sets up the __confluent_comp_do_file_comp variable.
#
# This completion will be run second as complete commands are added FILO.
# It triggers file completion choices when __confluent_comp_do_file_comp is set.
complete -c confluent -n 'set --query __confluent_comp_do_file_comp'

# This completion will be run first as complete commands are added FILO.
# The call to __confluent_prepare_completions will setup both __confluent_comp_results and __confluent_comp_do_file_comp.
# It provides the program's completion choices.
complete -c confluent -n '__confluent_prepare_completions' -f -a '$__confluent_comp_results'
