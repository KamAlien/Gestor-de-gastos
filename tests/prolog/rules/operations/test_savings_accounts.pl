:- encoding(utf8).
%=========================================================================================
% PRUEBAS DE prolog/rules/operations/savings_accounts.pl
%=========================================================================================
:- ensure_loaded('../../../test_helpers_savings').
:- ensure_loaded('../../../../prolog/rules/operations/savings_accounts').

:- begin_tests(rules_operations_savings_accounts, [setup(sv_backup), cleanup(sv_restore)]).

% ---- arguments_rules/4 ----
test(args_validos) :- arguments_rules(necesidad, "ropa", "compras", 10).
test(args_porcentaje_cero) :- arguments_rules(deseo, "ropa", "compras", 0).
test(args_porcentaje_decimal) :- arguments_rules(deseo, "ropa", "compras", 12.5).
test(args_descripcion_no_string, [fail]) :- arguments_rules(necesidad, "ropa", compras, 10).
test(args_categoria_invalida, [fail]) :- arguments_rules(global, "ropa", "x", 10).
test(args_subcategoria_no_string, [fail]) :- arguments_rules(necesidad, ropa, "x", 10).
test(args_subcategoria_vacia, [fail]) :- arguments_rules(necesidad, "", "x", 10).
test(args_subcategoria_reservada, [fail]) :- arguments_rules(necesidad, "Cuenta de Ahorro global", "x", 10).
test(args_descripcion_vacia, [fail]) :- arguments_rules(necesidad, "ropa", "", 10).
test(args_porcentaje_negativo, [fail]) :- arguments_rules(necesidad, "ropa", "x", -1).
test(args_porcentaje_no_numero, [fail]) :- arguments_rules(necesidad, "ropa", "x", "10").

% ---- get_saving_account/3 ----
test(get_existente, [setup(sv_fixture), true(L == [(necesidad, "hospital", 30)])]) :- get_saving_account(necesidad, "hospital", L).
test(get_inexistente, [setup(sv_fixture), true(L == [])]) :- get_saving_account(deseo, "nada", L).

% ---- not_exist_sb/1 y exist_sb/1 ----
test(not_exist_lista_vacia) :- not_exist_sb([]).
test(not_exist_con_elementos, [fail]) :- not_exist_sb([a]).
test(exist_un_elemento) :- exist_sb([a]).
test(exist_vacia, [fail]) :- exist_sb([]).
test(exist_dos_elementos, [fail]) :- exist_sb([a, b]).

% ---- sum_savings_account_percent/2 (no cuenta la global) ----
test(sum_nueva_cabe, [setup(sv_fixture), true(T =:= 50)]) :- sum_savings_account_percent(10, T).
test(sum_justo_100, [setup(sv_fixture), true(T =:= 100)]) :- sum_savings_account_percent(60, T).
test(sum_se_pasa, [setup(sv_fixture), fail]) :- sum_savings_account_percent(61, _).
test(sum_cero, [setup(sv_fixture), true(T =:= 40)]) :- sum_savings_account_percent(0, T).
test(sum_diferencia_negativa, [setup(sv_fixture), true(T =:= 35)]) :- sum_savings_account_percent(-5, T).

% ---- new_name_is_free/4 ----
test(nombre_igual_al_anterior, [setup(sv_fixture)]) :- new_name_is_free(necesidad, "hospital", necesidad, "hospital").
test(nombre_nuevo_libre, [setup(sv_fixture)]) :- new_name_is_free(necesidad, "hospital", necesidad, "salud").
test(nombre_ocupado, [setup(sv_fixture), fail]) :- new_name_is_free(necesidad, "hospital", deseo, "viajes").
test(misma_sub_otra_categoria_libre, [setup(sv_fixture)]) :- new_name_is_free(necesidad, "hospital", deseo, "hospital").

% ---- diferent_is_valid/2 ----
test(igual_porcentaje, [setup(sv_fixture)]) :- diferent_is_valid(30, 30).
test(igual_numerico_entero_y_decimal, [setup(sv_fixture)]) :- diferent_is_valid(30.0, 30).
test(sube_y_cabe, [setup(sv_fixture)]) :- diferent_is_valid(90, 30).
test(sube_y_se_pasa, [setup(sv_fixture), fail]) :- diferent_is_valid(91, 30).
test(baja, [setup(sv_fixture)]) :- diferent_is_valid(0, 30).
test(determinista, [setup(sv_fixture)]) :- diferent_is_valid(40, 30).  % sin nondet: no deja puntos de eleccion

:- end_tests(rules_operations_savings_accounts).
