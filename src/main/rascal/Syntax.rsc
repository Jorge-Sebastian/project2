module Syntax

// Layout: NO consumimos '\n' para poder exigir fin de línea cuando toca (using)
layout Layout = (WS | Comment)* !>> [\ \t\r#];
lexical WS = [\ \t\r]+;
lexical Comment = @category="Comment" "#" ![\n]* $;

// Newline explícito
lexical NL = [\n]+;

// Keywords (incluye defer, te lo habían marcado como faltante en P1)
keyword Reserved
  = "defmodule" | "using" | "defspace" | "defoperator" | "defvar" | "defrule"
  | "defexpression" | "end"
  | "forall" | "exists"
  | "and" | "or" | "neg" | "in"
  | "defer"
  ;

// Identificadores
lexical ID = ([a-zA-Z][a-zA-Z0-9\-]* !>> [a-zA-Z0-9\-]) \ Reserved;

// Literales básicos
lexical INT = [0-9]+;
lexical FLOAT = [0-9]+ "." [0-9]+;
lexical CHAR = "'" !["'\n"] "'";

// Start: un archivo es un módulo
start syntax Module
  = module:
    'defmodule' ID name NL
    UsingDecl* uses
    Declaration* decls
    'end' NL?
  ;

// using exige fin de línea (feedback P1)
syntax UsingDecl
  = usingDecl:
    'using' ID moduleName NL
  ;

// Declaraciones: incluye attrs y relations como “cosas sueltas” (feedback P1)
syntax Declaration
  = spaceDecl: SpaceDecl
  | operatorDecl: OperatorDecl
  | varDecl: VarDecl
  | ruleDecl: RuleDecl
  | exprDecl: ExpressionDecl
  | attrDecl: AttributeDecl
  | relDecl: RelationDecl
  ;

// Spaces
syntax SpaceDecl
  = spaceDecl:
    'defspace' ID name ('<' ID super)? 'end' NL?
  ;

// Operators (sin AttributeList, porque “no deberían poder tener atributos”)
syntax OperatorDecl
  = operatorDecl:
    'defoperator' ID op ':' Type type 'end' NL?
  ;

// Curry types: A -> B -> C ...
syntax Type
  = funType:
    ID t1 ('->' ID)+ more
  ;

// Attributes como declaración aparte (pueden aparecer “solos”)
syntax AttributeDecl
  = attrDecl:
    AttributeList attrs NL?
  ;

syntax AttributeList
  = attrs:
    '[' AttributeItem+ items ']'
  ;

syntax AttributeItem
  = attrItem:
    ID name (':' AttributeValue val)?
  ;

syntax AttributeValue
  = attrValId: ID
  ;

// Variables
syntax VarDecl
  = varDecl:
    'defvar' VarItem (',' VarItem)* items 'end' NL?
  ;

syntax VarItem
  = varItem:
    ID name ':' ID domain
  ;

// Rules: reescritura entre aplicaciones prefijas
syntax RuleDecl
  = ruleDecl:
    'defrule' OperatorApp lhs '->' OperatorApp rhs 'end' NL?
  ;

syntax OperatorApp
  = opApp:
    '(' ID op ArgList? args ')'
  ;

// Args: mejor que sean “átomos” (variables/literales/aplicaciones), no Expression completa
syntax ArgList
  = args:
    Atom+ items
  ;

syntax Atom
  = atomId: ID
  | atomInt: INT
  | atomFloat: FLOAT
  | atomChar: CHAR
  | atomApp: OperatorApp
  ;

// Expressions
syntax ExpressionDecl
  = exprDecl:
    'defexpression' Expression exp AttributeList? attrs 'end' NL?
  ;

// Precedencia (estilo tu gramática)
syntax Expression = impl: ImplicationExpr;

syntax ImplicationExpr
  = implExpr:
    EquivalenceExpr left ('=>' EquivalenceExpr)* rest
  ;

syntax EquivalenceExpr
  = equivExpr:
    LogicalOrExpr left ('≡' LogicalOrExpr)* rest
  ;

syntax LogicalOrExpr
  = orExpr:
    LogicalAndExpr left ('or' LogicalAndExpr)* rest
  ;

syntax LogicalAndExpr
  = andExpr:
    EqualityExpr left ('and' EqualityExpr)* rest
  ;

syntax EqualityExpr
  = eqExpr:
    RelationalExpr left (RelOp RelationalExpr)* rest
  ;

syntax RelationalExpr
  = relExpr:
    AdditiveExpr expr
  ;

syntax RelOp
  = lt: '<' | gt: '>' | le: '<=' | ge: '>=' | ne: '<>' | inOp: 'in'
  ;

syntax AdditiveExpr
  = addExpr:
    MultiplicativeExpr left (('+'|'-') MultiplicativeExpr)* rest
  ;

syntax MultiplicativeExpr
  = mulExpr:
    UnaryExpr left (('*'|'/'|'%') UnaryExpr)* rest
  ;

syntax UnaryExpr
  = negExpr: ('neg'|'-') UnaryExpr
  | primExpr: PrimaryExpr
  ;

// Importante: NO incluimos "∅" como expresión
syntax PrimaryExpr
  = quant: QuantifiedExpr
  | app: OperatorApp
  | id: ID
  | intLit: INT
  | floatLit: FLOAT
  | charLit: CHAR
  | par: '(' Expression ')'
  ;

syntax QuantifiedExpr
  = quantExpr:
    Quantifier q ID var 'in' ID domain '.' Expression body
  ;

syntax Quantifier = all: 'forall' | ex: 'exists';

// “Relaciones” usando defer como declaración explícita
// (así existe un constructo de relación sin inventar keywords nuevas)
syntax RelationDecl
  = relDecl:
    'defer' ID name ':' Type type 'end' NL?
  ;
