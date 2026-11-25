:- encoding(utf8).
%=========================================================================================
% PRUEBAS DE prolog/operations/savings_adjustments.pl
% (historial_month/2 y historial_savings_adj_data/3 dependen de historial.pl: se prueban alli)
%=========================================================================================
:- ensure_loaded('../../test_helpers_savings').
:- ensure_loaded('../../../prolog/operations/savings_adjustments').

:- begin_tests(savings_adjustments, [setup(sv_backup), cleanup(sv_restore)]).

% ---- exist_adjustment/5 ----
test(exist_uno, [setup(sv_fixture), nondet, true(N == 1)]) :- exist_adjustment(2026, 3, 5, 50, N).
test(exist_repetido, [setup((sv_fixture, sv_add_adjustment(2026, 3, 5, 50))), nondet, true(N == 2)]) :-
    exist_adjustment(2026, 3, 5, 50, N).
test(exist_no, [setup(sv_fixture), fail]) :- exist_adjustment(2026, 3, 5, 99, _).

% ---- change_saving/4 ----
test(change_crea_ajuste, [setup(sv_fixture), true(N == 1)]) :-
    change_saving(2026, 6, 1, 25), sv_count_adjustments(2026, 6, 1, 25, N).
test(change_afecta_el_ahorro, [setup(sv_fixture), true(T =:= 25)]) :-
    change_saving(2026, 6, 1, 25), total_month_saving(2026, 6, T).
test(change_acepta_negativo, [setup(sv_fixture), true(T =:= -30)]) :-
    change_saving(2026, 6, 1, -30), total_month_saving(2026, 6, T).
test(change_mes_sin_datos_no_falla, [setup(sv_clear)]) :- change_saving(2030, 1, 1, 10).

% ---- delete_savings_adjustments/4 ----
test(delete_quita_ajuste, [setup(sv_fixture), true(N == 0)]) :-
    delete_savings_adjustments(2026, 3, 5, 50), sv_count_adjustments(2026, 3, 5, 50, N).
test(delete_cambia_el_ahorro, [setup(sv_fixture), true(T =:= 300)]) :-
    delete_savings_adjustments(2026, 3, 5, 50), total_month_saving(2026, 3, T).
test(delete_solo_uno_si_hay_repetidos, [setup((sv_fixture, sv_add_adjustment(2026, 3, 5, 50))), true(N == 1)]) :-
    delete_savings_adjustments(2026, 3, 5, 50), sv_count_adjustments(2026, 3, 5, 50, N).
test(delete_inexistente, [setup(sv_fixture), fail]) :- delete_savings_adjustments(2026, 3, 5, 99).

:- end_tests(savings_adjustments).
