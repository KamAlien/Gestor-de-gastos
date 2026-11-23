:- encoding(utf8).
%=========================================================================================
% PRUEBAS DE prolog/operations/savings_account.pl
%=========================================================================================
:- ensure_loaded('../../test_helpers_savings').
:- ensure_loaded('../../../prolog/operations/savings_account').

:- begin_tests(savings_account, [setup(sv_backup), cleanup(sv_restore)]).

% ---- total_up_to/4 y adjustments_up_to/3 ----
test(total_ingresos_hasta, [setup(sv_fixture), true(T =:= 2500)]) :- total_up_to(incomes, 2026, 4, T).
test(total_gastos_hasta,   [setup(sv_fixture), true(T =:= 2150)]) :- total_up_to(expenses_amount, 2026, 5, T).
test(total_hasta_mes_sin_datos, [setup(sv_fixture), true(T =:= 0)]) :- total_up_to(incomes, 2026, 2, T).
test(ajustes_hasta, [setup(sv_fixture), true(T =:= 50)]) :- adjustments_up_to(2026, 6, T).
test(ajustes_antes, [setup(sv_fixture), true(T =:= 0)]) :- adjustments_up_to(2026, 2, T).

% ---- saving_count_money/5 ----
test(count_money_existente, [setup(sv_fixture), true(B =:= 65)]) :- saving_count_money(necesidad, "hospital", 2026, 5, B).
test(count_money_inexistente, [setup(sv_fixture), fail]) :- saving_count_money(deseo, "nada", 2026, 5, _).

% ---- create_saving_account/7 ----
test(create_guarda_cuenta_e_historial, [setup(sv_fixture), true((N == 1, H == [2026-6-1-10]))]) :-
    create_saving_account(2026, 6, 1, necesidad, "ropa", "compras", 10),
    sv_count_accounts(necesidad, "ropa", N), sv_percent_history(necesidad, "ropa", H).
test(create_recalcula_la_global, [setup(sv_fixture), true(P =:= 50)]) :-
    create_saving_account(2026, 6, 1, necesidad, "ropa", "compras", 10),
    sv_account_percent(global, "Cuenta de Ahorro global", P).
test(create_global_guarda_su_tramo, [setup(sv_fixture), true(memberchk(2026-6-1-50, H))]) :-
    create_saving_account(2026, 6, 1, necesidad, "ropa", "compras", 10),
    sv_percent_history(global, "Cuenta de Ahorro global", H).
test(create_conserva_pasado, [setup(sv_fixture), true(B =:= 295)]) :-
    create_saving_account(2026, 6, 1, necesidad, "ropa", "compras", 10),
    savings_account_balance(global, "Cuenta de Ahorro global", 2026, 5, B).

% ---- update_global_account/3 ----
test(global_sin_cambios_no_agrega_tramo, [setup(sv_fixture), true(H0 == H1)]) :-
    sv_percent_history(global, "Cuenta de Ahorro global", H0),
    update_global_account(2026, 6, 1),
    sv_percent_history(global, "Cuenta de Ahorro global", H1).
test(global_es_el_sobrante, [setup((sv_fixture, sv_add_account(deseo, "extra", "x", 20))), true(P =:= 40)]) :-
    update_global_account(2026, 6, 1),
    sv_account_percent(global, "Cuenta de Ahorro global", P).

% ---- update_history_percent/5 ----
test(history_renombra_todo, [setup(sv_fixture), true((H == [], N == [2026-3-1-20, 2026-5-1-30]))]) :-
    update_history_percent([2026-3-1-20, 2026-5-1-30], necesidad, "hospital", necesidad, "salud"),
    sv_percent_history(necesidad, "hospital", H), sv_percent_history(necesidad, "salud", N0), msort(N0, N).
test(history_lista_vacia, [setup(sv_fixture)]) :- update_history_percent([], necesidad, "hospital", necesidad, "salud").

% ---- update_savings_account/9 ----
test(update_renombra_y_mueve_historial, [setup(sv_fixture), true((N0 == 0, N1 == 1, H == [2026-3-1-20, 2026-5-1-30]))]) :-
    update_savings_account(2026, 6, 1, necesidad, "hospital", necesidad, "salud", "nueva", 30),
    sv_count_accounts(necesidad, "hospital", N0), sv_count_accounts(necesidad, "salud", N1),
    sv_percent_history(necesidad, "salud", H0), msort(H0, H).
test(update_cambia_descripcion, [setup(sv_fixture), true(D == "nueva")]) :-
    update_savings_account(2026, 6, 1, necesidad, "hospital", necesidad, "hospital", "nueva", 30),
    savings_account(necesidad, "hospital", D, _).
test(update_cambia_porcentaje_agrega_tramo, [setup(sv_fixture), true(memberchk(2026-6-1-35, H))]) :-
    update_savings_account(2026, 6, 1, necesidad, "hospital", necesidad, "hospital", "d", 35),
    sv_percent_history(necesidad, "hospital", H).
test(update_porcentaje_igual_no_agrega_tramo, [setup(sv_fixture), true(H == [2026-3-1-20, 2026-5-1-30])]) :-
    update_savings_account(2026, 6, 1, necesidad, "hospital", necesidad, "hospital", "d", 30),
    sv_percent_history(necesidad, "hospital", H0), msort(H0, H).
test(update_recalcula_global, [setup(sv_fixture), true(P =:= 55)]) :-
    update_savings_account(2026, 6, 1, necesidad, "hospital", necesidad, "hospital", "d", 35),
    sv_account_percent(global, "Cuenta de Ahorro global", P).
test(update_no_cambia_el_pasado, [setup(sv_fixture), true(B =:= 65)]) :-
    update_savings_account(2026, 6, 1, necesidad, "hospital", necesidad, "hospital", "d", 35),
    savings_account_balance(necesidad, "hospital", 2026, 5, B).
test(update_cuenta_inexistente, [setup(sv_fixture), fail]) :-
    update_savings_account(2026, 6, 1, deseo, "nada", deseo, "otra", "d", 5).

% ---- delete_savings_account/5 ----
test(delete_quita_cuenta_e_historial, [setup(sv_fixture), true((N == 0, H == []))]) :-
    delete_savings_account(2026, 6, 1, deseo, "viajes"),
    sv_count_accounts(deseo, "viajes", N), sv_percent_history(deseo, "viajes", H).
test(delete_recalcula_global, [setup(sv_fixture), true(P =:= 70)]) :-
    delete_savings_account(2026, 6, 1, deseo, "viajes"),
    sv_account_percent(global, "Cuenta de Ahorro global", P).
test(delete_inexistente, [setup(sv_fixture), fail]) :- delete_savings_account(2026, 6, 1, deseo, "nada").

% ---- save_transfer/8 ----
test(save_transfer_guarda, [setup(sv_fixture), true(N == 1)]) :-
    save_transfer(2026, 4, 3, global, "Cuenta de Ahorro global", necesidad, "hospital", 100),
    sv_count_transfers(N).
test(save_transfer_afecta_saldos, [setup(sv_fixture), true(B =:= 210)]) :-
    save_transfer(2026, 4, 3, global, "Cuenta de Ahorro global", necesidad, "hospital", 100),
    savings_account_balance(necesidad, "hospital", 2026, 4, B).

:- end_tests(savings_account).
