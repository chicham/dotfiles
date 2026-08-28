complete -c pr-clean -f \
    -a "(jj workspace list 2>/dev/null | string replace -r ':.*' '' | string match -v default)"
