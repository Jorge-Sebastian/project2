module Plugin

import IO;
import Checker;
import ParseTree;
import Relation;
import Syntax;
import util::IDEServices;
import util::LanguageServer;
import util::Reflective;

PathConfig pcfg = getProjectPathConfig(|project://js-otalorab12-project-verilang|);

Language verilangLang = language(pcfg, "VeriLang", "vl", "Plugin", "contribs");

set[LanguageService] contribs() = {
  parser(start[Program] (str program, loc src) {
    return parse(#start[Program], program, src);
  }),
  summarizer(verilangSummary)
};

void main(list[str] args) {
  registerLanguage(verilangLang);
  println("VeriLang registered for .vl");
}
