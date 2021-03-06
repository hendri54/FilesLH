"""
	$(SIGNATURES)

Deploy package docs to my website.

This is to be included in each package's `make.jl`. The benefit over hosting on github is to work around issues with private repos and private registries that would arise when TravisCI is used.

# Example
```
# This gives the package directory, if called from `docs/make.jl`.
pkgDir = rstrip(normpath(@__DIR__, ".."), '/');
@assert endswith(pkgDir, "FilesLH")
deploy_docs(pkgDir);
```

# Arguments
- `pkgDir`: points to package directory. If `pkgDir = /a/b/Foo` the docs end up in `julia/Foo` on my website.
"""
function deploy_docs(pkgDir :: AbstractString; 
    trialRun :: Bool = false,
    tgBaseDir :: AbstractString = "/Users/lutz/Documents/data/web/hendri54.github.io/julia/")

    pkgName = basename(pkgDir);
    srcDir = joinpath(pkgDir, "docs", "build");
    @assert isdir(srcDir);
    tgDir = joinpath(tgBaseDir, pkgName);
    cm = rsync_command(srcDir, tgDir; trialRun = trialRun,
        doDelete = true,  inclSubDirs = true);
    run(cm);
end


"""
	$(SIGNATURES)

Given a path and several base directories, return that path hanging off each of the base directories.

# Arguments
- srcPath :: String
    Absolute or relative path. If absolute, it must include one of the base directories.
"""
function common_base_dir(srcPath :: String, baseDirV :: Vector{String})
    @assert length(baseDirV) >= 1
    @assert all(isabspath.(baseDirV)) "All base directories must be absolute paths"

    # Find which baseDir we match.
    relPath = "";
    if isabspath(srcPath)
        found = false;
        for baseDir in baseDirV
            if startswith(srcPath, baseDir)
                relPath = relpath(srcPath, baseDir);    	
                found = true;
                break;
            end
        end
        if !found
			error("srcPath must be inside a base directory:  $srcPath")
        end
    else
        relPath = srcPath;
    end
    
    outDirV = similar(baseDirV);
    for (j, baseDir) in enumerate(baseDirV)
        outDirV[j] = joinpath(baseDir, relPath);
    end

	return outDirV
end


"""
	$(SIGNATURES)

Make a pair of local and remote paths, both in the same location relative to homedir().

# Arguments
- srcPath
	can be absolute path on either machine or relative to `homedir()`
"""
function remote_and_local_path(srcPath :: String; 
	srcComp = defaultLocal,  tgComp = defaultRemote)
	
	srcComp = get_computer(srcComp);
    tgComp = get_computer(tgComp);
    
    outDirV = common_base_dir(srcPath,  [srcComp.homeDir, tgComp.homeDir]);
    localDir = outDirV[1];
    remoteDir = outDirV[2];
	
	# # Make path relative to home on whatever machine it matches.
    # if isabspath(srcPath)
    # 	if startswith(srcPath, srcComp.homeDir)
	# 		srcPath = relpath(srcPath, srcComp.homeDir);    	
	# 	elseif startswith(srcPath, tgComp.homeDir)
	# 		srcPath = relpath(srcPath, tgComp.homeDir);    	
	# 	else
	# 		error("srcPath must be inside home directory:  $srcPath")
	# 	end
	# end

    # localDir = joinpath(srcComp.homeDir, srcPath);
    # remoteDir = joinpath(tgComp.homeDir, srcPath);
	return localDir, remoteDir
end


"""
	$(SIGNATURES)

Make a directory on the remote, optionally creating all parents as well.
Creates a command of the form
`ssh lhendri@longleaf.unc.edu 'mkdir -p ~/home/abc'`.
Shows on-screen error if the directory already exists.

Generates on-screen output from ssh login.

Note that other shell commands can be run with the same syntax.

See https://unix.stackexchange.com/questions/8612/programmatically-creating-a-remote-directory-using-ssh

# Arguments
- `sshStr`: e.g. "lhendri@longleaf.unc.edu
"""
function make_remote_dir(remoteDir :: String,  sshStr :: String;
    trialRun :: Bool = false, createParents :: Bool = true)

    if createParents
        pStr = " -p";
    else
        pStr = " ";
    end
    rcCmd = `ssh $sshStr mkdir $pStr $remoteDir`;

    if trialRun
        println(rcCmd);
    else
        run(rcCmd);
    end
    return rcCmd
