using FilesLH
using Test

# ------------  Helpers

function test_header(hdStr)
    println("-----  Testing $hdStr")
end

function test_file_dir()
    return joinpath(@__DIR__, "test_files")
end

if !isdir(test_file_dir())
    mkdir(test_file_dir())
end


# --------  Tests

include("file_transfer_test.jl")
include("computer_test.jl")
include("sbatch_test.jl")

@testset "FilesLH" begin
    file_transfer_test()
    computer_test()
    sbatch_test()
end

# ----------------