# Extract multiline BODY field from structured response using awk
function _agent_extract_body_field -a response
    printf '%s\n' "$response" | awk '/^BODY: */ {
        sub(/^BODY: */, "");
        body = $0;
        while ((getline line) > 0 && line !~ /^[A-Z]+: */) {
            if (body) body = body "\n" line; else body = line;
        }
        print body;
        exit
    }'
end
