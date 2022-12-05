defmodule LexerTest do
  use ExUnit.Case
  doctest Lexer

  setup_all do
    #A tuple is defined
    {:ok,
      #A list is defined with the tentative tokens that the lexer must obtain
     tokens: [
       :int_keyword,
       :main_keyword,
       :open_paren,
       :close_paren,
       :open_brace,
       :return_keyword,
       :negative,
       :complement,
       :logic,
       {:constant, 2},
       :semicolon,
       :close_brace
     ]}
  end

  # tests to pass
  #test 1
  test "return 2", state do

    #code to tokenize
    code = """
      int main() {
        return 2;
    }
    """

    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.delete_at(state[:tokens], 6)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)

    #The result is passed to the lexer   |  It is compared with the list of tentative tokens
    assert Lexer.scan_words(s_code)     == expected_result3

    #"assert" is responsible for comparing the two expressions and if they are equal, the test is approved
  end

  #test 2
  test "return 0", state do
    #code to tokenize
    code = """
      int main() {
        return 0;
    }
    """

    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #The list is updated so that the constant 0 is expected as a token
    #The method List.updated_at() is used, indicating which list, the position of the element and the new value
    expected_result = List.update_at(state[:tokens], 9, fn _ -> {:constant, 0} end)

    expected_result1 = List.delete_at(expected_result, 6)
    expected_result2 = List.delete_at(expected_result1, 6)
    expected_result3 = List.delete_at(expected_result2, 6)

    #The sanitized code is passed to the lexer and compared to the updated list of tentative tokens
    assert Lexer.scan_words(s_code) == expected_result3
  end

  #test 3
  test "multi_digit", state do
    code = """
      int main() {
        return 100;
    }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #The list is updated so that the multi-digit constant 100 is expected as a token
    expected_result = List.update_at(state[:tokens], 9, fn _ -> {:constant, 100} end)

    expected_result1 = List.delete_at(expected_result, 6)
    expected_result2 = List.delete_at(expected_result1, 6)
    expected_result3 = List.delete_at(expected_result2, 6)

    #The sanitized code is passed to the lexer and compared to the updated list of tentative tokens
    assert Lexer.scan_words(s_code) == expected_result3
  end

  #test 4
  test "new_lines", state do
    #code to tokenize
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

    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.delete_at(state[:tokens], 6)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)

    #compare the output of the lexer with the list of tokens
    assert Lexer.scan_words(s_code) == expected_result3
  end

  #test 5
  test "no_newlines", state do
    #code to tokenize
    code = """
    int main(){return 2;}
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.delete_at(state[:tokens], 6)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)

    #compare the output of the lexer with the list of tokens
    assert Lexer.scan_words(s_code) == expected_result3
  end

  #test 6
  test "spaces", state do
    #code to tokenize
    code = """
    int   main    (  )  {   return  2 ; }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.delete_at(state[:tokens], 6)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)

    #compare the output of the lexer with the list of tokens
    assert Lexer.scan_words(s_code) == expected_result3
  end

  #test 7
  test "mix of spaces", state do
    #code to tokenize
    code = """
    int main
    (
                )
    {   return
    2000000000000
    ;}
    """

    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #The list is updated so that the multi-digit constant 2000000000000 is expected as a token
    expected_result = List.update_at(state[:tokens], 9, fn _ -> {:constant, 2000000000000} end)
    expected_result1 = List.delete_at(expected_result, 6)
    expected_result2 = List.delete_at(expected_result1, 6)
    expected_result3 = List.delete_at(expected_result2, 6)

    #The sanitized code is passed to the lexer and compared to the updated list of tentative tokens
    assert Lexer.scan_words(s_code) == expected_result3
  end

  #test 8
  test "return value in parentheses", state do
    #code to tokenize
    code = """
      int main() {
        return (2) ;
    }
    """
     #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #the list of tokens is updated, using the List.insert_at method, adding the parentheses that the lexer must detect.
    expected_result1 = List.delete_at(state[:tokens], 6)
    expected_result2 = List.delete_at(expected_result1, 6)
    expected_result3 = List.delete_at(expected_result2, 6)
    expected_result4 = List.insert_at(expected_result3, 6, :open_paren)
    expected_result5 = List.insert_at(expected_result4, 8, :close_paren)

    #compare the output of the lexer with the expected result
    assert Lexer.scan_words(s_code) == expected_result5
  end

  #test 9
  test "elements separated just by spaces", state do

    expected_result1 = List.delete_at(state[:tokens], 6)
    expected_result2 = List.delete_at(expected_result1, 6)
    expected_result3 = List.delete_at(expected_result2, 6)

    #The lexer is given a tokenizer code and the output is directly compared to the list of expected tokens.
    assert Lexer.scan_words(["int", "main(){return", "2;}"]) == expected_result3
  end

  #test 10
  test "function name separated of function body", state do

    expected_result1 = List.delete_at(state[:tokens], 6)
    expected_result2 = List.delete_at(expected_result1, 6)
    expected_result3 = List.delete_at(expected_result2, 6)

    #The lexer is given a tokenizer code and the output is directly compared to the list of expected tokens.
    assert Lexer.scan_words(["int", "main()", "{return", "2;}"]) == expected_result3
  end

  #test 11
  test "everything is separated", state do

    expected_result1 = List.delete_at(state[:tokens], 6)
    expected_result2 = List.delete_at(expected_result1, 6)
    expected_result3 = List.delete_at(expected_result2, 6)

    #The lexer is given a tokenizer code and the output is directly compared to the list of expected tokens.
    assert Lexer.scan_words(["int", "main", "(", ")", "{", "return", "2", ";", "}"]) == expected_result3
  end

  #test 12
  test "Bitwise", state do
    code = """
      int main() {
      return ~12;
      }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)
    #The lexer is given a tokenizer code and the output is directly compared to the list of expected tokens.
    expected_result = List.update_at(state[:tokens], 9, fn _ -> {:constant, 12} end)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 7)

    assert Lexer.scan_words(s_code) == expected_result3
    end

  #test 13
  test "Negation", state do
    code = """
      int main() {
      return -12;
      }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)
    #The lexer is given a tokenizer code and the output is directly compared to the list of expected tokens.
    expected_result = List.update_at(state[:tokens], 9, fn _ -> {:constant, 12} end)
    expected_result2 = List.delete_at(expected_result, 7)
    expected_result3 = List.delete_at(expected_result2, 7)

    assert Lexer.scan_words(s_code) == expected_result3
    end

  #test 14
    test "Logical negation", state do
      code = """
        int main() {
        return !12;
        }
      """
      #The code is passed through the sanitizer
      s_code = Sanitizer.sanitize_source(code)
      #The lexer is given a tokenizer code and the output is directly compared to the list of expected tokens.
      expected_result = List.update_at(state[:tokens], 9, fn _ -> {:constant, 12} end)
      expected_result2 = List.delete_at(expected_result, 6)
      expected_result3 = List.delete_at(expected_result2, 6)

      assert Lexer.scan_words(s_code) == expected_result3
      end

  #test 15
    test "Negation+Bitwise+Logical negation", state do
      code = """
        int main() {
        return -~!2;
        }
      """
      #The code is passed through the sanitizer
      s_code = Sanitizer.sanitize_source(code)
      #The lexer is given a tokenizer code and the output is directly compared to the list of expected tokens
      assert Lexer.scan_words(s_code) == state[:tokens]
      end

  #test 16
  test "Bitwise+Logical negation+Negation", state do
    code = """
      int main() {
      return ~!-2;
      }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.delete_at(state[:tokens], 6)
    expected_result2 = List.insert_at(expected_result, 8, :negative)
    assert Lexer.scan_words(s_code) == expected_result2
  end


  #test 17
  test "Logical negation+Negation+Bitwise", state do
    code = """
      int main() {
      return !-~2;
      }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.delete_at(state[:tokens], 6)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.insert_at(expected_result2, 7, :negative)
    expected_result4 = List.insert_at(expected_result3, 8, :complement)
    assert Lexer.scan_words(s_code) == expected_result4
  end

  #test 18
  test "Bitwise+Negation+Logical negation", state do
    code = """
      int main() {
      return ~-!2;
      }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.delete_at(state[:tokens], 6)
    expected_result2 = List.insert_at(expected_result, 7, :negative)
    assert Lexer.scan_words(s_code) == expected_result2
  end

  #test 19
  test "No_Five", state do
    code = """
      int main() {
      return !5;
      }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 9, fn _ -> {:constant, 5} end)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)
    assert Lexer.scan_words(s_code) == expected_result3
  end

  #test 20
  test "No_Zero", state do
    code = """
      int main() {
      return !0;
      }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 9, fn _ -> {:constant, 0} end)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)
    assert Lexer.scan_words(s_code) == expected_result3
  end

  #test 21
  test "Bitwise_Zero", state do
    code = """
      int main() {
      return ~0;
      }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 9, fn _ -> {:constant, 0} end)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 7)
    assert Lexer.scan_words(s_code) == expected_result3
  end

  # tests to fail

  #test
  test "missing open_paren", state do
    #code to tokenize
    code = """
      int main){
        return 2;
      }
    """
     #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #The opening parenthesis is removed from the list of expected tokens, since the lexer is expected to detect that it is missing.
    expected_result  = List.delete_at(state[:tokens], 2)
    expected_result2 = List.delete_at(expected_result, 5)
    expected_result3 = List.delete_at(expected_result2, 5)
    expected_result4 = List.delete_at(expected_result3, 5)

    #compare the output of the lexer with the expected result
    assert Lexer.scan_words(s_code) == expected_result4
  end

  #test
  test "missing close_paren", state do
    #code to tokenize
    code = """
      int main( {
        return 2;
      }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #The closing parenthesis is removed from the list of expected tokens, since the lexer is expected to detect that it is missing.
    expected_result  = List.delete_at(state[:tokens], 3)
    expected_result2 = List.delete_at(expected_result, 5)
    expected_result3 = List.delete_at(expected_result2, 5)
    expected_result4 = List.delete_at(expected_result3, 5)

    #compare the output of the lexer with the expected result
    assert Lexer.scan_words(s_code) == expected_result4
  end

  #test
  test "missing open_brace", state do
    #code to tokenize
    code = """
      int main()
        return 2;
      }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #The opening brace is removed from the list of expected tokens, since the lexer is expected to detect that it is missing.
    expected_result = List.delete_at(state[:tokens], 4)
    expected_result2 = List.delete_at(expected_result, 5)
    expected_result3 = List.delete_at(expected_result2, 5)
    expected_result4 = List.delete_at(expected_result3, 5)

    #compare the output of the lexer with the expected result
    assert Lexer.scan_words(s_code) == expected_result4
  end

  #test
  test "missing close_brace", state do
    #code to tokenize
    code = """
      int main() {
        return 2;

    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #The closing brace is removed from the list of expected tokens, since the lexer is expected to detect that it is missing.
    expected_result = List.delete_at(state[:tokens], 11)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)
    expected_result4 = List.delete_at(expected_result3, 6)

    #compare the output of the lexer with the list of tokens
    assert Lexer.scan_words(s_code) == expected_result4
  end

  #test
  test "wrong case", state do
    #code to tokenize
    code = """
    int main() {
      RETURN 2;
    }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #The expected result is defined: error on the keyword "return".
    expected_result = List.update_at(state[:tokens], 5, fn _ -> :error end)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)
    expected_result4 = List.delete_at(expected_result3, 6)

    #compare the output of the lexer with the expected result
    assert Lexer.scan_words(s_code) == expected_result4
  end

  #test
  test "missing return value", state do
    #code to tokenize
    code = """
      int main() {
        return;
    }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #the expected result is defined: the return constant is missing.
    expected_result = List.delete_at(state[:tokens], 9)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)
    expected_result4 = List.delete_at(expected_result3, 6)

    #compare the output of the lexer with the expected result
    assert Lexer.scan_words(s_code) == expected_result4
  end

  #test
  test "missing semicolon", state do
    #code to tokenize
    code = """
      int main() {
        return 2
    }
    """

    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #the expected result is defined: the semicolon is missing.
    expected_result = List.delete_at(state[:tokens], 10)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)
    expected_result4 = List.delete_at(expected_result3, 6)

    #compare the output of the lexer with the expected result
    assert Lexer.scan_words(s_code) == expected_result4
  end

  #test
  test "wrong symbol", state do
    #code to tokenize
    code = """
      int main() {
        return 2 :
    }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #T he expected result is defined: the symbol in the position of the semicolon is incorrect.
    expected_result = List.update_at(state[:tokens], 10, fn _ -> :error end)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)
    expected_result4 = List.delete_at(expected_result3, 6)

    #compare the output of the lexer with the expected result
    assert Lexer.scan_words(s_code) == expected_result4
  end

  #test
  test "wrong return value", state do
    #code to tokenize
    code = """
      int main() {
        return a ;
    }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #The expected result is defined: the return value is incorrect.
    expected_result = List.update_at(state[:tokens], 9, fn _ -> :error end)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)
    expected_result4 = List.delete_at(expected_result3, 6)

    #compare the output of the lexer with the expected result
    assert Lexer.scan_words(s_code) == expected_result4
  end

  #test
  test "missing return value - logic", state do
    #code to tokenize
    code = """
      int main() {
        return !;
    }
    """
    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #the expected result is defined: the return constant is missing.
    expected_result = List.delete_at(state[:tokens], 9)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)

    #compare the output of the lexer with the expected result
    assert Lexer.scan_words(s_code) == expected_result3
  end

  #test
  test "missing semicolon - logic", state do
    #code to tokenize
    code = """
      int main() {
        return !2
    }
    """

    #The code is passed through the sanitizer
    s_code = Sanitizer.sanitize_source(code)

    #the expected result is defined: the semicolon is missing.
    expected_result = List.delete_at(state[:tokens], 10)
    expected_result2 = List.delete_at(expected_result, 6)
    expected_result3 = List.delete_at(expected_result2, 6)

    #compare the output of the lexer with the expected result
    assert Lexer.scan_words(s_code) == expected_result3
  end

end
