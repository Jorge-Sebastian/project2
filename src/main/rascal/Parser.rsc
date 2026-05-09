module Parser

import AST;
import Generator;
import IO;
import ParseTree;
import Syntax;
import ToAST;
import TypeChecker;

public Tree parseVerilang(loc file) {
  str txt = readFile(file);
  return parse(#start[Program], txt, file);
}

public AST::Program loadVerilang(loc file) {
  return toProgram(parseVerilang(file));
}

public void parseExample() {
  loc file = |project://js-otalorab12-project-verilang/instance/spec1.vl|;
  Tree tree = parseVerilang(file);
  AST::Program program = toProgram(tree);

  println("Parse OK");
  println("--- Generated output ---");
  runProgram(program);
  println("--- Type checking ---");
  printCheck(program);
}

public void main(list[str] args) {
  parseExample();
}
