using FilesLH, Test

function make_dir_test()
    @testset "Make dir" begin
        d = joinpath(test_file_dir(), "make_dir_test");
        isdir(d)  &&  rm(d);
        make_dir(d);
        @test isdir(d);

        pd = parent_dir(d);
        @test isdir(pd);
    end
end


function list_sub_dirs_test()
    @testset "List sub dirs" begin
        @test isnothing(list_sub_dirs("/not/a dir"));

        d = parent_dir(test_file_dir());
        dList = list_sub_dirs(d);
        @test !isnothing(dList);
        for fDir in dList
            @test isdir(fDir);
        end

        fDir = joinpath(test_file_dir(), "empty_dir");
        isdir(fDir)  ||  mkpath(fDir);
        @test isnothing(list_sub_dirs(fDir));
    end
end


function right_dirs_test()
    @testset "Parent dirs" begin
        @test right_dirs("abc", 1) == "abc"
        @test right_dirs("/abc", 1) == "abc"
        @test right_dirs("/abc", 2) == "/abc"
        @test right_dirs("abc/def", 1) == "def"
        @test right_dirs("abc/d/ef/", 2) == "d/ef"
        @test right_dirs("abc/d/ef/", 4) == "abc/d/ef"
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


# This test just the filtering of excluded strings. 
# Should also test `dir_diff_report` directly +++
function filter_excludes_test()
    @testset "filter excludes" begin
        v = ["a", "abc", "abcdef", "cdefg"];
        v2 = copy(v);
        FilesLH.filter_excludes!(v2, "cb");
        @test v == v2

        FilesLH.filter_excludes!(v2, "ab");
        @test v2 == v[[1,4]];

        v2 = copy(v);
        FilesLH.filter_excludes!(v2, ["ab", "ba"]);
        @test v2 == v[[1,4]];
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

    right_dirs_test();
    files_in_dir_test();
    list_sub_dirs_test();
    find_common_base_dir_test()
    filter_excludes_test();
end

# -------------