# First print of AST

Tokens size:5

chrono.ast.NodeKind.VariableDeclaration
	chrono.ast__union_23939{ .VariableDeclaration = chrono.ast__union_23939__struct_23940{ .name = { 120 }, .expression = chrono.ast{ .kind = chrono.ast.NodeKind.NumberLiteral, .data = chrono.ast__union_23939{ ... } } } }


## First multiple assignmet

Tokens size:26

Nodes has length of 5
Kind: VariableDeclaration
	VariableDeclaration:
	x
chrono.ast{ .kind = chrono.ast.NodeKind.NumberLiteral, .data = chrono.ast__union_23949{ .NumberLiteral = chrono.ast__union_23949__struct_23952{ .value = 20 } } }
Kind: VariableDeclaration
	VariableDeclaration:
	y
chrono.ast{ .kind = chrono.ast.NodeKind.NumberLiteral, .data = chrono.ast__union_23949{ .NumberLiteral = chrono.ast__union_23949__struct_23952{ .value = 40 } } }
Kind: VariableDeclaration
	VariableDeclaration:
	z
chrono.ast{ .kind = chrono.ast.NodeKind.NumberLiteral, .data = chrono.ast__union_23949{ .NumberLiteral = chrono.ast__union_23949__struct_23952{ .value = 50 } } }
Kind: Assignment
	Assignment:
	chrono.ast{ .kind = chrono.ast.NodeKind.VariableReference, .data = chrono.ast__union_23949{ .VariableReference = chrono.ast__union_23949__struct_23951{ .name = { ... } } } }
chrono.ast{ .kind = chrono.ast.NodeKind.NumberLiteral, .data = chrono.ast__union_23949{ .NumberLiteral = chrono.ast__union_23949__struct_23952{ .value = 25 } } }
Kind: Assignment
	Assignment:
	chrono.ast{ .kind = chrono.ast.NodeKind.VariableReference, .data = chrono.ast__union_23949{ .VariableReference = chrono.ast__union_23949__struct_23951{ .name = { ... } } } }
chrono.ast{ .kind = chrono.ast.NodeKind.NumberLiteral, .data = chrono.ast__union_23949{ .NumberLiteral = chrono.ast__union_23949__struct_23952{ .value = 45 } } }


## Multiple declarations, assignments and variable references

Last token type: chrono.token{ .token_type = chrono.token.TokenType{ .EOF = void }, .lexeme = {  } }
Tokens size:30

Nodes has length of 8
Kind: VariableDeclaration
	VariableDeclaration:
	x
chrono.ast{ .kind = chrono.ast.NodeKind.NumberLiteral, .data = chrono.ast__union_23955{ .NumberLiteral = chrono.ast__union_23955__struct_23958{ .value = 20 } } }
Kind: VariableDeclaration
	VariableDeclaration:
	y
chrono.ast{ .kind = chrono.ast.NodeKind.NumberLiteral, .data = chrono.ast__union_23955{ .NumberLiteral = chrono.ast__union_23955__struct_23958{ .value = 40 } } }
Kind: VariableDeclaration
	VariableDeclaration:
	z
chrono.ast{ .kind = chrono.ast.NodeKind.NumberLiteral, .data = chrono.ast__union_23955{ .NumberLiteral = chrono.ast__union_23955__struct_23958{ .value = 50 } } }
Kind: Assignment
	Assignment:
	chrono.ast{ .kind = chrono.ast.NodeKind.VariableReference, .data = chrono.ast__union_23955{ .VariableReference = chrono.ast__union_23955__struct_23957{ .name = { ... } } } }
chrono.ast{ .kind = chrono.ast.NodeKind.NumberLiteral, .data = chrono.ast__union_23955{ .NumberLiteral = chrono.ast__union_23955__struct_23958{ .value = 25 } } }
Kind: Assignment
	Assignment:
	chrono.ast{ .kind = chrono.ast.NodeKind.VariableReference, .data = chrono.ast__union_23955{ .VariableReference = chrono.ast__union_23955__struct_23957{ .name = { ... } } } }
chrono.ast{ .kind = chrono.ast.NodeKind.NumberLiteral, .data = chrono.ast__union_23955{ .NumberLiteral = chrono.ast__union_23955__struct_23958{ .value = 45 } } }
Kind: VariableReference
	VariableReference:
	z
Kind: VariableReference
	VariableReference:
	x
Kind: VariableReference
	VariableReference:
	y
