# Display standardized debug message with section formatting
function _agent_debug -a title content
    if test -n "$content"
        echo "" >&2
        echo "🐛 DEBUG - $title:" >&2
        echo "============================" >&2
        echo -e "$content" >&2
        echo "============================" >&2
        echo "" >&2
    else
        echo "🐛 DEBUG - $title" >&2
    end
end
