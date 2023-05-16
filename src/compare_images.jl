"""
	$(SIGNATURES)

View files matching a pattern in two directories side-by-side.
Creates an html file with image links for all files. Opens the file in browser.

# Arguments
- `d1, d2`: Directories to be compared.
- `pattern`: `Glob` pattern.
- `maxNumber`: maximum number of files to show.
- `dropFilesWithoutMatches`: if true, only show files that occur in both directories. If not, show placeholder for missing files.
"""
function compare_images(d1, d2, comparisonFn; 
        pattern = "*.pdf", tgExt = ".png", maxNumber = 20,
        headerV  = nothing,
        browserApp = "Brave Browser", 
        convertDir = nothing, relConvertDir = nothing,
        dropFilesWithoutMatches = true)

    fList = make_file_list(d1, d2; pattern, dropFilesWithoutMatches);
    if isempty(fList)
        @info "Nothing to show."
    else
        fPath1V = make_path_list(d1, fList);
        fPath2V = make_path_list(d2, fList);

        _, srcExt = splitext(first(fList));
        if tgExt != srcExt
            # add option to skip existing files that are newer than input files +++++
            fPath1V = convert_files(fPath1V, tgExt, convertDir, relConvertDir);
            fPath2V = convert_files(fPath2V, tgExt, convertDir, relConvertDir);
        end

        write_html_image_file(fPath1V, fPath2V, comparisonFn; 
            headerV, maxNumber);
        if !isnothing(browserApp)
            show_viewer(comparisonFn, browserApp);
        end
    end
end




## -----------  List of files

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

split_filename(fPath :: AbstractString) = last(splitdir(fPath));

function make_path_list(d1, fnV)
    return [joinpath(d1, fn)  for fn in fnV];
end


## ----------  Convert files

function convert_files(filePathV, fExt, convertDir, relConvertDir)
    baseDir, _ = splitdir(first(filePathV));
    outDir = convert_dir(baseDir, convertDir, relConvertDir);
    isdir(outDir)  ||  mkdir(outDir);
    
    newPathV = copy(filePathV);
    for (j, fPath) in enumerate(filePathV)
        newPathV[j] = converted_path(fPath, fExt, outDir);
        convert_file(fPath, newPathV[j]);
    end
    return newPathV
end

function convert_dir(baseDir, convertDir, relConvertDir)
    if isnothing(convertDir)
        if isnothing(relConvertDir)
            outDir = baseDir;
        else
            outDir = joinpath(baseDir, relConvertDir);
        end
    else
        outDir = convertDir; 
    end
    return outDir
end

# function convert_file(srcPath, fExt, outDir)
#     outPair = [converted_path(fPath, fExt, outDir)  for fPath in filePair];
#     for (j, fPath) in enumerate(filePair)
#         convert_file(fPath, outPair[j]);
#     end
#     return outPair
# end

function converted_path(fPath, fExt, outDir)
    _, fnWithExt = splitdir(fPath);
    fn, _ = splitext(fnWithExt);
    joinpath(outDir, fn * make_extension(fExt));
end


## -----------  Write html file

function write_html_image_file(fPath1V, fPath2V, fn :: AbstractString; 
        headerV = nothing, maxNumber = 20)
    @assert size(fPath1V) == size(fPath2V);
    open(fn, "w") do io
        write_html_header(io);
        write_html_col_headers(io, headerV);
        for j = 1 : min(length(fPath1V), maxNumber)
            write_file_entry(io, fPath1V[j], fPath2V[j]);
        end
        write_html_footer(io);
    end
    return nothing
end

# html_fn(dir1) = joinpath(dir1, "file_compare.html");

function write_html_header(io)
    println(io, "<!DOCTYPE html> \n <html> \n <body>");
end

function write_html_col_headers(io, headerV)
    isnothing(headerV)  &&  return;
    print(io, "<h2>  |  ");
    for header in headerV
        if isnothing(header)
            print(io, "No header");
        else
            print(io, header);
        end
        print(io, "  |  ");
    end
    println(io, "</h2>");
end

function write_html_footer(io)
    println(io, "</body> \n </html>");
end


## ----------------  Markdown version

# function write_markdown_file(filePairV, fn :: AbstractString; maxNumber = 20)
#     # fn = markdown_fn(d2);
#     open(fn, "w") do io
#         for j = 1 : min(length(fPairV), maxNumber)
#             write_file_entry(io, filePairV[j]);
#         end
#     end
#     return fn
# end

# markdown_fn(dir1) = joinpath(dir1, "file_compare.md");

# This is HTML
function write_file_entry(io, fPath1, fPath2)
    fn = split_filename(fPath1);
    write(io, image_header(fn));
    for fPath in (fPath1, fPath2)
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
    return "<h4>$fn</h4> \n";
end

function image_entry(fPath; width = 550)
    fn = split_filename(fPath);
    return """<img src="$fPath" alt="$fn" width="$width">"""
end

function blank_image_entry(fPath; width = 550)
    fn = split_filename(fPath);
    return "Not found: $fn";
end


function show_viewer(mdFn, browserApp)
    fn = split_filename(mdFn)
    @info "Showing viewer for $fn"
    run(`open -a "$browserApp" "$mdFn"`);
end

# -----------------------------