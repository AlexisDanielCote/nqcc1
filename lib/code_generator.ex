defmodule CodeGenerator do
  @moduledoc """
  Code Generator, this module gets the AST after the parser validation and check all the
  nodes to get the assembler code.
  """

  @doc"""
  This fuction calls the post_order with the ast as 
  an argument, and returns the code.
  with :print -Prints the resulting code in the terminal.
  with :noprint -It doesn't print the code in the terminal.
  """
  def generate_code(ast, :print) do

    code = post_order(ast)

    IO.puts("\nCode Generator output:")
    IO.puts(code)

    code

  end


  def generate_code(ast, :noprint) do

    code = post_order(ast)

    code

  end

  @doc"""
  This fuction applies post_order recursively to the ast and get
  code_snippet's which conform the full code until the ast is fully
  traversed.
  """
  def post_order(node) do
    case node do
      nil ->
        nil

      ast_node ->
        code_snippet = post_order(ast_node.left_node)
        # TODO: Falta terminar de implementar cuando el arbol tiene mas ramas
        post_order(ast_node.right_node)

        emit_code(ast_node.node_name, code_snippet, ast_node.value)
    end
  end

  @doc"""
  This function can emit the code corresponding to the received tokens, and it's variations
  consider recursive code generation with the use of code_snippet's.
  """
  def emit_code(:program, code_snippet, _) do
    """
        .section  .text.startup,"ax",@progbits
        .p2align        4, 0x90
    """ <>
      code_snippet
  end

  
  #Emit code for a C main function.
  def emit_code(:function, code_snippet, :main) do
    """
        .globl  main         ## -- Begin function main
    main:                    ## @main
    """ <>
      code_snippet
  end

  
  #Emit code for a return statement, the finishing code_snippet it's
  #expected to be the :constant which completes the movl function with
  #the eax register.
  def emit_code(:return, code_snippet, _) do
    """
        mov    #{code_snippet}
        ret
    """
  end

  
  #The constant is the last value relevant to the code generator, 
  #so it has the snippet <<, %eax>> which complements a movl function, 
  #after the code has been generated recursively for the other unary 
  #operators if any.

  def emit_code(:constant, _, value) do
    "$#{value}, %rax"
  end

  
  #Emit code for a negative unOp, considering recursive code generation.
  def emit_code(:negative, code_snippet, _) do
    """
#{code_snippet}
        neg     %rax
    """
  end

  #Emit code for a complement unOp, considering recursive code generation.
  def emit_code(:complement, code_snippet, _) do
    """
#{code_snippet}
        not     %rax
    """
  end

  #Emit code for a logic negation unOp, considering recursive code generation.
  def emit_code(:logic, code_snippet, _) do
    """
#{code_snippet}
        cmp $0, %rax
        mov $0, %rax
        sete %al
    """
  end
end
