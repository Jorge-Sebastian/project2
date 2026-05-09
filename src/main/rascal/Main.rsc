module Main

import AST;
import Generator;
import IO;
import Parser;
import TypeChecker;

void main(list[str] args) {
  loc file = |project://js-otalorab12-project-verilang/instance/spec1.vl|;
  AST::Program program = loadVerilang(file);

  println("VeriLang input: <file>");
  println("--- Generated output ---");
  runProgram(program);
  println("--- Type checking ---");
  printCheck(program);
}
