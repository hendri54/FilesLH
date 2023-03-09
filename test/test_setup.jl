function test_header(hdStr)
    println("-----  Testing $hdStr")
end

# function test_file_dir()
#     return joinpath(@__DIR__, "test_files")
# end

if !isdir(test_file_dir())
    mkdir(test_file_dir())
end


# ------------