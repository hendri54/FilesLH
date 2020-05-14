"""
    $(SIGNATURES)

Clear a directory and its sub-directories
"""
function clear_directory(tgDir :: AbstractString; askFirst :: Bool = true)
    if isdir(tgDir)
        if askFirst
            ans1 = ask_yes_no("Clear directory  $tgDir");
        else
            ans1 = true;
        end
        ans1  &&  rm(tgDir, recursive = true);
    end
    isdir(tgDir)  ||  mkpath(tgDir);
    return nothing
end


"""
	$(SIGNATURES)

Is a directory empty?
"""
is_dir_empty(d :: AbstractString) = isempty(readdir(d));

# --------------