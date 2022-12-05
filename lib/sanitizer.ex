defmodule Sanitizer do 
  @moduledoc """
  Spaces are removed
  """
  def sanitize_source(file_content) do
    trimmed_content = String.trim(file_content) 
    Regex.split(~r/\s+/, trimmed_content) 
  end
end
