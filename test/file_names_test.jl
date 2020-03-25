function fn_test()
    @test isa(filesep(), Char);

    @test paths_equal("abc", "abc/")
    @test !paths_equal("abc", "abcd")
end


@testset "File names" begin

end

# --------------