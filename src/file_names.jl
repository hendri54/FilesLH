"""
	$(SIGNATURES)

Compare two paths, taking into account that trailing file separators do not count.
"""
paths_equal(f1, f2) = 
    isequal(strip_trailing_fs(f1),  strip_trailing_fs(f2));


"""
	$(SIGNATURES)

Are two extensions equal, ignoring leading "."?
"""
extensions_equal(f1 :: AbstractString, f2 :: AbstractString) = 
    isequal(lstrip(f1, '.'), lstrip(f2, '.'));


strip_trailing_fs(fPath) = rstrip(fPath, filesep());


"""
	$(SIGNATURES)

File separator for current OS.
"""
function filesep()
    if Sys.isunix()
        return '/'
    elseif Sys.iswindows()
        return '\\'
    end
end


"""
	$(SIGNATURES)

Does file have an extension?
"""
has_extension(filePath :: AbstractString) = !isempty(splitext(filePath)[2]);


"""
	$(SIGNATURES)

Does file have a particular extension? Ignoring leading '.'.
"""
function has_extension(filePath :: AbstractString, fExt :: AbstractString)
    _, fExt2 = splitext(filePath);
    return extensions_equal(fExt, fExt2)
end


"""
    $(SIGNATURES)

Change or add extension to a path. `newExt` may or may not include the leading ".".
"""
function change_extension(filePath :: String, newExt :: String)
    (newPath, _) = splitext(filePath);
	if newExt[1] != '.'
        dotStr = ".";
    else
        dotStr = "";
    end
   return newPath * dotStr * newExt
end


"""
	$(SIGNATURES)

Add extension to a file, unless it already has one.
"""
function add_extension(filePath :: AbstractString, newExt :: AbstractString)
    if has_extension(filePath)
        return filePath
    else
        return change_extension(filePath, newExt);
    end
end


# -------------