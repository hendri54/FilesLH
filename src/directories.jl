"""
    $(SIGNATURES)

Clear a directory and its sub-directories
"""
function clear_directory(tgDir :: AbstractString; askFirst :: Bool = true)
    if isdir(tgDir)
        ans1 = ask_yes_no("Clear directory  $tgDir");
        if ans1
            rm(tgDir, recursive = true);
        end
    end
    isdir(tgDir)  ||  mkpath(tgDir);
    return nothing
end

# --------------