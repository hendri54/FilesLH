function file_transfer_test()
    @testset "File transfer" begin
        srcDir = "/Users/lutz/Documents/temp";
        tgDir = "/nas/longleaf/home/lhendri/Documents/temp"

        test_header("Common base dir")
        # Relative path
        srcPath = "abc/def.txt";
        baseDirV = ["/base/one", "/two/base", "/base/three"];
        outDirV = common_base_dir(srcPath, baseDirV);
        for j = 1 : length(baseDirV)
            @test isequal(outDirV[j],  joinpath(baseDirV[j], srcPath))
        end
        # Absolute path
        srcPathAbs = joinpath(baseDirV[2], srcPath);
        outDir2V = common_base_dir(srcPathAbs, baseDirV);
        @test all(isequal.(outDirV, outDir2V))

        # Remote and local path using Computers as inputs
        localDir, remoteDir = remote_and_local_path(srcPath,  tgComp = :longleaf);
        @test localDir == joinpath(home_dir(FilesLH.defaultLocal), srcPath)
        @test remoteDir == joinpath(home_dir(:longleaf), srcPath)
    
        # The same with full path
        localDir2, remoteDir2 = remote_and_local_path(
            joinpath(homedir(), srcPath),  tgComp = :longleaf);
        @test isequal(localDir2, localDir)
        @test isequal(remoteDir, remoteDir2)
    

        test_header("Remote copy");
        localPath = joinpath(srcDir, "temp1.txt");
        remotePath = joinpath(tgDir, "temp1.txt");
        sshStr = "lhendri@longleaf.unc.edu";
        cmdUp = remote_copy(localPath, remotePath, sshStr, :up, trialRun = true);
        @test isa(cmdUp, Cmd)
        cmdDown = remote_copy(remotePath, localPath, sshStr, :up, trialRun = true);
        @test isa(cmdDown, Cmd)


        test_header("Rsync")
        rsCmd = rsync_command(srcDir, tgDir, trialRun = true);
        @test isa(rsCmd, Cmd);

        rsCmd = rsync_dir(srcDir, tgDir, trialRun = true);
        @test isa(rsCmd, Cmd);


        test_header("Git")
        repoDir, _ = splitdir(@__DIR__);
        @test git_upload_dir(repoDir, trialRun = true);
    end
end

# --------------------