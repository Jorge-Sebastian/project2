module Checker

extend analysis::typepal::TypePal;

import ParseTree;
import Syntax;
import util::LanguageServer;

data IdRole = spaceId() | variableId() | operatorId() | dataId();
data AType = verilangType(str name);

void defineName(str nameText, IdRole role, Tree nameTree, Collector c) {
  DefInfo dt = defType(verilangType(nameText));
  c.define(nameText, role, nameTree, dt);
}

void collect(current: (SpaceComponent) `defspace <Nombre name> end`, Collector c) {
  defineName("<name>", spaceId(), name, c);
}

void collect(current: (SpaceComponent) `defspace <Nombre child> <Less op> <Nombre parent> end`, Collector c) {
  defineName("<child>", spaceId(), child, c);
  c.use(parent, {spaceId()});
}

void collect(current: (OperatorComponent) `defoperator <Nombre name> : <Type typ> end`, Collector c) {
  defineName("<name>", operatorId(), name, c);
}

void collect(current: (OperatorComponent) `defoperator <Nombre name> : <Type typ> <Attribute attrs> end`, Collector c) {
  defineName("<name>", operatorId(), name, c);
}

void collect(current: (VarDecl) `<Nombre name> : <Type typ>`, Collector c) {
  defineName("<name>", variableId(), name, c);
}

void collect(current: (DataComponent) `defdata <Nombre name> : <Type typ> <Equal eq> <DataLiteral values> end`, Collector c) {
  defineName("<name>", dataId(), name, c);
}

void collect(current: (DataItem) `<Nombre name>`, Collector c) {
  c.use(name, {variableId(), dataId()});
}

void collect(current: (Application) `( <Nombre name> <Argument+ args> )`, Collector c) {
  c.use(name, {operatorId()});
}

void collect(current: (BoolAtom) `<Nombre name>`, Collector c) {
  c.use(name, {variableId()});
}

public TModel TModelFromTree(Tree pt) {
  if (pt has top) {
    pt = pt.top;
  }

  TypePalConfig config = getModulesConfig();
  Collector c = newCollector("collectAndSolve", pt, config);
  collect(pt, c);
  return newSolver(pt, c.run()).run();
}

public Summary verilangSummary(loc l, start[Program] input) {
  TModel tm = TModelFromTree(input);
  rel[loc use, loc def] defs = getUseDef(tm);
  return summary(l, messages = {<m.at, m> | m <- getMessages(tm), !(m is info)}, definitions = defs);
}
