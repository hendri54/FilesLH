"""
	$(SIGNATURES)

Copy a file between local and remote computer using `scp`.

Syntax

	`scp /path/local lhendri@longleaf.unc.edu/path/remote`

# Arguments
- sshStr :: String
	e.g. "lhendri@longleaf.unc.edu"
"""
function remote_copy(localPath :: String, remotePath :: String, sshStr :: String,
	upDown :: Symbol; trialRun :: Bool = false)

	if upDown == :up
		rcCmd = `scp $localPath $sshStr$remotePath`
	elseif upDown == :down
		rcCmd = `scp $sshStr$localPath $remotePath`
	else
		error("Invalid direction: $upDown")
	end
	if trialRun
		println(rcCmd)
	else
		run(rcCmd)
	end
	return rcCmd
end


"""
    $(SIGNATURES)

Rsync to or from remote machine.

Fails if local or remote paths contain spaces.

# Arguments
- srcDirIn, tgDirIn :: String
    Source and target directories.
    Remote directory must include part required for `ssh` (e.g. `lhendri@longleaf.unc.edu:`)
- `doDelete` :: Bool
    Should orphan files be deleted on target? `True` by default.

#ToDo: How to make the interpolation work when there are quotes around the objects?
#ToDo: Hard wired file separator
"""
function rsync_command(srcDirIn :: String, tgDirIn :: String;
    trialRun :: Bool = false, doDelete :: Bool = true)

	# This ensures that `srcDir` ends in `/`
    srcDir = joinpath(srcDirIn, "");
    @assert srcDir[end] == '/'

    # Ensure that remote dir does NOT end in "/"
    tgDir = tgDirIn;
    if tgDir[end] == '/'
    	tgDir = tgDir[1 : (end-1)];
    end

    # Need to concatenate commands, not strings for interpolation to work.
    if doDelete
        deleteStr = ` --delete`;
    else
        deleteStr = ``;
    end
    if trialRun
        trialStr = ` -n`;
    else
        trialStr = ``;
    end

    switchStr = `-atuzv $trialStr $deleteStr`;

    cmdStr = `rsync $switchStr --exclude .git $srcDir $tgDir`;
	return cmdStr
end


"""
	$(SIGNATURES)

Transfer a directory to remote using rsync.
"""
function rsync_dir(srcDir :: String, tgDir :: String; 
    trialRun :: Bool = false, doDelete :: Bool = true)

	rCmd = rsync_command(srcDir,  tgDir,  trialRun = trialRun,  doDelete = doDelete);
	show(rCmd);
	# `trialRun` is built into the command
    run(rCmd);
    return rCmd
end


"""
	$(SIGNATURES)

Upload a repo to git.
"""
function git_upload_dir(repoDir :: String; trialRun :: Bool = false)
    @assert isdir(repoDir);
    addCmd = Cmd(`git add .`, dir = repoDir);
    commitCmd = Cmd(`git commit -am "update"`, dir = repoDir);
    pushCmd = Cmd(`git push origin master`, dir = repoDir);
    success = true;

    if trialRun
        println(addCmd);
        println(commitCmd);
        println(pushCmd);
    else
        run(addCmd)
        # Commit fails if there is nothing to commit
        try
            run(commitCmd);
            run(pushCmd);
        catch
            @warn "git commit failed"
            success = false;
        end
    end
    return success
end

# -------------