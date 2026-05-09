module TypeChecker

import AST;
import IO;
import Set;
import List;

public list[str] check(Program p) {
  if (prog(vModule(_, _, comps)) := p) {
    set[str] spaces = {"Int", "Bool", "String", "Char", "Real"};
    set[str] vars = {};
    set[str] operators = {};
    set[str] dataNames = {};
    list[str] errors = [];

    for (comp <- comps) {
      if (spaceComp(simpleSpace(n)) := comp) {
        spaces += {n};
      }
      if (spaceComp(orderedSpace(child, _)) := comp) {
        spaces += {child};
      }
      if (dataComp(dataDecl(name, _, _)) := comp) {
        dataNames += {name};
      }
      if (operComp(operDef(name, _, _)) := comp) {
        operators += {name};
      }
    }

    for (comp <- comps) {
      if (variableComp(varBlock(decls)) := comp) {
        for (varDecl(n, _) <- decls) {
          vars += {n};
        }
      }
    }

    for (comp <- comps) {
      if (operComp(operDef(name, typ, _)) := comp) {
        errors += checkTypeNames("operador <name>", typ, spaces);
      }
      if (variableComp(varBlock(decls)) := comp) {
        for (varDecl(vname, typ) <- decls) {
          errors += checkTypeNames("variable <vname>", typ, spaces);
        }
      }
      if (dataComp(dataDecl(dname, typ, values)) := comp) {
        errors += checkTypeNames("estructura <dname>", typ, spaces);
        errors += checkDataValues(dname, typ, values, vars, dataNames);
      }
      if (spaceComp(orderedSpace(child, parent)) := comp) {
        if (parent notin spaces) {
          errors += ["Error: espacio padre <parent> de <child> no esta definido"];
        }
      }
    }

    for (comp <- comps) {
      if (exprComp(exprDecl(expr, _)) := comp) {
        for (str v <- collectVarNames(expr)) {
          if (v notin vars && v notin spaces && v notin dataNames && v notin operators) {
            errors += ["Error: variable <v> en expresion no esta declarada"];
          }
        }
      }
      if (equationComp(equationDecl(left, right)) := comp) {
        for (str v <- collectVarNames(left) + collectVarNames(right)) {
          if (v notin vars && v notin spaces && v notin dataNames && v notin operators) {
            errors += ["Error: variable <v> en ecuacion no esta declarada"];
          }
        }
      }
      if (ruleComp(ruleDecl(left, right)) := comp) {
        for (str v <- collectNamesInTerm(left) + collectNamesInTerm(right)) {
          if (v notin vars && v notin spaces && v notin dataNames && v notin operators) {
            errors += ["Error: nombre <v> en regla no esta declarado"];
          }
        }
      }
    }

    return errors;
  }

  return ["Error: programa VeriLang invalido"];
}

public void printCheck(Program p) {
  list[str] errors = check(p);

  if (errors == []) {
    println("OK: no se encontraron errores de tipos o referencias");
  } else {
    for (e <- errors) {
      println(e);
    }
  }
}

list[str] checkTypeNames(str context, VType t, set[str] spaces) {
  list[str] errors = [];

  for (str name <- collectTypeNames(t)) {
    if (name notin spaces) {
      errors += ["Error: tipo <name> en <context> no esta definido como espacio"];
    }
  }

  return errors;
}

list[str] checkDataValues(str dataName, VType declaredType, list[DataItem] values, set[str] vars, set[str] dataNames) {
  list[str] errors = [];

  for (item <- values) {
    switch (item) {
      case dataName(identifier):
        if (identifier notin vars && identifier notin dataNames) {
          errors += ["Error: elemento <identifier> usado en estructura <dataName> no existe"];
        }
      case dataInt(_, typ):
        errors += checkLiteralType(dataName, "Int", typ, declaredType);
      case dataReal(_, typ):
        errors += checkLiteralType(dataName, "Real", typ, declaredType);
      case dataString(_, typ):
        errors += checkLiteralType(dataName, "String", typ, declaredType);
      case dataChar(_, typ):
        errors += checkLiteralType(dataName, "Char", typ, declaredType);
      case dataBool(_, typ):
        errors += checkLiteralType(dataName, "Bool", typ, declaredType);
    }
  }

  return errors;
}

list[str] checkLiteralType(str dataName, str literalType, VType itemType, VType declaredType) {
  list[str] errors = [];

  if (typeName(itemType) != literalType) {
    errors += ["Error: literal en estructura <dataName> anotado como <typeName(itemType)>, pero su tipo real es <literalType>"];
  }
  if (typeName(declaredType) != literalType) {
    errors += ["Error: literal de tipo <literalType> no corresponde con el tipo declarado de estructura <dataName> (<typeName(declaredType)>)"];
  }

  return errors;
}

list[str] collectTypeNames(VType t) {
  switch (t) {
    case simpleType(name):
      return [name];
    case arrowType(left, right):
      return collectTypeNames(left) + collectTypeNames(right);
  }

  return [];
}

str typeName(VType t) {
  switch (t) {
    case simpleType(name):
      return name;
    case arrowType(_, _):
      return "Function";
  }
}

set[str] collectVarNames(LogicExpr e) {
  set[str] result = {};

  visit(e) {
    case termExpr(nameTerm(n)):
      result += {n};
    case relationExpr(left, _, right): {
      result += collectNamesInTerm(left);
      result += collectNamesInTerm(right);
    }
  }

  return result;
}

set[str] collectNamesInTerm(Term t) {
  set[str] result = {};

  visit(t) {
    case nameTerm(n):
      result += {n};
    case appTerm(name, _):
      result += {name};
  }

  return result;
}
