# Claude todo will run using the 

### PARAMETERS
# session_id - the session id of the claude that you want to run
# todo_file - the file that has - [ ] items init that need to be completed.
# template_file - this is the template prompt file that will be executed by claude.
claude_todos() {
    local session_id="$1"
    local todo_file="$2"
    local template_file="$3"
    
    for i in {1..10}; do
        echo "=== Running claude_todos iteration $i/10 ==="
        local todos=$(grep "^- \[ \]" "$todo_file" | head -1 || echo "No uncompleted todos found")
        local prompt=$(sed "s|\$ARGUMENTS|$todos|g" "$template_file")
        echo "claude -p \"$prompt \n the todo file is $todo_file\" --dangerously-skip-permissions --session-id \"$session_id\""
        claude -p "$prompt   \n the todo file is $todo_file" --verbose \
            --allowedTools "Read,Write,Edit,MultiEdit,Glob,Grep,Task,Bash,WebSearch,WebFetch,Notebook,Computer" \
            --output-format stream-json --resume "$session_id"
        
        # Check if there are any remaining todos
        if ! grep -q "^- \[ \]" "$todo_file"; then
            echo "All todos completed after $i iterations"
            break
        fi
    done
}

claude_todos $1 $2 $3
