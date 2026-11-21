:- encoding(utf8).
%=========================================================================================
% PRUEBAS DE prolog/operations/auxiliary methods/account_balance.pl
%=========================================================================================
:- ensure_loaded('../../../test_helpers_savings').
:- ensure_loaded('../../../../prolog/operations/auxiliary methods/account_balance').

:- begin_tests(account_balance, [setup(sv_backup), cleanup(sv_restore)]).

% ---- month_index/3 ----
test(month_index, true(I =:= 24313)) :- month_index(2026, 1, I).
test(month_index_consecutivo, true(B =:= A + 1)) :- month_index(2025, 12, A), month_index(2026, 1, B).

% ---- saving_between/3 (cuenta Start, no cuenta End) ----
test(between_dos_meses, [setup(sv_fixture), true(S =:= 550)]) :-
    month_index(2026, 3, A), month_index(2026, 5, B), saving_between(A, B, S).
test(between_un_mes, [setup(sv_fixture), true(S =:= 350)]) :-
    month_index(2026, 3, A), month_index(2026, 4, B), saving_between(A, B, S).
test(between_vacio, [setup(sv_fixture), true(S =:= 0)]) :-
    month_index(2026, 5, A), saving_between(A, A, S).
test(between_cruza_anio, [setup((sv_fixture, sv_add_income(2025, 12, 40))), true(S =:= 40)]) :-
    month_index(2025, 12, A), month_index(2026, 1, B), saving_between(A, B, S).

% ---- account_changes/5 ----
test(changes_ordenados, [setup(sv_fixture), true(C == [Y3-20, Y5-30])]) :-
    month_index(2026, 3, Y3), month_index(2026, 5, Y5), account_changes(necesidad, "hospital", 2026, 6, C).
test(changes_corta_en_el_mes, [setup(sv_fixture), true(C == [Y3-20])]) :-
    month_index(2026, 3, Y3), account_changes(necesidad, "hospital", 2026, 4, C).
test(changes_antes_de_crearse, [setup(sv_fixture), true(C == [])]) :-
    account_changes(necesidad, "hospital", 2026, 2, C).
test(changes_cuenta_inexistente, [setup(sv_fixture), true(C == [])]) :-
    account_changes(deseo, "nada", 2026, 6, C).

% ---- tramos_share/5 ----
test(tramos_ultimo_tramo, [setup(sv_fixture), true(S == [110])]) :-
    month_index(2026, 3, A), month_index(2026, 5, End), tramos_share([], A, 20, End, S).
test(tramos_dos_tramos, [setup(sv_fixture), true(S == [110, -45])]) :-
    month_index(2026, 3, A), month_index(2026, 5, B), month_index(2026, 6, End),
    tramos_share([B-30], A, 20, End, S).

% ---- savings_account_balance/5 ----
test(balance_primer_mes, [setup(sv_fixture), true(B =:= 70)])  :- savings_account_balance(necesidad, "hospital", 2026, 3, B).
test(balance_dos_meses, [setup(sv_fixture), true(B =:= 110)]) :- savings_account_balance(necesidad, "hospital", 2026, 4, B).
test(balance_cambio_de_porcentaje, [setup(sv_fixture), true(B =:= 65)]) :- savings_account_balance(necesidad, "hospital", 2026, 5, B).
test(balance_global, [setup(sv_fixture), true(B =:= 295)]) :- savings_account_balance(global, "Cuenta de Ahorro global", 2026, 5, B).
test(balance_viajes, [setup(sv_fixture), true(B =:= 40)]) :- savings_account_balance(deseo, "viajes", 2026, 5, B).
test(balance_antes_de_existir, [setup(sv_fixture), true(B =:= 0)]) :- savings_account_balance(necesidad, "hospital", 2026, 2, B).
test(balance_cuenta_inexistente, [setup(sv_fixture), fail]) :- savings_account_balance(deseo, "nada", 2026, 5, _).
test(balance_suma_todo_el_ahorro, [setup(sv_fixture), true(abs(T - 400) < 1.0e-9)]) :-
    findall(B, (member(C-S, [global-"Cuenta de Ahorro global", necesidad-"hospital", deseo-"viajes"]),
                savings_account_balance(C, S, 2026, 5, B)), L),
    sum_list(L, T).

% ---- transferencias ----
test(balance_con_transferencia_recibida, [setup((sv_fixture, sv_add_transfer(2026, 4, 3, global, "Cuenta de Ahorro global", necesidad, "hospital", 100))), true(B =:= 210)]) :-
    savings_account_balance(necesidad, "hospital", 2026, 4, B).
test(balance_con_transferencia_enviada, [setup((sv_fixture, sv_add_transfer(2026, 4, 3, global, "Cuenta de Ahorro global", necesidad, "hospital", 100))), true(B =:= 285)]) :-
    savings_account_balance(global, "Cuenta de Ahorro global", 2026, 4, B).
test(transferencia_futura_no_cuenta, [setup((sv_fixture, sv_add_transfer(2026, 5, 3, global, "Cuenta de Ahorro global", necesidad, "hospital", 100))), true(B =:= 110)]) :-
    savings_account_balance(necesidad, "hospital", 2026, 4, B).
test(transferencias_conservan_el_total,
     [setup((sv_fixture, sv_add_transfer(2026, 4, 3, global, "Cuenta de Ahorro global", necesidad, "hospital", 100))),
      true(abs(T - 400) < 1.0e-9)]) :-
    findall(B, (member(C-S, [global-"Cuenta de Ahorro global", necesidad-"hospital", deseo-"viajes"]),
                savings_account_balance(C, S, 2026, 5, B)), L),
    sum_list(L, T).

% ---- net_transfers/4 ----
test(net_sin_transferencias, [setup(sv_fixture), true(N =:= 0)]) :- month_index(2026, 5, L), net_transfers(deseo, "viajes", L, N).
test(net_recibe_y_envia,
     [setup((sv_fixture,
             sv_add_transfer(2026, 4, 1, global, "Cuenta de Ahorro global", deseo, "viajes", 30),
             sv_add_transfer(2026, 5, 1, deseo, "viajes", necesidad, "hospital", 10))),
      true(N =:= 20)]) :-
    month_index(2026, 5, L), net_transfers(deseo, "viajes", L, N).

% ---- sum_percent/1 ----
test(sum_percent_sin_global, [setup(sv_fixture), true(P =:= 40)]) :- sum_percent(P).
test(sum_percent_sin_cuentas, [setup(sv_clear), true(P =:= 0)]) :- sum_percent(P).

:- end_tests(account_balance).
