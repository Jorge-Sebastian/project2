module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Relation;

import Syntax;

PathConfig pcfg = getProjectPathConfig(|project://project2|);

// Nombre del lenguaje y extensión
Language verilangLang = language(pcfg, "Verilang", "vlg", "Plugin", "contribs");

set[LanguageService] contribs() = {
  parser(start[Module] (str program, loc src) {
    return parse(#start[Module], program, src);
  })
};

void main() {
  registerLanguage(verilangLang);
  println("Verilang registered for .vlg");
}