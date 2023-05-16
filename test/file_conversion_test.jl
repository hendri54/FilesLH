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

function compare_images_test()
    @testset "Compare images" begin
        d1 = joinpath(test_file_dir(), "testdir1");
        d2 = joinpath(test_file_dir(), "testdir2");
        # convertDir = joinpath(test_file_dir(), "convert_dir");
        convertDir = nothing;
        relConvertDir = "bitmaps";
        fExt = "html";
        comparisonFn = joinpath(test_file_dir(), "convert_dir", 
            "file_compare." * fExt);
        isfile(comparisonFn)  &&  rm(comparisonFn);
        compare_images(d1, d2, comparisonFn; 
            pattern = "*.pdf", tgExt = ".png",
            headerV = ["Header 1", nothing],
            # browserApp = nothing, 
            convertDir, relConvertDir);
        @test isfile(comparisonFn); 
    end
end

@testset "File conversion" begin
    for fExt in ("png", "jpg")
        file_conversion_test(fExt);
    end
    compare_images_test();
end

# ----------------