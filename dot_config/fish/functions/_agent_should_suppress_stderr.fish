# Suppress stderr based on debug flag presence in argument list
function _agent_should_suppress_stderr
    for arg in $argv
        if test "$arg" = "--debug"
            return 1  # Don't suppress if debug flag present
        end
    end
    return 0  # Suppress stderr
end
