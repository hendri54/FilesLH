
# """
# 	$(SIGNATURES)
	
# Write sbatch file to local machine

# IN
# 	filePath
# 		path for the sbatch file
# 	juliaCmd
# 		Julia commands to be written after 
# OUT
# 	filePath
# 		path that was actually written
# """
# function write_sbatch_file(filePath :: String, cmdPath :: String, 
# 	sbatchCmdV :: Vector{String})

# 	if isempty(dirname(filePath))
# 		filePath = joinpath(sbatch_dir(compName = defaultLocal),  filePath);
# 	end

# 	lineV = sbatch_commands(outPath;
# 		timeStr = timeStr,  nNodes = nNodes,  nCores = nCores,  memPerCpu = memKB);

# 	open(filePath, "w") do io
# 		for line in lineV
# 			write(io, line);
# 		end
# 		write(io, "julia '$cmdPath' \n")
# 	end
	
# 	return filePath
# end


"""
	$(SIGNATURES)

Write the `#SBATCH` portion of an sbatch file and the "export number of threads" command.

# Arguments
- outPath :: String
	path where output of the run will be written
- timeStr :: String
	e.g. "3-00" for 3 days
- memPerCpu :: Int
	in KB
"""
function sbatch_commands(outPath :: String;
	timeStr :: String = "3-00",  nNodes :: Int = 1,  nCores :: Int = 1,  memPerCpu :: Int = 16000,
	emailStr = "lhendri@email.unc.edu")

	lineV = [
		"#!/bin/bash \n\n",
		"#SBATCH -N $nNodes \n", 
		"#SBATCH -n $nCores \n",
		"#SBATCH -t $timeStr \n",
		"#SBATCH -p general \n",
		"#SBATCH --mem-per-cpu $memPerCpu \n",
		"#SBATCH -o '$outPath' \n",
		"#SBATCH --mail-type=end \n",
		"#SBATCH --mail-user=$emailStr \n",
		"\n",
		"export JULIA_NUM_THREADS=$nCores \n"
	];
	return lineV
end

# ----------