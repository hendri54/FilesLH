module FilesLH

using ArgCheck, Dates, DelimitedFiles, DocStringExtensions, Downloads, Glob, Parameters;
using TimeZones;
import Base.show
import CommonLH: ask_yes_no

# Directories
export clear_directory, is_dir_empty, files_in_dir, files_not_in_dir2;
export find_common_base_dir, dir_diff_report, make_dir, right_dirs;
export list_sub_dirs, parent_dir;
# File info
export date_modified, seconds_since_modified;
# File names
export add_extension, change_extension, has_extension, extensions_equal, filesep, paths_equal
# File transfer
export remote_copy, rsync_command, rsync_dir, git_upload_dir, make_remote_dir, deploy_docs;
export download_with_metadata, get_file_source;
# Computers
export Computer, computerLH, computerLongleaf
export home_dir, run_local, is_remote, common_base_dir, remote_and_local_path
export ComputerList, defaultCompList
export add_computer, remove_computer, current_computer, get_computer
# Slurm
export sbatch_commands
# Compare images
export compare_images;
# File conversions
export convert_file;
# Test
export test_file_dir, test_dir;

# --- Merged from LatexLH ---
# Beamer
export write_beamer_header, write_beamer_footer, typeset_file
export write_figure_slide, figure_slide, table_slide;
# Tables
export CellColor, Cell
export add_row!, color_string, cell_string, nrows, write_table
# Parameter table
export ParameterTable
export add_row!
# SymbolTable
export SymbolTable, SymbolInfo
export add_symbol!, has_symbol, newcommand, description, group, latex, load_from_csv!, erase!
export write_preamble, write_notation_tex
# Writing tex files and their pieces
export write_doc, doc_header, doc_footer;
export figure_comparison;
export latex_table, latex_section, latex_figures, latex_figure, latex_line;
export figures_side_by_side;

include("computers.jl");
include("directories.jl");
include("file_info.jl");
include("file_names.jl");
include("file_transfer.jl");
include("compare_images.jl");
include("file_conversion.jl");
include("download_from_web.jl");
include("sbatch.jl");

# --- Merged from LatexLH ---
include("pieces.jl");
include("write_doc.jl");
include("table.jl");
include("parameter_table.jl");
include("symbol_info.jl");
include("symbol_table.jl");
include("beamer.jl");

function test_file_dir()
    normpath(joinpath(@__DIR__, "..", "test", "test_files"));
end

test_dir() = test_file_dir();

end # module
