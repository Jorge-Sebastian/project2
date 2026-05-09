module ToAST

import ParseTree;
import AST;
import Syntax;
import String;

Program toProgram(Tree t) {
  visit(t) {
    case m: appl(prod(label("verilangModule", sort("Module")), _, _), _):
      return prog(toModule(m));
    case m: appl(prod(sort("Module"), _, _), _):
      return prog(toModule(m));
  }

  throw "No se encontro un modulo VeriLang";
}

VModule toModule(Tree t) {
  list[str] lines = split("\n", unparse(t));
  str firstLine = trim(lines[0]);
  str moduleName = trim(replaceAll(firstLine, "defmodule", ""));

  return vModule(moduleName, toUsingList(t), toComponents(t));
}

list[str] toUsingList(Tree t) {
  list[str] result = [];

  visit(t) {
    case u: appl(prod(sort("Using"), _, _), _):
      result += [trim(replaceAll(unparse(u), "using", ""))];
  }

  return result;
}

list[Component] toComponents(Tree t) {
  list[Component] result = [];

  visit(t) {
    case appl(prod(label("opDef", _), _, _), kids):
      result += [operComp(operDef(trim(unparse(kids[2])), toType(kids[6]), []))];
    case appl(prod(label("opDefAttr", _), _, _), kids):
      result += [operComp(operDef(trim(unparse(kids[2])), toType(kids[6]), toAttributes(kids[8])))];
    case appl(prod(label("spaceSimple", _), _, _), kids):
      result += [spaceComp(simpleSpace(trim(unparse(kids[2]))))];
    case appl(prod(label("spaceOrdered", _), _, _), kids):
      result += [spaceComp(orderedSpace(trim(unparse(kids[2])), trim(unparse(kids[6]))))];
    case appl(prod(label("ruleDef", _), _, _), kids):
      result += [ruleComp(ruleDecl(toTerm(kids[2]), toTerm(kids[6])))];
    case appl(prod(label("varComp", _), _, _), kids):
      result += [variableComp(varBlock(toVarDecls(kids[2])))];
    case appl(prod(label("exprNoAttr", _), _, _), kids):
      result += [exprComp(exprDecl(toLogicExpr(kids[2]), []))];
    case appl(prod(label("exprAttr", _), _, _), kids):
      result += [exprComp(exprDecl(toLogicExpr(kids[2]), toAttributes(kids[4])))];
    case appl(prod(label("equationDef", _), _, _), kids):
      result += [equationComp(equationDecl(toLogicExpr(kids[2]), toLogicExpr(kids[6])))];
    case appl(prod(label("dataDef", _), _, _), kids):
      result += [dataComp(dataDecl(trim(unparse(kids[2])), toType(kids[6]), toDataItems(kids[10])))];
  }

  return result;
}

VType toType(Tree t) {
  switch (t) {
    case appl(prod(label("arrowType", _), _, _), kids):
      return arrowType(simpleType(trim(unparse(kids[0]))), toType(kids[4]));
    case appl(prod(label("simpleType", _), _, _), kids):
      return simpleType(trim(unparse(kids[0])));
  }

  str txt = trim(unparse(t));
  if (/^[a-zA-Z][a-zA-Z0-9\-]*$/ := txt) {
    return simpleType(txt);
  }

  throw "No se pudo convertir Type: <txt>";
}

list[VarDecl] toVarDecls(Tree t) {
  list[VarDecl] result = [];

  visit(t) {
    case d: appl(prod(label("varDecl", _), _, _), _):
      result += [toVarDecl(d)];
  }

  return result;
}

VarDecl toVarDecl(Tree t) {
  switch (t) {
    case appl(prod(label("varDecl", _), _, _), kids):
      return varDecl(trim(unparse(kids[0])), toType(kids[4]));
  }

  throw "No se pudo convertir VarDecl";
}

