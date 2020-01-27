using FilesLH
using Test

function test_header(hdStr)
    println("-----  Testing $hdStr")
end


include("file_transfer_test.jl")
include("computer_test.jl")

@testset "FilesLH" begin
    file_transfer_test()
    computer_test()
end

# ----------------