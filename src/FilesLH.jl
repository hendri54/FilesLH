module FilesLH

using ArgCheck, DocStringExtensions, Parameters
import Base.show

# File transfer
export remote_copy, rsync_command, rsync_dir, git_upload_dir
# Computers
export Computer, computerLH, computerLongleaf
export home_dir, run_local, is_remote
export ComputerList, defaultCompList
export add_computer, remove_computer, current_computer

include("file_transfer.jl")
include("computers.jl")

end # module