Term toTerm(Tree t) {
  switch (t) {
    case appl(prod(sort("Argument"), _, _), kids):
      return toTerm(kids[0]);
    case appl(prod(label("termApp", _), _, _), kids):
      return toTerm(kids[0]);
    case appl(prod(label("termName", _), _, _), kids):
      return nameTerm(trim(unparse(kids[0])));
    case appl(prod(label("termInt", _), _, _), kids):
      return intTerm(toInt(trim(unparse(kids[0]))));
    case appl(prod(label("termFloat", _), _, _), kids):
      return realTerm(toReal(trim(unparse(kids[0]))));
    case appl(prod(label("termString", _), _, _), kids):
      return stringTerm(trim(unparse(kids[0])));
    case appl(prod(label("termChar", _), _, _), kids):
      return charTerm(trim(unparse(kids[0])));
    case appl(prod(label("termBool", _), _, _), kids):
      return boolTerm(toBoolLiteral(trim(unparse(kids[0]))));
    case appl(prod(label("termTyped", _), _, _), kids):
      return toTerm(kids[0]);
    case appl(prod(label("typedInt", _), _, _), kids):
      return intTerm(toInt(trim(unparse(kids[0]))));
    case appl(prod(label("typedFloat", _), _, _), kids):
      return realTerm(toReal(trim(unparse(kids[0]))));
    case appl(prod(label("typedString", _), _, _), kids):
      return stringTerm(trim(unparse(kids[0])));
    case appl(prod(label("typedChar", _), _, _), kids):
      return charTerm(trim(unparse(kids[0])));
    case appl(prod(label("typedBool", _), _, _), kids):
      return boolTerm(toBoolLiteral(trim(unparse(kids[0]))));
    case appl(prod(label("application", sort("Application")), _, _), kids):
      return appTerm(trim(unparse(kids[2])), toArgs(t));
    case appl(prod(sort("Application"), _, _), kids):
      return appTerm(trim(unparse(kids[2])), toArgs(t));
  }

  str txt = trim(unparse(t));

  if (/^[a-zA-Z][a-zA-Z0-9\-]*$/ := txt) return nameTerm(txt);
  if (/^[0-9]+$/ := txt) return intTerm(toInt(txt));
  if (/^[0-9]+\.[0-9]+$/ := txt) return realTerm(toReal(txt));
  if (/^".*"$/ := txt) return stringTerm(txt);
  if (/^'.'$/ := txt) return charTerm(txt);
  if (txt == "true" || txt == "false") return boolTerm(toBoolLiteral(txt));

  throw "No se pudo convertir Term: <txt>";
}

list[Term] toArgs(Tree t) {
  list[Term] result = [];

  visit(t) {
    case a: appl(prod(label(/^arg/, sort("Argument")), _, _), _):
      result += [toTerm(a)];
    case a: appl(prod(sort("Argument"), _, _), _):
      result += [toTerm(a)];
  }

  return result;
}

LogicExpr toRelation(Tree t) {
  switch (t) {
    case appl(prod(label("relEqual", _), _, _), kids):
      return relationExpr(toTerm(kids[0]), equalOp(), toTerm(kids[4]));
    case appl(prod(label("relLessEq", _), _, _), kids):
      return relationExpr(toTerm(kids[0]), lessEqOp(), toTerm(kids[4]));
    case appl(prod(label("relGreaterEq", _), _, _), kids):
      return relationExpr(toTerm(kids[0]), greaterEqOp(), toTerm(kids[4]));
    case appl(prod(label("relNotEqual", _), _, _), kids):
      return relationExpr(toTerm(kids[0]), notEqualOp(), toTerm(kids[4]));
    case appl(prod(label("relLess", _), _, _), kids):
      return relationExpr(toTerm(kids[0]), lessOp(), toTerm(kids[4]));
    case appl(prod(label("relGreater", _), _, _), kids):
      return relationExpr(toTerm(kids[0]), greaterOp(), toTerm(kids[4]));
    case appl(prod(label("relIn", _), _, _), kids):
      return relationExpr(toTerm(kids[0]), inOp(), toTerm(kids[4]));
  }

  throw "No se pudo convertir Relation: <unparse(t)>";
}

LogicExpr toLogicExpr(Tree t) {
  if (appl(prod(label("forallExpr", _), _, _), _) := t) return toForall(t);
  if (appl(prod(label("existsExpr", _), _, _), _) := t) return toExists(t);
  if (appl(prod(label("negExpr", _), _, _), _) := t) return toNeg(t);
  if (appl(prod(label("andChain", _), _, _), _) := t) return toAnd(t);
  if (appl(prod(label("orChain", _), _, _), _) := t) return toOr(t);
  if (appl(prod(label("implChain", _), _, _), _) := t) return toImplies(t);
  if (appl(prod(label("equivChain", _), _, _), _) := t) return toEquiv(t);
  if (appl(prod(label(/^rel/, _), _, _), _) := t) return toRelation(t);
  if (appl(prod(label("boolName", _), _, _), kids) := t) return termExpr(nameTerm(trim(unparse(kids[0]))));
  if (appl(prod(label("boolLiteral", _), _, _), kids) := t) return termExpr(boolTerm(toBoolLiteral(trim(unparse(kids[0])))));

  LogicExpr found = termExpr(nameTerm("?"));
  visit(t) {
    case r: appl(prod(label(/^rel/, _), _, _), _):
      found = toRelation(r);
    case andNode: appl(prod(label("andChain", _), _, _), _):
      found = toAnd(andNode);
    case orNode: appl(prod(label("orChain", _), _, _), _):
      found = toOr(orNode);
    case implNode: appl(prod(label("implChain", _), _, _), _):
      found = toImplies(implNode);
    case equivNode: appl(prod(label("equivChain", _), _, _), _):
      found = toEquiv(equivNode);
    case boolNode: appl(prod(label("boolName", _), _, _), kids):
      found = termExpr(nameTerm(trim(unparse(kids[0]))));
    case boolLit: appl(prod(label("boolLiteral", _), _, _), kids):
      found = termExpr(boolTerm(toBoolLiteral(trim(unparse(kids[0])))));
  }

  return found;
}

