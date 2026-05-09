module Generator

import AST;
import IO;
import String;
import List;

public void runProgram(Program p) {
  println(generateProgram(p));
}

public str generateProgram(Program p) {
  switch (p) {
    case prog(vModule(name, usings, comps)):
      return "Module: <name>\n"
           + generateUsings(usings)
           + generateComponents(comps);
  }
}

str generateUsings(list[str] usings) {
  str result = "";

  for (u <- usings) {
    result += "Using: <u>\n";
  }

  return result;
}

str generateComponents(list[Component] comps) {
  str result = "";

  for (c <- comps) {
    result += generateComponent(c) + "\n";
  }

  return result;
}

str generateComponent(Component c) {
  switch (c) {
    case spaceComp(simpleSpace(name)):
      return "Space: <name>";
    case spaceComp(orderedSpace(child, parent)):
      return "Space: <child> \< <parent>";
    case operComp(operDef(name, typ, attrs)):
      return "Operator: <name> : <generateType(typ)><generateAttributes(attrs)>";
    case variableComp(varBlock(vars)):
      return generateVarBlock(vars);
    case ruleComp(ruleDecl(left, right)):
      return "Rule: <generateTerm(left)> -\> <generateTerm(right)>";
    case exprComp(exprDecl(expr, attrs)):
      return "Expression: <generateLogicExpr(expr)><generateAttributes(attrs)>";
    case equationComp(equationDecl(left, right)):
      return "Equation: <generateLogicExpr(left)> = <generateLogicExpr(right)>";
    case dataComp(dataDecl(name, typ, values)):
      return "Data: <name> : <generateType(typ)> = [<generateDataValues(values)>]";
    case attrComp(attrs):
      return "Attributes: <generateAttributes(attrs)>";
  }
}

str generateType(VType t) {
  switch (t) {
    case simpleType(name):
      return name;
    case arrowType(left, right):
      return "<generateType(left)> -\> <generateType(right)>";
  }
}

str generateAttributes(list[AttrItem] attrs) {
  if (attrs == []) {
    return "";
  }

  return " [" + intercalate(", ", [generateAttribute(a) | a <- attrs]) + "]";
}

str generateAttribute(AttrItem item) {
  switch (item) {
    case flagAttr(name):
      return name;
    case valuedAttr(key, attrVal):
      return "<key>:<generateAttrValue(attrVal)>";
  }
}

str generateAttrValue(AttrValue attrVal) {
  switch (attrVal) {
    case attrName(text):
      return text;
    case attrInt(number):
      return "<number>";
    case attrReal(decimal):
      return "<decimal>";
    case attrBool(boolValue):
      return "<boolValue>";
    case attrEmpty():
      return "empty";
  }
}

str generateVarBlock(list[VarDecl] vars) {
  return "Variables: " + intercalate(", ", [generateVar(v) | v <- vars]);
}

str generateVar(VarDecl v) {
  switch (v) {
    case varDecl(name, typ):
      return "<name> : <generateType(typ)>";
  }
}

str generateTerm(Term t) {
  switch (t) {
    case nameTerm(n):
      return n;
    case intTerm(i):
      return "<i>";
    case realTerm(r):
      return "<r>";
    case stringTerm(s):
      return s;
    case charTerm(c):
      return c;
    case boolTerm(b):
      return "<b>";
    case appTerm(name, args):
      return "<name>(<generateArgs(args)>)";
  }
}

str generateArgs(list[Term] args) {
  return intercalate(", ", [generateTerm(a) | a <- args]);
}

str generateDataValues(list[DataItem] values) {
  return intercalate(", ", [generateDataItem(v) | v <- values]);
}

str generateDataItem(DataItem item) {
  switch (item) {
    case dataName(identifier):
      return identifier;
    case dataInt(intValue, typ):
      return "<intValue>:<generateType(typ)>";
    case dataReal(realValue, typ):
      return "<realValue>:<generateType(typ)>";
    case dataString(stringValue, typ):
      return "<stringValue>:<generateType(typ)>";
    case dataChar(charValue, typ):
      return "<charValue>:<generateType(typ)>";
    case dataBool(boolValue, typ):
      return "<boolValue>:<generateType(typ)>";
  }
}

str generateLogicExpr(LogicExpr e) {
  switch (e) {
    case termExpr(t):
      return generateTerm(t);
    case relationExpr(left, op, right):
      return "<generateTerm(left)> <generateRelOp(op)> <generateTerm(right)>";
    case andExpr(exprs):
      return intercalate(" and ", [generateLogicExpr(x) | x <- exprs]);
    case orExpr(exprs):
      return intercalate(" or ", [generateLogicExpr(x) | x <- exprs]);
    case negExpr(inner):
      return "neg <generateLogicExpr(inner)>";
    case forallExpr(var, domain, body):
      return "forall <var><generateMaybeSpace(domain)> . <generateLogicExpr(body)>";
    case existsExpr(var, domain, body):
      return "exists <var><generateMaybeSpace(domain)> . <generateLogicExpr(body)>";
    case groupedExpr(inner):
      return "(<generateLogicExpr(inner)>)";
    case impliesExpr(exprs):
      return intercalate(" =\> ", [generateLogicExpr(x) | x <- exprs]);
    case equivExpr(exprs):
      return intercalate(" == ", [generateLogicExpr(x) | x <- exprs]);
  }
}

str generateMaybeSpace(MaybeSpace s) {
  switch (s) {
    case noSpace():
      return "";
    case inSpace(name):
      return " in <name>";
  }
}

str generateRelOp(RelOp op) {
  switch (op) {
    case inOp():
      return "in";
    case lessEqOp():
      return "\<=";
    case greaterEqOp():
      return "\>=";
    case notEqualOp():
      return "\<\>";
    case lessOp():
      return "\<";
    case greaterOp():
      return "\>";
    case equalOp():
      return "=";
  }
}
