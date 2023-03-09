function file_conversion_test(fExt)
    @testset "File conversion $fExt" begin
        dir1 = joinpath(test_file_dir(), "file_conversions");
        inFile = joinpath(dir1, "ad_shock_negative.pdf");
        @test isfile(inFile);
        outFile = joinpath(dir1, "pdf_to_png." * fExt);
        isfile(outFile)  &&  rm(outFile);
        convert_file(inFile, outFile);
        @test isfile(outFile);
    end
end

@testset "File conversion" begin
    for fExt in ("png", "jpg")
        file_conversion_test(fExt);
    end
end

# ----------------