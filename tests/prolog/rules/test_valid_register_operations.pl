:- encoding(utf8).
%=========================================================================================
% PRUEBAS DE prolog/rules/valid_register_operations.pl
% (supone: valid_day/3 valida fechas reales; income_type/1 e expenses_type/1 definen las categorias)
%=========================================================================================
:- ensure_loaded('../../../prolog/rules/valid_register_operations').

:- begin_tests(valid_register_operations).

% ---- general_validation/5 ----
test(general_valida, [nondet]) :- general_validation(2026, 3, 1, "sueldo", 100).
test(general_monto_cero, [nondet]) :- general_validation(2026, 3, 1, "sueldo", 0).
test(general_bisiesto, [nondet]) :- general_validation(2028, 2, 29, "x", 1).
test(general_no_bisiesto, [fail]) :- general_validation(2026, 2, 29, "x", 1).
test(general_mes_13, [fail]) :- general_validation(2026, 13, 1, "x", 1).
test(general_dia_0, [fail]) :- general_validation(2026, 3, 0, "x", 1).
test(general_dia_32, [fail]) :- general_validation(2026, 3, 32, "x", 1).
test(general_anio_no_entero, [fail]) :- general_validation("2026", 3, 1, "x", 1).
test(general_descripcion_vacia, [fail]) :- general_validation(2026, 3, 1, "", 1).
test(general_descripcion_no_string, [fail]) :- general_validation(2026, 3, 1, sueldo, 1).
test(general_monto_negativo, [fail]) :- general_validation(2026, 3, 1, "x", -1).
test(general_monto_no_entero, [fail]) :- general_validation(2026, 3, 1, "x", 1.5).
test(general_monto_texto, [fail]) :- general_validation(2026, 3, 1, "x", "1").

% ---- valid_incomes/6 ----
test(incomes_valido, [nondet]) :- valid_incomes(2026, 3, 1, "sueldo", 1500, salario).
test(incomes_categoria_de_gasto, [fail]) :- valid_incomes(2026, 3, 1, "x", 10, necesidad).
test(incomes_categoria_inventada, [fail]) :- valid_incomes(2026, 3, 1, "x", 10, inventada).
test(incomes_datos_invalidos, [fail]) :- valid_incomes(2026, 3, 1, "", 10, salario).

% ---- valid_expenses/6 ----
test(expenses_valido, [nondet]) :- valid_expenses(2026, 3, 1, "renta", 1200, necesidad).
test(expenses_categoria_de_ingreso, [fail]) :- valid_expenses(2026, 3, 1, "x", 10, salario).
test(expenses_categoria_inventada, [fail]) :- valid_expenses(2026, 3, 1, "x", 10, inventada).
test(expenses_datos_invalidos, [fail]) :- valid_expenses(2026, 3, 1, "x", -10, necesidad).

% ---- valid_changes_saving/4 ----
test(changes_positivo, [nondet]) :- valid_changes_saving(2026, 3, 1, 50).
test(changes_negativo, [nondet]) :- valid_changes_saving(2026, 3, 1, -50).
test(changes_decimal, [nondet]) :- valid_changes_saving(2026, 3, 1, 2.5).
test(changes_no_numero, [fail]) :- valid_changes_saving(2026, 3, 1, "50").
test(changes_fecha_invalida, [fail]) :- valid_changes_saving(2026, 2, 30, 50).

:- end_tests(valid_register_operations).