end


"""
	$(SIGNATURES)

Copy a file between local and remote computer using `scp`.
`scp` replaces existing files without warning.

Syntax

	`scp /path/local lhendri@longleaf.unc.edu:/path/remote`

# Arguments
- sshStr :: String
	e.g. "lhendri@longleaf.unc.edu"
"""
function remote_copy(localPath :: String, remotePath :: String, sshStr :: String,
	upDown :: Symbol; trialRun :: Bool = false)

	if upDown == :up
		rcCmd = `scp $localPath $(sshStr):$(remotePath)`
	elseif upDown == :down
		rcCmd = `scp $(sshStr):$(remotePath) $localPath`
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

Rsync to or from remote machine. Only for directories.

Fails if local or remote paths contain spaces.

# Arguments
- srcDirIn, tgDirIn :: String
    Source and target directories.
    Remote directory must include part required for `ssh` (e.g. `lhendri@longleaf.unc.edu:`)
- `doDelete` :: Bool
    Should orphan files be deleted on target? `False` by default.
- `trialRun` :: Bool
- `progress` :: Bool
    Show progress indicator

#ToDo: How to make the interpolation work when there are quotes around the objects?
"""
function rsync_command(srcDirIn :: String, tgDirIn :: String;
    trialRun :: Bool = false, doDelete :: Bool = false,
    doCompress :: Bool = true, verbose :: Bool = true,
    inclSubDirs :: Bool = true, progress :: Bool = false,
    excludeV = nothing)

	# This ensures that `srcDir` ends in `/`
    srcDir = joinpath(srcDirIn, "");
    @assert srcDir[end] == filesep();

    # Ensure that remote dir does NOT end in "/"
    tgDir = rstrip(tgDirIn, filesep());

    # Need to concatenate commands, not strings for interpolation to work.
    if doDelete
        deleteStr = ` --delete`;
    else
        deleteStr = ``;
    end

    # Switches
    switchV = Vector{Char}();
    trialRun  &&  push!(switchV, 'n');
    doCompress &&  push!(switchV, 'z');
    verbose &&  push!(switchV, 'v');
    inclSubDirs  &&  push!(switchV, 'a');
    progress  &&  push!(switchV, 'P');
    vecStr = *(switchV...);
    switchStr = ` -tu$vecStr `;

    exclCmd = exclude_commands(excludeV);

    cmdStr = `rsync $switchStr $deleteStr $exclCmd --exclude .git $srcDir $tgDir`;
	return cmdStr
end


exclude_commands(exclV :: Nothing) = ``;
exclude_commands(exclV :: AbstractString) = `--exclude $exclV`;
function exclude_commands(exclV) 
    if isempty(exclV) 
        return ``;
    end
    cmdV = [`--exclude $x` for x in exclV];
    return cat_commands(cmdV);
end

# function exclude_command(x)
#     return `--exclude $x`;
# end

# Concatenate several commands
function cat_commands(cmdV :: Vector{Cmd})
    if isempty(cmdV)
        return ``
    end
    c = cmdV[1];
    if length(cmdV) > 1
        for j = 2 : length(cmdV)
            c = `$c $(cmdV[j])`;
        end
    end
    return c
end


"""
	$(SIGNATURES)

Transfer a directory to remote using rsync.
`delete` is by default off.
"""
function rsync_dir(srcDir :: String, tgDir :: String; kwargs...)
    # trialRun :: Bool = false, doDelete :: Bool = false)

	rCmd = rsync_command(srcDir,  tgDir; kwargs...);
	println(rCmd);
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