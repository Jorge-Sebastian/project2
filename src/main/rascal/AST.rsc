module AST

data Module = module(str name, list[UsingDecl] uses, list[Declaration] decls);

data UsingDecl = usingDecl(str moduleName);

data Declaration
  = spaceDecl(SpaceDecl d)
  | operatorDecl(OperatorDecl d)
  | varDecl(VarDecl d)
  | ruleDecl(RuleDecl d)
  | exprDecl(ExpressionDecl d)
  | attrDecl(AttributeDecl d)
  | relDecl(RelationDecl d)
  ;

data SpaceDecl = spaceDecl(str name, list[str] super); // [] o [X]

data OperatorDecl = operatorDecl(str op, Type type);
data Type = funType(list[str] chain); // ej: ["Int","Double","Double"]

data AttributeDecl = attrDecl(AttributeList attrs);
data AttributeList = attrs(list[AttributeItem] items);
data AttributeItem = attrItem(str name, list[AttributeValue] val); // [] o [v]
data AttributeValue = attrValId(str v);

data VarDecl = varDecl(list[VarItem] items);
data VarItem = varItem(str name, str domain);

data RuleDecl = ruleDecl(OperatorApp lhs, OperatorApp rhs);
data OperatorApp = opApp(str op, list[Atom] args);

data Atom
  = atomId(str name)
  | atomInt(int v)
  | atomFloat(real v)
  | atomChar(str v)
  | atomApp(OperatorApp app);

data ExpressionDecl = exprDecl(Expression exp, list[AttributeList] attrs);

data Expression = impl(ImplicationExpr e);

data ImplicationExpr = implExpr(EquivalenceExpr left, list[EquivalenceExpr] rest);
data EquivalenceExpr = equivExpr(LogicalOrExpr left, list[LogicalOrExpr] rest);
data LogicalOrExpr = orExpr(LogicalAndExpr left, list[LogicalAndExpr] rest);
data LogicalAndExpr = andExpr(EqualityExpr left, list[EqualityExpr] rest);

data EqualityExpr = eqExpr(RelationalExpr left, list[RelPair] rest);
data RelPair = relPair(RelOp op, RelationalExpr rhs);

data RelationalExpr = relExpr(AdditiveExpr expr);
data RelOp = lt() | gt() | le() | ge() | ne() | inOp();

data AdditiveExpr = addExpr(MultiplicativeExpr left, list[AddPair] rest);
data AddPair = addPair(str op, MultiplicativeExpr rhs);

data MultiplicativeExpr = mulExpr(UnaryExpr left, list[MulPair] rest);
data MulPair = mulPair(str op, UnaryExpr rhs);

data UnaryExpr = negExpr(str op, UnaryExpr arg) | primExpr(PrimaryExpr p);

data PrimaryExpr
  = quant(QuantifiedExpr q)
  | app(OperatorApp app)
  | id(str name)
  | intLit(int v)
  | floatLit(real v)
  | charLit(str v)
  | par(Expression e);

data QuantifiedExpr = quantExpr(Quantifier q, str var, str domain, Expression body);
data Quantifier = all() | ex();

// Relación declarada con defer
data RelationDecl = relDecl(str name, Type type);