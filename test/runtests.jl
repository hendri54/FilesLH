using FilesLH
using Test

# ------------  Helpers

include("test_setup.jl")

# --------  Tests

include("file_transfer_test.jl");
include("file_conversion_test.jl");
include("computer_test.jl")
include("sbatch_test.jl")

@testset "FilesLH" begin
    file_transfer_test()
    computer_test()
    sbatch_test()
    include("directories_test.jl")
    include("file_names_test.jl")
end

# ----------------