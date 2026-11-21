:- encoding(utf8).
%=========================================================================================
% PRUEBAS DE prolog/operations/savings.pl (una sola responsabilidad: este archivo)
%=========================================================================================
:- ensure_loaded('../../test_helpers_savings').
:- ensure_loaded('../../../prolog/operations/savings').

:- begin_tests(savings, [setup(sv_backup), cleanup(sv_restore)]).

% ---- total_month_saving/3 ----
test(total_con_ajuste,  [setup(sv_fixture), true(T =:= 350)])  :- total_month_saving(2026, 3, T).
test(total_sin_ajuste,  [setup(sv_fixture), true(T =:= 200)])  :- total_month_saving(2026, 4, T).
test(total_negativo,    [setup(sv_fixture), true(T =:= -150)]) :- total_month_saving(2026, 5, T).
test(total_mes_vacio,   [setup(sv_fixture), true(T =:= 0)])    :- total_month_saving(2026, 6, T).
test(total_varios_ajustes, [setup((sv_fixture, sv_add_adjustment(2026, 3, 9, -20))), true(T =:= 330)]) :-
    total_month_saving(2026, 3, T).

% ---- operation_savings/5 ----
test(operation_diferencia, [setup(sv_fixture), true(R =:= -150)]) :- operation_savings(2026, 2026, 4, 3, R).
test(operation_cero,       [setup(sv_fixture), true(R =:= 0)])    :- operation_savings(2026, 2026, 6, 6, R).

% ---- compare_savings_with_lastmonth/4 y compare_savings/4 ----
% (el texto del mensaje lo decide compare_result/2, que no es de este archivo: solo se exige que exista)
test(compare_mes_normal, [setup(sv_fixture), nondet, true(R =:= -150)]) :-
    compare_savings_with_lastmonth(2026, 4, R, M), ground(M).
test(compare_enero_usa_diciembre,
     [setup((sv_fixture, sv_add_income(2025, 12, 100), sv_add_income(2026, 1, 300))), nondet, true(R =:= 200)]) :-
    compare_savings_with_lastmonth(2026, 1, R, M), ground(M).
test(compare_sin_cambio, [setup(sv_fixture), nondet, true(R =:= 0)]) :-
    compare_savings_with_lastmonth(2026, 7, R, M), ground(M).
test(compare_savings_delega, [setup(sv_fixture), nondet, true(R =:= 200 - 350)]) :-
    compare_savings(2026, 4, R, M), ground(M).

% ---- porcentaje_ahorro/3 ----
test(porcentaje_normal, [setup(sv_fixture), true(abs(P - 350/1500*100) < 1.0e-9)]) :- porcentaje_ahorro(2026, 3, P).
test(porcentaje_sin_ingresos, [setup(sv_fixture), true(P =:= 0)]) :- porcentaje_ahorro(2026, 5, P).
test(porcentaje_negativo_si_gasta_mas,
     [setup((sv_fixture, sv_add_income(2026, 5, 100))), true(P =:= -50)]) :- porcentaje_ahorro(2026, 5, P).

:- end_tests(savings).
