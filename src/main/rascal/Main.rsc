module Main

import IO;
import Syntax;
import AST;
import ParseTree;

void main() {
  // Cambia el nombre del archivo si quieres
  loc file = |project://project2/instance/spec1.vlg|;

  // Parse (concrete syntax tree)
  Tree cst = parseModule(file);
  println("CST OK");

  // AST (implode requiere que el módulo AST exista y los nombres coincidan con labels)
  Module ast = implode(cst);
  println("AST OK");
  println(ast);
}