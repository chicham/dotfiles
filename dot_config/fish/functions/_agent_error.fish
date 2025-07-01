# Display standardized error message with suggestion
function _agent_error -a message suggestion
    echo "❌ Error: $message" >&2
    if test -n "$suggestion"
        echo "💡 Suggestion: $suggestion" >&2
    end
end
