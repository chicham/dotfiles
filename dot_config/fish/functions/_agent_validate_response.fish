# Validate response and handle empty responses with clipboard fallback
function _agent_validate_response -a response
    if test -z "$response"
        _agent_error "Received empty response from AI agent" "Raw response copied to clipboard for inspection"
        echo "$response" | pbcopy
        return 1
    end
    return 0
end
