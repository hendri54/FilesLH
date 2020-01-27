"""
	Computer
"""
@with_kw struct Computer
	name :: Symbol
	homeDir :: String
	sshStr :: String = ""
	isRemote :: Bool = true
end

computerLH = Computer(name = :LH, homeDir = "/Users/lutz", isRemote = false);

computerLongleaf = Computer(name = :longleaf, 
	homeDir = "/nas/longleaf/home/lhendri",
	sshStr = "lhendri@longleaf.unc.edu",
	isRemote = true);


"""
	$(SIGNATURES)

List of known computers. Can be changed for each project.
"""
mutable struct ComputerList
	cList :: Dict{Symbol, Computer}
end

defaultCompList = ComputerList(Dict([:LH => computerLH,  :longleaf => computerLongleaf]));


# -------------  List of known computers

"""
	$(SIGNATURES)

Add a computer to the list.
If computer exists, it is replaced.
"""
function add_computer(newComp :: Computer;  compList :: ComputerList = defaultCompList)
	if haskey(compList.cList, newComp.name)
		doReplace = true;
		@warn "Computer $(newComp.name) exists. Will be replaced in computer list."
	else
		doReplace = false;
	end
	compList.cList[newComp.name] = newComp;
	return doReplace
end


"""
	$(SIGNATURES)

Remove computer from list of known computers.
"""
function remove_computer(comp :: Computer;  compList :: ComputerList = defaultCompList)
	if haskey(compList.cList, comp.name)
		compExists = true;
		delete!(compList.cList, comp.name);
	else
		compExists = false;
	end
	return compExists
end


"""
	$(SIGNATURES)

Return a `Computer` from its name (or :current).
"""
function get_computer(compName :: Symbol = :current;  compList :: ComputerList = defaultCompList)
	if compName == :current
		return current_computer();
	else
		return compList.cList[compName];
	end
end

# Pass through method
function get_computer(comp :: Computer;  compList :: ComputerList = defaultCompList)
	return comp
end


"""
	$(SIGNATURES)

Determine current computer.
"""
function current_computer(; compList :: ComputerList = defaultCompList)
	found = false;
	outComp = computerLH;
	for (k, comp) in compList.cList
		if isdir(comp.homeDir)
			found = true;
			outComp = comp;
			break
		end
	end
	@assert found  "Current computer unknown"
	return outComp
end


"""
	$(SIGNATURES)

Running on local or remote computer?
"""
function run_local(; compList :: ComputerList = defaultCompList)
	comp = current_computer(compList = compList);
    return !comp.isRemote
end


"""
	$(SIGNATURES)

Home directory.
"""
function home_dir(compIn; compList :: ComputerList = defaultCompList)
	comp = get_computer(compIn, compList = compList);
	return home_dir(comp);
end


"""
	$(SIGNATURES)

Is this computer a remote or local computer?
"""
function is_remote(compIn; compList :: ComputerList = defaultCompList)
	comp = get_computer(compIn, compList = compList);
	return comp.isRemote
end


# -----------  Computer properties

"""
	$(SIGNATURES)

Computer's home directory.
"""
function home_dir(comp :: Computer)
	return comp.homeDir
end


function is_remote(comp :: Computer)
	return comp.isRemote
end


# -------------