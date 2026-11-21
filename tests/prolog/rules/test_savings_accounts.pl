:- encoding(utf8).
%=========================================================================================
% PRUEBAS DE prolog/rules/savings_accounts.pl
%=========================================================================================
:- ensure_loaded('../../test_helpers_savings').
:- ensure_loaded('../../../prolog/rules/savings_accounts').

:- begin_tests(rules_savings_accounts, [setup(sv_backup), cleanup(sv_restore)]).

% ---- valid_create_savings_account/4 ----
test(create_valida, [nondet, setup(sv_fixture)]) :- valid_create_savings_account(necesidad, "ropa", "compras", 10).
test(create_exacto_100, [nondet, setup(sv_fixture)]) :- valid_create_savings_account(necesidad, "ropa", "compras", 60).
test(create_excede_100, [setup(sv_fixture), fail]) :- valid_create_savings_account(necesidad, "ropa", "compras", 61).
test(create_repetida, [setup(sv_fixture), fail]) :- valid_create_savings_account(necesidad, "hospital", "x", 5).
test(create_misma_subcategoria_otra_categoria, [nondet, setup(sv_fixture)]) :- valid_create_savings_account(deseo, "hospital", "x", 5).
test(create_categoria_invalida, [setup(sv_fixture), fail]) :- valid_create_savings_account(inventada, "ropa", "x", 5).
test(create_subcategoria_vacia, [setup(sv_fixture), fail]) :- valid_create_savings_account(necesidad, "", "x", 5).
test(create_porcentaje_negativo, [setup(sv_fixture), fail]) :- valid_create_savings_account(necesidad, "ropa", "x", -5).
test(create_nombre_reservado, [setup(sv_fixture), fail]) :- valid_create_savings_account(necesidad, "Cuenta de Ahorro global", "x", 5).

% ---- valid_update_savings_account/6 ----
test(update_valida_renombrar, [nondet, setup(sv_fixture)]) :- valid_update_savings_account(necesidad, "hospital", necesidad, "salud", "d", 30).
test(update_valida_cambiar_porcentaje, [nondet, setup(sv_fixture)]) :- valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "d", 50).
test(update_mismo_nombre_ok, [nondet, setup(sv_fixture)]) :- valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "nueva", 30).
test(update_excede_100, [setup(sv_fixture), fail]) :- valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "d", 91).
test(update_nombre_ocupado, [setup(sv_fixture), fail]) :- valid_update_savings_account(necesidad, "hospital", deseo, "viajes", "d", 30).
test(update_cuenta_inexistente, [setup(sv_fixture), fail]) :- valid_update_savings_account(deseo, "nada", deseo, "otra", "d", 5).
test(update_global_no_se_toca, [setup(sv_fixture), fail]) :-
    valid_update_savings_account(global, "Cuenta de Ahorro global", deseo, "x", "y", 70).
test(update_argumentos_invalidos, [setup(sv_fixture), fail]) :- valid_update_savings_account(necesidad, "hospital", necesidad, "", "d", 30).

% ---- valid_delete_saving_account/5 ----
test(delete_con_saldo_cero, [nondet, setup((sv_fixture, sv_add_account(deseo, "vacia", "x", 0), sv_add_percent(2026, 6, 1, deseo, "vacia", 0)))]) :-
    valid_delete_saving_account(2026, 6, 1, deseo, "vacia").
test(delete_con_saldo_no_se_puede, [setup(sv_fixture), fail]) :- valid_delete_saving_account(2026, 5, 1, necesidad, "hospital").
test(delete_global_no_se_puede, [setup(sv_fixture), fail]) :- valid_delete_saving_account(2026, 5, 1, global, "Cuenta de Ahorro global").
test(delete_inexistente, [setup(sv_fixture), fail]) :- valid_delete_saving_account(2026, 5, 1, deseo, "nada").
test(delete_fecha_invalida, [setup((sv_fixture, sv_add_account(deseo, "vacia", "x", 0), sv_add_percent(2026, 6, 1, deseo, "vacia", 0))), fail]) :-
    valid_delete_saving_account(2026, 2, 30, deseo, "vacia").

% ---- valid_transfer/8 ----
test(transfer_valida, [nondet, setup(sv_fixture)]) :-
    valid_transfer(2026, 5, 10, global, "Cuenta de Ahorro global", necesidad, "hospital", 100).
test(transfer_todo_el_saldo, [nondet, setup(sv_fixture)]) :-
    valid_transfer(2026, 5, 10, necesidad, "hospital", deseo, "viajes", 65).
test(transfer_mas_que_el_saldo, [setup(sv_fixture), fail]) :-
    valid_transfer(2026, 5, 10, necesidad, "hospital", deseo, "viajes", 66).
test(transfer_misma_categoria_distinta_subcategoria, [nondet, setup((sv_fixture, sv_add_account(necesidad, "otra", "x", 0)))]) :-
    valid_transfer(2026, 5, 10, necesidad, "hospital", necesidad, "otra", 10).
test(transfer_misma_subcategoria_distinta_categoria, [nondet, setup((sv_fixture, sv_add_account(deseo, "hospital", "x", 0)))]) :-
    valid_transfer(2026, 5, 10, necesidad, "hospital", deseo, "hospital", 10).
test(transfer_a_si_misma, [setup(sv_fixture), fail]) :-
    valid_transfer(2026, 5, 10, necesidad, "hospital", necesidad, "hospital", 10).
test(transfer_monto_cero, [setup(sv_fixture), fail]) :- valid_transfer(2026, 5, 10, global, "Cuenta de Ahorro global", necesidad, "hospital", 0).
test(transfer_monto_negativo, [setup(sv_fixture), fail]) :- valid_transfer(2026, 5, 10, global, "Cuenta de Ahorro global", necesidad, "hospital", -5).
test(transfer_monto_no_numero, [setup(sv_fixture), fail]) :- valid_transfer(2026, 5, 10, global, "Cuenta de Ahorro global", necesidad, "hospital", "diez").
test(transfer_origen_inexistente, [setup(sv_fixture), fail]) :- valid_transfer(2026, 5, 10, deseo, "nada", necesidad, "hospital", 10).
test(transfer_destino_inexistente, [setup(sv_fixture), fail]) :- valid_transfer(2026, 5, 10, global, "Cuenta de Ahorro global", deseo, "nada", 10).
test(transfer_fecha_invalida, [setup(sv_fixture), fail]) :- valid_transfer(2026, 2, 30, global, "Cuenta de Ahorro global", necesidad, "hospital", 10).
test(transfer_considera_transferencias_previas,
     [setup((sv_fixture, sv_add_transfer(2026, 4, 1, necesidad, "hospital", deseo, "viajes", 100))), fail]) :-
    valid_transfer(2026, 5, 10, necesidad, "hospital", deseo, "viajes", 100).

:- end_tests(rules_savings_accounts).
