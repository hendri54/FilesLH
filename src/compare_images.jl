"""
	$(SIGNATURES)

View files matching a pattern in two directories side-by-side.
Creates a markdown files with image links for all files. Opens the file in Marked.

# Arguments
- `d1, d2`: Directories to be compared.
- `pattern`: `Glob` pattern.
- `maxNumber`: maximum number of files to show.
- `dropFilesWithoutMatches`: if true, only show files that occur in both directories. If not, show placeholder for missing files.
"""
function compare_images(d1, d2; pattern = "*.pdf", maxNumber = 20,
        dropFilesWithoutMatches = true)
    fList = make_file_list(d1, d2; pattern, dropFilesWithoutMatches);
    if isempty(fList)
        @info "Nothing to show."
    else
        mdFn = write_markdown_file(d1, d2, fList; maxNumber);
        show_viewer(mdFn);
    end
end

function make_file_list(d1, d2; pattern = "*.pdf", dropFilesWithoutMatches = true)
    @assert isdir(d1);
    @assert isdir(d2);
    fl1 = matching_filenames(d1, pattern);
    fl2 = matching_filenames(d2, pattern);
    if dropFilesWithoutMatches
        fList = intersect(fl1, fl2);
    else
        fList = union(fl1, fl2);
    end
    return fList
end

# Glob, but only returning file names
function matching_filenames(d, pattern)
    return split_filename.(glob(pattern, d))
end

split_filename(fPath) = last(splitdir(fPath));

function write_markdown_file(d1, d2, fList; maxNumber = 20)
    fn = markdown_fn(d2);
    open(fn, "w") do io
        for j = 1 : min(length(fList), maxNumber)
            write_file_entry(io, d1, d2, fList[j]);
        end
    end
    return fn
end

markdown_fn(dir1) = joinpath(dir1, "file_compare.md");

function write_file_entry(io, d1, d2, fn)
    write(io, image_header(fn));
    for dir1 in (d1, d2)
        fPath = joinpath(dir1, fn);
        if isfile(fPath)
            imgStr = image_entry(fPath);
        else
            imgStr = blank_image_entry(fPath);
        end
        write(io, imgStr);
    end
end

function image_header(fPath)
    fn = split_filename(fPath);
    return "**$fn** \n";
end

function image_entry(fPath)
    return """<img src="$fPath" width="550">"""
end

blank_image_entry(fPath) = "No image";


function show_viewer(mdFn)
    fn = split_filename(mdFn)
    @info "Showing viewer for $fn"
    run(`open -a "Marked 2" "$mdFn"`);
end

# -----------------------------