LogicExpr toNeg(Tree t) {
  switch (t) {
    case appl(prod(label("negExpr", _), _, _), kids):
      return negExpr(toLogicExpr(kids[2]));
  }

  throw "No se pudo convertir neg";
}

LogicExpr toAnd(Tree t) {
  switch (t) {
    case appl(prod(label("andChain", _), _, _), kids):
      return andExpr([toLogicExpr(kids[0]), toLogicExpr(kids[4])]);
  }

  throw "No se pudo convertir and";
}

LogicExpr toOr(Tree t) {
  switch (t) {
    case appl(prod(label("orChain", _), _, _), kids):
      return orExpr([toLogicExpr(kids[0]), toLogicExpr(kids[4])]);
  }

  throw "No se pudo convertir or";
}

LogicExpr toImplies(Tree t) {
  switch (t) {
    case appl(prod(label("implChain", _), _, _), kids):
      return impliesExpr([toLogicExpr(kids[0]), toLogicExpr(kids[4])]);
  }

  throw "No se pudo convertir implicacion";
}

LogicExpr toEquiv(Tree t) {
  switch (t) {
    case appl(prod(label("equivChain", _), _, _), kids):
      return equivExpr([toLogicExpr(kids[0]), toLogicExpr(kids[4])]);
  }

  throw "No se pudo convertir equivalencia";
}

LogicExpr toForall(Tree t) {
  switch (t) {
    case appl(_, [_, _, var, _, _, body]):
      return forallExpr(trim(unparse(var)), noSpace(), toLogicExpr(body));
    case appl(_, [_, _, var, _, _, space, _, _, body]):
      return forallExpr(trim(unparse(var)), inSpace(trim(unparse(space))), toLogicExpr(body));
  }

  throw "No se pudo convertir forall";
}

LogicExpr toExists(Tree t) {
  switch (t) {
    case appl(_, [_, _, var, _, _, body]):
      return existsExpr(trim(unparse(var)), noSpace(), toLogicExpr(body));
    case appl(_, [_, _, var, _, _, space, _, _, body]):
      return existsExpr(trim(unparse(var)), inSpace(trim(unparse(space))), toLogicExpr(body));
  }

  throw "No se pudo convertir exists";
}

list[AttrItem] toAttributes(Tree t) {
  list[AttrItem] result = [];

  visit(t) {
    case appl(prod(label("attrPlain", _), _, _), kids):
      result += [flagAttr(trim(unparse(kids[0])))];
    case appl(prod(label("attrKeyVal", _), _, _), kids):
      result += [valuedAttr(trim(unparse(kids[0])), toAttrValue(kids[4]))];
  }

  return result;
}

AttrValue toAttrValue(Tree t) {
  switch (t) {
    case appl(prod(label("attrName", _), _, _), kids):
      return attrName(trim(unparse(kids[0])));
    case appl(prod(label("attrInt", _), _, _), kids):
      return attrInt(toInt(trim(unparse(kids[0]))));
    case appl(prod(label("attrFloat", _), _, _), kids):
      return attrReal(toReal(trim(unparse(kids[0]))));
    case appl(prod(label("attrBool", _), _, _), kids):
      return attrBool(toBoolLiteral(trim(unparse(kids[0]))));
    case appl(prod(label("attrEmpty", _), _, _), _):
      return attrEmpty();
  }

  throw "No se pudo convertir AttributeValue: <unparse(t)>";
}

list[DataItem] toDataItems(Tree t) {
  list[DataItem] result = [];

  visit(t) {
    case appl(prod(label("dataName", _), _, _), kids):
      result += [dataName(trim(unparse(kids[0])))];
    case v: appl(prod(label(/^typed/, _), _, _), _):
      result += [toDataItem(v)];
  }

  return result;
}

DataItem toDataItem(Tree t) {
  switch (t) {
    case appl(prod(label("typedInt", _), _, _), kids):
      return dataInt(toInt(trim(unparse(kids[0]))), toType(kids[4]));
    case appl(prod(label("typedFloat", _), _, _), kids):
      return dataReal(toReal(trim(unparse(kids[0]))), toType(kids[4]));
    case appl(prod(label("typedString", _), _, _), kids):
      return dataString(trim(unparse(kids[0])), toType(kids[4]));
    case appl(prod(label("typedChar", _), _, _), kids):
      return dataChar(trim(unparse(kids[0])), toType(kids[4]));
    case appl(prod(label("typedBool", _), _, _), kids):
      return dataBool(toBoolLiteral(trim(unparse(kids[0]))), toType(kids[4]));
  }

  throw "No se pudo convertir DataItem: <unparse(t)>";
}

bool toBoolLiteral(str text) = trim(text) == "true";
