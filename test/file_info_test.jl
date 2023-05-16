using Dates, Test, FilesLH;

function file_info_test()
    @testset "File Info" begin
        fPath = joinpath(test_file_dir(), "fi_test.txt");
        open(fPath, "w") do io
            println(io, "Test file");
        end
        tCreated = date_modified(fPath);

        @test Dates.value(Dates.now() - tCreated) > 0;
        @test Dates.value(Dates.now() - tCreated) < 10_000; # milliseconds

        s = seconds_since_modified(fPath);
        @test 0 <= s < 5;
    end
end

@testset "File info" begin
    file_info_test();
end

# ------------------