defmodule LexerTest do
  use ExUnit.Case
  doctest Lexer

  setup_all do
    {:ok,
     tokens: [
       :int_keyword,
       :main_keyword,
       :open_paren,
       :close_paren,
       :open_brace,
       :return_keyword,
       {:constant, 2},
       :semicolon,
       :close_brace
     ]}
  end

  # tests to pass
  test "return 2", state do
    code = """
      int main() {
        return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == state[:tokens]
  end

  test "return 0", state do
    code = """
      int main() {
        return 0;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 6, fn _ -> {:constant, 0} end)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "multi_digit", state do
    code = """
      int main() {
        return 100;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 6, fn _ -> {:constant, 100} end)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "new_lines", state do
    code = """
    int
    main
    (
    )
    {
    return
    2
    ;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == state[:tokens]
  end

  test "no_newlines", state do
    code = """
    int main(){return 2;}
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == state[:tokens]
  end

  test "spaces", state do
    code = """
    int   main    (  )  {   return  2 ; }
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == state[:tokens]
  end

  test "elements separated just by spaces", state do
    assert Lexer.scan_words(["int", "main(){return", "2;}"]) == state[:tokens]
  end

  test "function name separated of function body", state do
    assert Lexer.scan_words(["int", "main()", "{return", "2;}"]) == state[:tokens]
  end

  test "everything is separated", state do
    assert Lexer.scan_words(["int", "main", "(", ")", "{", "return", "2", ";", "}"]) ==
             state[:tokens]
  end

  # tests to fail
    test "wrong case return", state do
    code = """
    int main() {
      RETURN 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 5, fn _ -> :error end)
    assert Lexer.scan_words(s_code) == expected_result
  end
  
  test "wrong case int", state do
    code = """
    INT main() {
      return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 0, fn _ -> :error end)
    assert Lexer.scan_words(s_code) == expected_result
  end
  
  test "wrong char closing paren", state do
    code = """
    int main(] {
      return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 3, fn _ -> :error end)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "wrong char opening brace", state do
    code = """
    int main() [
      return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 4, fn _ -> :error end)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "wrong char closing brace", state do
    code = """
    int main() {
      return 2;
    ]
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 8, fn _ -> :error end)
    assert Lexer.scan_words(s_code) == expected_result
  end
  
  test "wrong char semicolon", state do
    code = """
    int main() {
      return 2:
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 7, fn _ -> :error end)
    assert Lexer.scan_words(s_code) == expected_result
  end
  
  test "no semicolon", state do
    code = """
    int main() {
      return 2
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = Enum.filter(List.update_at(state[:tokens], 7, fn _-> nil end), & !is_nil(&1))
    assert Lexer.scan_words(s_code) == expected_result
  end
  
  test "no opening brace", state do
    code = """
    int main() 
      return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = Enum.filter(List.update_at(state[:tokens], 4, fn _-> nil end), & !is_nil(&1))
    assert Lexer.scan_words(s_code) == expected_result
  end
  
    test "no closing brace", state do
    code = """
    int main() {
      return 2;
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = Enum.filter(List.update_at(state[:tokens], 8, fn _-> nil end), & !is_nil(&1))
    assert Lexer.scan_words(s_code) == expected_result
  end
  
  test "no retval", state do
    code = """
    int main() {
      return ;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = Enum.filter(List.update_at(state[:tokens], 6, fn _-> nil end), & !is_nil(&1))
    assert Lexer.scan_words(s_code) == expected_result
  end
  
  test "no open paren", state do
    code = """
    int main) {
      return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = Enum.filter(List.update_at(state[:tokens], 2, fn _-> nil end), & !is_nil(&1))
    assert Lexer.scan_words(s_code) == expected_result
  end
  
  test "no close paren", state do
    code = """
    int main( {
      return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = Enum.filter(List.update_at(state[:tokens], 3, fn _-> nil end), & !is_nil(&1))
    assert Lexer.scan_words(s_code) == expected_result
  end
  
  test "no space", state do
    code = """
    int main() {
      return2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 9, fn _-> nil end)
    assert Lexer.scan_words(s_code) == expected_result
  end
  
end
