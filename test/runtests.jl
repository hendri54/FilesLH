using FilesLH
using Test

# ------------  Helpers

include("test_setup.jl")

# --------  Tests


@testset "FilesLH" begin
    include("file_transfer_test.jl");
    include("file_conversion_test.jl");
    include("computer_test.jl");
    include("sbatch_test.jl");
    include("directories_test.jl");
    include("file_names_test.jl");
    include("file_info_test.jl");
end

# ----------------