module Main

import AST;
import Generator;
import IO;
import Parser;
import TypeChecker;

public void runDefault() {
  loc file = |project://js-otalorab12-project-verilang/instance/spec1.vl|;
  runFile(file);
}

public void runFile(loc file) {
  AST::Program program = loadVerilang(file);

  println("VeriLang input: <file>");
  println("--- Generated output ---");
  runProgram(program);
  println("--- Type checking ---");
  printCheck(program);
}

public void main(list[str] args) {
  runDefault();
}
