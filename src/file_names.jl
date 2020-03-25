paths_equal(f1, f2) = 
    isequal(strip_trailing_fs(f1),  strip_trailing_fs(f2));


strip_trailing_fs(fPath) = rstrip(fPath, filesep());


function filesep()
    if Sys.isunix()
        return '/'
    elseif Sys.iswindows()
        return '\\'
    end
end

# -------------