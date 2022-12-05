defmodule Lexer do
  @moduledoc """
  Documentation for the Lexer
  The Lexer receive a linked list of words provided by the sanitizer
  to return a list of tokens according to the words it identifies
  """

  #Identify and flatten the list of words according to the list of defined tokens
  def scan_words(words) do
    Enum.flat_map(words, &lex_raw_tokens/1)
  end

  #It is responsible for determining the value of the constant that the program returnsby assigning token :constant and the numerical value.
  #For the regular expression /^\d+/ Matches the beginning of the entry one or more digits. Replace the string constant with its numeric representation.
  def get_constant(program) do
    #Provides regular expressions ~r/  /.
    case Regex.run(~r/^\d+/, program) do
      #trim_leading returns a string with all value characters removed
      [value] ->
        {{:constant, String.to_integer(value)}, String.trim_leading(program,value)}
      program ->
        {:error, "Token not valid: #{program}"}
    end
  end

  def get_negative(program) do
    case Regex.run(~r/^\d+/, program) do
      #trim_leading returns a string with all value characters removed
      [value] ->
        {{:negative, -1*String.to_integer(value)}, String.trim_leading(program, value)}
      program ->
        {:error, "Token not valid: #{program}"}
    end
  end

  def get_complement(program) do
    #Provides regular expressions ~r/  /.
    cmp=fn(program)-> #Defino una funcion anonima
      Regex.run(~r/^\d+/, program)
      |>List.first #Obtengo el primer elemento de la lista
      |>String.to_integer() #Lo convierto de string a entero
      |>Integer.digits(2) #Lo convierto de integer a list base 2
      |>Enum.map(fn x -> if x == 0, do: "z", else: x end)
      |>Enum.map(fn x -> if x == 1, do: "y", else: x end)
      |>Enum.map(fn x -> if x == "z", do: 1, else: x end) #me paso la misma funcion para saber donde cambiar
      |>Enum.map(fn x -> if x == "y", do: 0, else: x end)
      |>Integer.undigits #convierto a integer la lista para poder juntarla
      |>Integer.to_string #convierto de integer a string
      |>Integer.parse(2) #covierto mi string binaria a decimal
      |>elem(0)
      |>Integer.to_string
    end
    case Regex.run(~r/^\d+/, program) do
      #trim_leading returns a string with all value characters removed
      [value] ->
        {{:complement, String.to_integer(cmp.(program))}, String.trim_leading(program,value)}
      program ->
        {:error, "Token not valid: #{program}"}
    end
  end

  def get_logic(program) do #implementar logicos negativos
    [value] = Regex.run(~r/^\d+/, program)
    if Regex.run(~r/^\d+/, program) == ["0"] do #regex regresa una lista con la cadena programa
      {{:logic, 1}, String.trim_leading(program, value)} #Regresar siempre un diccionario y la lista siguiente
    else
      if Regex.run(~r/^\d+/, program) != ["0"] do
        {{:logic, 0}, String.trim_leading(program, value)}
      else
        {:error, "Token not valid: #{program}"}
      end
    end
  end

  #Compare the symbols found with the tokens for each found token add its atom to the output list
  def lex_raw_tokens(program) when program != "" do
    {token, rest} =
      case program do
        "{" <> rest ->
          {:open_brace, rest}

        "}" <> rest ->
          {:close_brace, rest}

        "(" <> rest ->
          {:open_paren, rest}

        ")" <> rest ->
          {:close_paren, rest}

        ";" <> rest ->
          {:semicolon, rest}

        "-" <> rest ->
          {:negative, rest}

        "~" <> rest ->
          {:complement, rest}

        "!" <> rest ->
          {:logic, rest}

        "int" <> rest ->
          {:int_keyword, rest}

        "return" <> rest ->
          {:return_keyword, rest}

        "main" <> rest ->
          {:main_keyword, rest}

        rest ->
          get_constant(rest)
      end

    if token != :error do
      remaining_tokens = lex_raw_tokens(rest)
      #Add token to the collection
      [token | remaining_tokens]
    else
      [:error]
    end
  end

  #Output list that will have all the tokens in the order they were found.
  def lex_raw_tokens(_program) do
    []
  end
end
