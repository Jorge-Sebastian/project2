module CheckExamples

import AST;
import IO;
import Parser;
import TypeChecker;

public void runExamples() {
  for (file <- [
      |project://js-otalorab12-project-verilang/instance/spec1.vl|,
      |project://js-otalorab12-project-verilang/instance/spec_typed_values.vl|,
      |project://js-otalorab12-project-verilang/instance/spec_error.vl|
    ]) {
    println("--- <file> ---");
    AST::Program program = loadVerilang(file);
    printCheck(program);
  }
}

public void main(list[str] args) {
  runExamples();
}
