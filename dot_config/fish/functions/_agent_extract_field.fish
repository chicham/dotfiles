# Extract single-line field from structured response (e.g., TITLE:, LABELS:)
function _agent_extract_field -a response field_name
    printf '%s\n' "$response" | grep "^$field_name:" | sed "s/^$field_name: *//"
end
