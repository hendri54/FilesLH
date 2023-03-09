"""
	$(SIGNATURES)

Parent directory of an input directory.
"""
function parent_dir(inDir)
    return normpath(joinpath(inDir, ".."))
end


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

Make a directory for a full path, if it does not already exist. Input `d` is a file path which may include name and extension. Also creates (using `mkpath`) intermediate directories.

# Example
```
make_dir("/abc/def/ghi.txt") # makes "/abc/def"
```
"""
function make_dir(d :: AbstractString)
    fDir, _ = splitdir(d);
    if !isempty(fDir)
        isdir(fDir)  ||  mkpath(fDir);
    end
end


"""
	$(SIGNATURES)

Is a directory empty?
"""
is_dir_empty(d :: AbstractString) = isempty(readdir(d));


"""
	$(SIGNATURES)

Return a string with the `nDirs` "rightmost" directories. Note that the right most "directly" is the file name if the input string contains one.

# Example
```
right_dirs("/abc/def/ghi/", 2) == "def/ghi"
right_dirs("abc/def/ghi.jl", 2) == "def/ghi.jl"
```
"""
function right_dirs(d :: AbstractString, nDirs :: Integer)
    # Locations of interior file separators
    # idxV = findall(j -> d[j] == filesep(), 2 : (length(d) - 1));
    # if length(idxV) < nDirs 
    #     pd = d;
    # else
    #     idx1 = idxV[length(idxV) - nDirs] + 1;
    #     pd = d[idx1 : end];
    # end
    pV = splitpath(d);
    n = length(pV);
    if n > nDirs
        idxV = max(1, n - nDirs + 1) : n;
        pd = joinpath(pV[idxV]...);
    else
        pd = rstrip(d, filesep());
    end
    return pd
end


"""
	$(SIGNATURES)

Find common base directory for a set of absolute paths.
"""
function find_common_base_dir(pathV :: AbstractVector{T}) where T <: AbstractString
    cbd = pathV[1];
    for j = 2 : length(pathV)
        cbd = find_common_base_dir(cbd, pathV[j]);
    end
    return cbd
end

function find_common_base_dir(d1, d2)
    if isempty(d1) || isempty(d2)
        return nothing
    end

    p1V = splitpath(d1);
    p2V = splitpath(d2);
    n = min(length(p1V), length(p2V));
    jd = findfirst(j -> !isequal(p1V[j], p2V[j]), 1 : n);

    if isnothing(jd)
        jd = n+1;
    end
    return joinpath(p1V[1 : (jd-1)]...)
end


"""
	$(SIGNATURES)

Make a list of all files in a given directory. Recurses sub-directories. Each line is of the form "subdir/file.ext"
"""
function files_in_dir(d :: AbstractString)
    fList = Vector{String}();
    for (root, _, files) in walkdir(d)
        subDir = relpath(root, d);
        if subDir == "."
            subDir = "";
        end
        for file in files
            push!(fList, joinpath(subDir, file));
        end
    end
    return fList
end


"""
	$(SIGNATURES)

Make a list of files that occur in dir1, but not in dir2. Recurses sub-directories. Only compares file names.
"""
function files_not_in_dir2(dir1 :: AbstractString, dir2 :: AbstractString)
    fList1 = files_in_dir(dir1);
    fList2 = files_in_dir(dir2);
    missList = Vector{String}();
    for f in fList1
        if !(f ∈ fList2)
            push!(missList, f);
        end
    end
    return missList
end


"""
	$(SIGNATURES)

Report differences between two directories and their sub-directories. Based on file names only.

# Arguments
- `dir1`, `dir2`: Directories to be compared.
- `io`: where output is to be written
- `exclude`: case sensitive substrings to be excluded

# Example
```julia
dir_diff_report("my/dir1", "my/dir2"; io = stdout, exclude = ["_not", "Drop"])
```
"""
function dir_diff_report(dir1 :: AbstractString, dir2 :: AbstractString; 
    io = stdout, exclude = :nothing)
    cbd = find_common_base_dir(dir1, dir2);
    @assert !isnothing(cbd)  "Must have common base dir"
    miss2V = files_not_in_dir2(dir1, dir2);
    filter_excludes!(miss2V, exclude);
    miss1V = files_not_in_dir2(dir2, dir1);
    filter_excludes!(miss1V, exclude);
    println(io, "\nComparing files by name in base directory\n  ",  cbd);

    relDir1 = relpath(dir1, cbd);
    println(io, "Files missing in $relDir1:");
    for f in miss1V
        println(io, "  $f");
    end
    relDir2 = relpath(dir2, cbd);
    println(io, "Files missing in $relDir2:");
    for f in miss2V
        println(io, "  $f");
    end
    println(io, "----------")
end


"""
	$(SIGNATURES)

Given a vector `v`, drop entries that contain any of the values in `exclude`.
"""
function filter_excludes!(v, exclude :: AbstractVector{T}) where T
    if !isnothing(exclude)
        keepV = trues(size(v));
        for excl in exclude
            filter_excludes!(v, excl);
        end
    end
    return nothing
end

filter_excludes!(v, exclude :: AbstractString) = 
    filter!(x -> !contains(x, exclude), v);

# --------------