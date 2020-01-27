function file_transfer_test()
    @testset "File transfer" begin
        srcDir = "/Users/lutz/Documents/temp";
        tgDir = "/nas/longleaf/home/lhendri/Documents/temp"

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