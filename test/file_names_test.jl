function fn_test()
    @test isa(filesep(), Char);

    @test paths_equal("abc", "abc/")
    @test !paths_equal("abc", "abcd")

    fPath = "/abd/def.txt";
    @test change_extension(fPath, "doc") == "/abd/def.doc"
    @test change_extension(fPath, ".doc") == "/abd/def.doc"
    @test change_extension("/abc/def", "doc") == "/abc/def.doc"

    @test add_extension(fPath, ".new") == fPath
    @test add_extension("abc/def", "txt") == "abc/def.txt"

    @test extensions_equal("txt", ".txt")
    @test !extensions_equal(".txt", ".txt2")

    @test has_extension("abc/def.txt", ".txt")
    @test has_extension("abc/def.txt", "txt")
    @test !has_extension("abc/def.txt", "txt2")
end


@testset "File names" begin
    fn_test()
end

# --------------