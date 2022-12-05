defmodule Linker do
  @moduledoc """
  assembly_path: Assembler file path
  gcc return_2.c -o return_2 : System.cmd("gcc", [assembly_file_name, "-o {binary_file_name}"], cd: output_dir_name)
  This function can be improved
  """
  def generate_binary(assembler, assembly_path) do
    assembly_file_name = Path.basename(assembly_path) 
    binary_file_name = Path.basename(assembly_path, ".s") 
    output_dir_name = Path.dirname(assembly_path) 
    assembly_path = output_dir_name <> "/" <> assembly_file_name 

    File.write!(assembly_path, assembler) 
    System.cmd("as", [assembly_file_name, "-o#{binary_file_name}"], cd: output_dir_name)
    #File.rm!(assembly_path) #Delete the file created at the start

    IO.puts("\n"<> binary_file_name <> " compiled succesfully!")
  end
end
