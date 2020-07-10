function make_dir_test()
    @testset "Make dir" begin
        d = joinpath(test_file_dir(), "make_dir_test");
        isdir(d)  &&  rm(d);
        make_dir(d);
        @test isdir(d);
    end
end

function files_in_dir_test()
    @testset "files in dir" begin
        d = @__DIR__;
        fList = files_in_dir(d);
        @test "directories_test.jl" ∈ fList
        @test "coverage/Project.toml" ∈ fList

        @test isempty(files_not_in_dir2(d, d))

        d2 = normpath(d, "..");
        @test isequal(files_not_in_dir2(d, d2), fList)
    end
end


function find_common_base_dir_test()
    @testset "Common base dir" begin
        d1 = "/a/bc/def/ghk";
        d2 = "/a/bc/defg/ghk";
        cbd = find_common_base_dir(d1, d2);
        @test cbd == "/a/bc"

        @test find_common_base_dir([d1, d2]) == cbd
    end
end



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

    files_in_dir_test()
    find_common_base_dir_test()
end

# -------------