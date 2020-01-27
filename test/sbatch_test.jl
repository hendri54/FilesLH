function sbatch_test()
	@testset "sbatch" begin
		filePath = joinpath(test_file_dir(), "sbatch_test.sl");
		if isfile(filePath)
			rm(filePath);
		end
		cmdPath = joinpath(test_file_dir(), "test1.jl");
		outPath = joinpath(test_file_dir(), "test1.out");
		timeStr = "7-00";
		
		lineV = sbatch_commands(outPath, timeStr = timeStr);
		@test isa(lineV, Vector{String})
		@test length(lineV) > 5

		# write_sbatch_file(filePath, cmdPath, outPath,  timeStr = timeStr);
		# @test isfile(filePath)
		
		# # Show on screen
		# println("------------")
		# for line in eachline(filePath)
		# println(line)
	end
end