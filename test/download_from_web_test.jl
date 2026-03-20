using FilesLH, Test

function download_metadata_test()
    @testset "Download metadata" begin
       fUrl = "https://econofact.org/wp-content/uploads/2017/04/CB_IndependenceAE.png";
       outDir = test_file_dir();
       fn = "download_metadata_test.png";
       newPath = joinpath(outDir, fn);
       isfile(newPath)  &&  rm(newPath);
       fPath = download_with_metadata(fUrl, outDir; newFn = fn); 
       @test isfile(fPath);
       src = get_file_source(fPath);
       @test contains(src, fUrl);
    end
end

@testset "Download from web all" begin
    download_metadata_test();
end

# ---------------