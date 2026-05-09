module Syntax

// VeriLang keeps line breaks between top-level components. Spaces and tabs are layout.
layout Layout = [\ \t]*;
lexical NL = "\r\n" | "\n";

start syntax Program
  = program: Module NL*
  ;

syntax Module
  = verilangModule:
    'defmodule' Nombre name NL
    UsingList uses
    ComponentSection components
    'end'
  ;

syntax UsingList
  = usingList: (Using NL)* imports
  ;

syntax Using
  = using: 'using' Nombre moduleName
  ;

syntax ComponentSection
  = componentSection: (Component NL)* components
  ;

syntax Component
  = spaceComponent: SpaceComponent
  | operatorComponent: OperatorComponent
  | variableComponent: VariableComponent
  | ruleComponent: RuleComponent
  | expressionComponent: ExpressionComponent
  | equationComponent: EquationComponent
  | dataComponent: DataComponent
  | attributeComponent: Attribute
  ;

syntax SpaceComponent
  = spaceSimple: 'defspace' Nombre name 'end'
  | spaceOrdered: 'defspace' Nombre child Less Nombre parent 'end'
  ;

syntax OperatorComponent
  = opDef: 'defoperator' Nombre name ':' Type operatorType 'end'
  | opDefAttr: 'defoperator' Nombre name ':' Type operatorType Attribute attrs 'end'
  ;

syntax Type
  = simpleType: Nombre name
  | arrowType: Nombre from Arrow Type to
  ;

syntax VariableComponent
  = varComp: 'defvar' VarDeclList declarations 'end'
  ;

syntax VarDeclList
  = oneVarDecl: VarDecl declaration
  | manyVarDecls: VarDecl declaration ',' VarDeclList rest
  ;

syntax VarDecl
  = varDecl: Nombre name ':' Type declaredType
  ;

syntax RuleComponent
  = ruleDef: 'defrule' Term left Arrow Term right 'end'
  ;

syntax Application
  = application: '(' Nombre name Argument+ arguments ')'
  ;

syntax Argument
  = argApplication: Application
  | argName: Nombre
  | argTypedValue: TypedValue
  | argInt: IntLiteral
  | argFloat: FloatLiteral
  | argString: StringLiteral
  | argChar: CharLiteral
  | argBool: BoolLiteral
  ;

syntax ExpressionComponent
  = exprNoAttr: 'defexpression' LogicalExpression expression 'end'
  | exprAttr: 'defexpression' LogicalExpression expression Attribute attrs 'end'
  ;

syntax EquationComponent
  = equationDef: 'defequation' LogicalExpression left Equal LogicalExpression right 'end'
  ;

syntax DataComponent
  = dataDef: 'defdata' Nombre name ':' Type declaredType Equal DataLiteral values 'end'
  ;

syntax DataLiteral
  = dataList: '[' DataItem (',' DataItem)* items ']'
  ;

syntax DataItem
  = dataName: Nombre
  | dataTyped: TypedValue
  ;

syntax TypedValue
  = typedInt: IntLiteral value ':' Type declaredType
  | typedFloat: FloatLiteral value ':' Type declaredType
  | typedString: StringLiteral value ':' Type declaredType
  | typedChar: CharLiteral value ':' Type declaredType
  | typedBool: BoolLiteral value ':' Type declaredType
  ;

syntax Attribute
  = attribute: '[' AttributeItem (',' AttributeItem)* items ']'
  ;

syntax AttributeItem
  = attrPlain: Nombre name
  | attrKeyVal: Nombre name ':' AttributeValue value
  ;

syntax AttributeValue
  = attrName: Nombre
  | attrInt: IntLiteral
  | attrFloat: FloatLiteral
  | attrBool: BoolLiteral
  | attrEmpty: EmptySet
  ;

syntax LogicalExpression
  = logicalQuant: Quantifier
  | logicalEquiv: EquivExpr
  ;

syntax Quantifier
  = forallExpr: 'forall' Nombre variable ('in' Nombre domain)? Dot LogicalExpression body
  | existsExpr: 'exists' Nombre variable ('in' Nombre domain)? Dot LogicalExpression body
  ;

syntax EquivExpr
  = equivSingle: ImplExpr
  | equivChain: ImplExpr left Equiv EquivExpr right
  ;

syntax ImplExpr
  = implSingle: OrExpr
  | implChain: OrExpr left Implies ImplExpr right
  ;

syntax OrExpr
  = orSingle: AndExpr
  | orChain: AndExpr left 'or' OrExpr right
  ;

syntax AndExpr
  = andSingle: UnaryExpr
  | andChain: UnaryExpr left 'and' AndExpr right
  ;

syntax UnaryExpr
  = negExpr: 'neg' UnaryExpr expression
  | unaryBase: BaseExpr
  ;

syntax BaseExpr
  = baseParen: '(' LogicalExpression expression ')'
  | baseRelation: Relation
  | baseBoolAtom: BoolAtom
  ;

syntax BoolAtom
  = boolName: Nombre
  | boolLiteral: BoolLiteral
  ;

syntax Relation
  = relIn: Term left 'in' Term right
  | relLessEq: Term left LessEq Term right
  | relGreaterEq: Term left GreaterEq Term right
  | relNotEqual: Term left NotEqual Term right
  | relLess: Term left Less Term right
  | relGreater: Term left Greater Term right
  | relEqual: Term left Equal Term right
  ;

syntax Term
  = termApp: Application
  | termName: Nombre
  | termTyped: TypedValue
  | termInt: IntLiteral
  | termFloat: FloatLiteral
  | termString: StringLiteral
  | termChar: CharLiteral
  | termBool: BoolLiteral
  ;

syntax Nombre
  = name: ID
  ;

lexical ID
  = [a-zA-Z][a-zA-Z0-9\-]* !>> [a-zA-Z0-9\-]
  \ Reserved
  ;

lexical IntLiteral = [0-9]+ !>> [0-9];
lexical FloatLiteral = [0-9]+ "." [0-9]+ !>> [0-9];
lexical StringLiteral = "\"" ![\"]* "\"";
lexical CharLiteral = "\'" ![\'] "\'";
lexical BoolLiteral = "true" | "false";

lexical Less = "\u003C" !>> "\u003D" !>> "\u003E";
lexical Greater = "\u003E" !>> "\u003D";
lexical LessEq = "\u003C\u003D";
lexical GreaterEq = "\u003E\u003D";
lexical NotEqual = "\u003C\u003E";
lexical Equal = "\u003D" !>> "\u003E";
lexical Implies  = "\u003D\u003E";
lexical Arrow = "\u002D\u003E";
lexical Dot = "." !>> [0-9];
lexical Equiv = "\u2261";
lexical EmptySet = "\u2205";

keyword Reserved
  = 'defmodule'
  | 'using'
  | 'defspace'
  | 'defoperator'
  | 'defvar'
  | 'defrule'
  | 'defexpression'
  | 'defequation'
  | 'defdata'
  | 'end'
  | 'forall'
  | 'exists'
  | 'in'
  | 'and'
  | 'or'
  | 'neg'
  | 'defer'
  | 'true'
  | 'false'
  ;
