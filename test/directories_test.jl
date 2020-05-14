@testset "Directories" begin
    tgDir = joinpath(test_file_dir(), "clear_dir_test");
    isdir(tgDir) || mkpath(tgDir);
    tgFile = joinpath(tgDir, "test.txt");
    open(tgFile, "w") do io
        println(io, "test");
    end
    @test !is_dir_empty(tgDir)

    clear_directory(tgDir; askFirst = false);
    @test isdir(tgDir)
    @test is_dir_empty(tgDir)
end

# -------------