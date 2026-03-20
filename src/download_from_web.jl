"""
    $(SIGNATURES)

Downloads an image from the given `url`, saves it to `outdir`, and adds
the URL and download date to its EXIF metadata and Finder comments (macOS only).
Finder comments are NOT visible in Finder (but they are there).
"""
function download_with_metadata(url::String, outDir::String; newFn = nothing)
    # Extract file name from URL
    if isnothing(newFn)
        filename = last(split(url, '/'));
    else
        filename = newFn;
    end
    filepath = joinpath(outDir, filename);
    isdir(outDir) || mkdir(outDir);

    # Download the image
    Downloads.download(url, filepath);
    @assert isfile(filepath);

    # Get the current date
    download_date = Dates.format(Dates.now(), "yyyy-mm-dd");

    # Construct metadata comment
    comment = "Downloaded from $url on $download_date";

    # Write EXIF metadata using exiftool
    # run(`exiftool -overwrite_original -Comment=$comment $filepath`)
    run(`exiftool -XMP-dc:Source=$comment $filepath`);

    # Write Finder comment using xattr (macOS only)
    try
        run(`xattr -w com.apple.metadata:kMDItemFinderComment "$comment" $filepath`);
    catch e
        @warn "Failed to set Finder comment (requires macOS and compatible file type)" exception = e
    end

    return filepath
end


"""
    $(SIGNATURES)

Read the source of a file from its metadata. Source metadata usually generated with `download_with_metadata`.
"""
function get_file_source(filepath::String)
    @assert isfile(filepath);
    cmd = `exiftool -Source -s3 $(filepath)`;
    try
        output = read(cmd, String);
        stripped = strip(output);
        return isempty(stripped) ? nothing : stripped;
    catch e
        @warn "Failed to read metadata: $e";
        return nothing
    end
end

# --------------