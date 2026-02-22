; extends

; struct field init: .k = v
(assignment_expression) @assignment.outer

(assignment_expression
  right: (_) @assignment.rhs)

(assignment_expression
  left: (_) @assignment.lhs)

(assignment_expression
  left: (_) @assignment.lhs_full)

; variable declarations: const x = ..., pub const x = ...
(variable_declaration
  (identifier) @assignment.lhs
  (_) @assignment.rhs) @assignment.outer

(variable_declaration
  . "const" @assignment.lhs_full
  . (identifier) @assignment.lhs_full)

(variable_declaration
  . "var" @assignment.lhs_full
  . (identifier) @assignment.lhs_full)

(variable_declaration
  . "pub" @assignment.lhs_full
  . ["const" "var"]
  . (identifier) @assignment.lhs_full)

; container fields: name: Type
(container_field
  name: (identifier) @assignment.lhs @assignment.lhs_full
  type: (_) @assignment.rhs) @assignment.outer
