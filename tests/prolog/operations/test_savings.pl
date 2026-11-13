
%=================================================================================================================================================
% TESTS DE LOS AHORROS (prolog/operations/savings.pl)
% Incluye: total_month_saving/3, save_saving/2, update_saving/3, operation_savings/5 y porcentaje_ahorro/3.
% Correr desde la carpeta del proyecto:
%   swipl -g run_tests -t halt tests/prolog/operations/test_savings.pl
%
% Cada test que usa datos empieza con esto (y al terminar se restauran los datos que habia):
%   Ingresos: marzo 150 y abril 150      Gastos: marzo 50 y abril 50      Ajustes: ninguno
%   -> se ahorran 100 cada mes.   La tabla month_saving empieza vacia.
%=================================================================================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../prolog/operations/savings').
 
%--------------------------------------------------------------------------
% Ayudas (prefijo sv_)
%--------------------------------------------------------------------------
sv_save :-
    findall(incomes(Y, M, D, De, A, T), incomes(Y, M, D, De, A, T), Incomes),
    findall(expenses(Y, M, D, De, A, C, S), expenses(Y, M, D, De, A, C, S), Expenses),
    findall(savings_adjustments(Y, M, D, A), savings_adjustments(Y, M, D, A), Adjustments),
    findall(month_saving(Y, M, A), month_saving(Y, M, A), Months),
    nb_setval(sv_saved, [Incomes, Expenses, Adjustments, Months]),
    sv_clear.
 
sv_clear :-
    retractall(incomes(_, _, _, _, _, _)),
    retractall(expenses(_, _, _, _, _, _, _)),
    retractall(savings_adjustments(_, _, _, _)),
    retractall(month_saving(_, _, _)).
 
sv_restore :-
    sv_clear,
    nb_getval(sv_saved, Saved),
    forall(( member(Group, Saved), member(Fact, Group) ), assertz(Fact)).
 
sv_with_data :-
    sv_save,
    assertz(incomes(2026, 3, 1, "Salario", 150, salario)),
    assertz(incomes(2026, 4, 1, "Salario", 150, salario)),
    assertz(expenses(2026, 3, 2, "Super", 50, necesidad, "super")),
    assertz(expenses(2026, 4, 2, "Super", 50, necesidad, "super")).
 
% Los tests no pueden hacer assertz/retractall directo (irian al modulo del test): se hace desde aqui.
sv_add(Fact) :- assertz(Fact).
 
sv_count_month_saving(Year, Month, N) :-
    findall(x, month_saving(Year, Month, _), L),
    length(L, N).
 
sv_count_all_month_saving(N) :-
    findall(x, month_saving(_, _, _), L),
    length(L, N).
 
sv_close(A, B) :- abs(A - B) < 1.0e-9.
 
%--------------------------------------------------------------------------
% total_month_saving/3 : ingresos - gastos + ajustes
%--------------------------------------------------------------------------
:- begin_tests(total_month_saving).
 
test(income_minus_expenses, [setup(sv_with_data), cleanup(sv_restore)]) :-
    total_month_saving(2026, 3, T),
    T =:= 100.
 
test(month_without_movements_is_zero, [setup(sv_with_data), cleanup(sv_restore)]) :-
    total_month_saving(2026, 9, T),
    T =:= 0.
 
test(positive_adjustment_adds, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(savings_adjustments(2026, 3, 5, 50)),
    total_month_saving(2026, 3, T),
    T =:= 150.
 
test(negative_adjustment_subtracts, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(savings_adjustments(2026, 3, 5, -30)),
    total_month_saving(2026, 3, T),
    T =:= 70.
 
test(several_adjustments_are_added, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(savings_adjustments(2026, 3, 5, 50)),
    sv_add(savings_adjustments(2026, 3, 6, -20)),
    sv_add(savings_adjustments(2026, 3, 7, 10)),
    total_month_saving(2026, 3, T),
    T =:= 140.
 
test(adjustments_of_other_months_do_not_count, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(savings_adjustments(2026, 4, 5, 50)),
    sv_add(savings_adjustments(2025, 3, 5, 70)),
    total_month_saving(2026, 3, T),
    T =:= 100.
 
test(can_be_negative, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(expenses(2026, 3, 9, "Gasto grande", 300, necesidad, "x")),
    total_month_saving(2026, 3, T),
    T =:= -200.
 
test(only_adjustments_in_a_month_without_movements, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(savings_adjustments(2026, 9, 5, 25)),
    total_month_saving(2026, 9, T),
    T =:= 25.
 
test(decimals, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(savings_adjustments(2026, 3, 5, 0.5)),
    total_month_saving(2026, 3, T),
    sv_close(T, 100.5).
 
test(does_not_change_the_data, [setup(sv_with_data), cleanup(sv_restore)]) :-
    total_month_saving(2026, 3, _),
    sv_count_all_month_saving(N),
    N =:= 0.
 
:- end_tests(total_month_saving).
 
%--------------------------------------------------------------------------
% save_saving/2 : guarda en month_saving lo que se ahorro ese mes
%--------------------------------------------------------------------------
:- begin_tests(save_saving).
 
test(saves_the_total_of_the_month, [setup(sv_with_data), cleanup(sv_restore)]) :-
    save_saving(2026, 3),
    month_saving(2026, 3, T),
    T =:= 100.
 
test(saves_exactly_one_row, [setup(sv_with_data), cleanup(sv_restore)]) :-
    save_saving(2026, 3),
    sv_count_month_saving(2026, 3, N),
    N =:= 1.
 
test(includes_the_adjustments, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(savings_adjustments(2026, 3, 5, 50)),
    save_saving(2026, 3),
    month_saving(2026, 3, T),
    T =:= 150.
 
test(a_month_without_movements_saves_zero, [setup(sv_with_data), cleanup(sv_restore)]) :-
    save_saving(2026, 9),
    month_saving(2026, 9, T),
    T =:= 0.
 
test(does_not_touch_other_months, [setup(sv_with_data), cleanup(sv_restore)]) :-
    save_saving(2026, 3),
    sv_count_all_month_saving(N),
    N =:= 1.
 
test(two_different_months_two_rows, [setup(sv_with_data), cleanup(sv_restore)]) :-
    save_saving(2026, 3),
    save_saving(2026, 4),
    sv_count_all_month_saving(N),
    N =:= 2.
 
test(saved_value_matches_the_computed_one, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(savings_adjustments(2026, 3, 5, -30)),
    save_saving(2026, 3),
    month_saving(2026, 3, Saved),
    total_month_saving(2026, 3, Computed),
    Saved =:= Computed.
 
% Guardar el mismo mes dos veces deberia dejar UNA sola fila (decide si reemplaza o si falla).
% Ahora deja dos filas repetidas, y despues update_saving solo actualiza la primera.
test(saving_twice_does_not_leave_two_rows,
     [blocked('decidir que hace save_saving si el mes ya esta guardado'), setup(sv_with_data), cleanup(sv_restore)]) :-
    save_saving(2026, 3),
    ( save_saving(2026, 3) -> true ; true ),
    sv_count_month_saving(2026, 3, N),
    N =< 1.
 
:- end_tests(save_saving).
 
%--------------------------------------------------------------------------
% update_saving/3 : suma un cambio al ahorro guardado de un mes
%--------------------------------------------------------------------------
:- begin_tests(update_saving).
 
test(adds_the_change, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(month_saving(2026, 3, 100)),
    update_saving(2026, 3, 30),
    month_saving(2026, 3, T),
    T =:= 130.
 
test(negative_change_subtracts, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(month_saving(2026, 3, 100)),
    update_saving(2026, 3, -30),
    month_saving(2026, 3, T),
    T =:= 70.
 
test(can_go_below_zero, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(month_saving(2026, 3, 100)),
    update_saving(2026, 3, -150),
    month_saving(2026, 3, T),
    T =:= -50.
 
test(zero_change_keeps_the_value, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(month_saving(2026, 3, 100)),
    update_saving(2026, 3, 0),
    month_saving(2026, 3, T),
    T =:= 100.
 
test(keeps_one_row, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(month_saving(2026, 3, 100)),
    update_saving(2026, 3, 30),
    sv_count_month_saving(2026, 3, N),
    N =:= 1.
 
test(only_changes_that_month, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(month_saving(2026, 3, 100)),
    sv_add(month_saving(2026, 4, 200)),
    update_saving(2026, 3, 30),
    month_saving(2026, 4, T),
    T =:= 200.
 
test(month_not_saved_fails, [fail, setup(sv_with_data), cleanup(sv_restore)]) :-
    update_saving(2026, 3, 30).
 
test(month_not_saved_changes_nothing, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(month_saving(2026, 4, 200)),
    \+ update_saving(2026, 3, 30),
    sv_count_all_month_saving(N),
    N =:= 1,
    month_saving(2026, 4, 200).
 
:- end_tests(update_saving).
 
%--------------------------------------------------------------------------
% operation_savings/5 : ahorro de un mes menos el de otro
% (year, last_year, month, last_month, rest)
%--------------------------------------------------------------------------
:- begin_tests(operation_savings).
 
test(same_saving_is_zero, [setup(sv_with_data), cleanup(sv_restore)]) :-
    operation_savings(2026, 2026, 4, 3, R),
    R =:= 0.
 
test(more_than_the_last_month_is_positive, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(incomes(2026, 4, 2, "Extra", 50, ingreso_extra)),
    operation_savings(2026, 2026, 4, 3, R),
    R =:= 50.
 
test(less_than_the_last_month_is_negative, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(expenses(2026, 4, 9, "Gasto", 30, deseo, "x")),
    operation_savings(2026, 2026, 4, 3, R),
    R =:= -30.
 
test(adjustments_count, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(savings_adjustments(2026, 4, 5, 20)),
    operation_savings(2026, 2026, 4, 3, R),
    R =:= 20.
 
test(january_against_december, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(incomes(2026, 12, 1, "Salario", 80, salario)),
    sv_add(incomes(2027, 1, 1, "Salario", 100, salario)),
    operation_savings(2027, 2026, 1, 12, R),
    R =:= 20.
 
:- end_tests(operation_savings).
 
%--------------------------------------------------------------------------
% porcentaje_ahorro/3 : que porcentaje de los ingresos se ahorro
%--------------------------------------------------------------------------
:- begin_tests(porcentaje_ahorro).
 
test(a_third_saved, [setup(sv_with_data), cleanup(sv_restore)]) :-
    porcentaje_ahorro(2026, 3, P),
    sv_close(P, 100 / 150 * 100).
 
test(without_income_is_zero, [setup(sv_with_data), cleanup(sv_restore)]) :-
    porcentaje_ahorro(2026, 9, P),
    P =:= 0.
 
test(everything_saved_is_100, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(incomes(2026, 5, 1, "Salario", 200, salario)),
    porcentaje_ahorro(2026, 5, P),
    sv_close(P, 100).
 
test(can_be_negative, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(expenses(2026, 3, 9, "Gasto grande", 250, necesidad, "x")),
    porcentaje_ahorro(2026, 3, P),
    P < 0.
 
test(adjustments_count, [setup(sv_with_data), cleanup(sv_restore)]) :-
    sv_add(savings_adjustments(2026, 3, 5, 50)),
    porcentaje_ahorro(2026, 3, P),
    sv_close(P, 100).
 
:- end_tests(porcentaje_ahorro).
 
%--------------------------------------------------------------------------
% Detector de basura: si algun test dejo los datos cambiados, falla.
%--------------------------------------------------------------------------
:- begin_tests(savings_cleanup).
 
test(sample_data_is_back, [nondet]) :-
    incomes(2026, 3, 2, "Salario", 1000, salario),
    month_saving(2026, 3, 100),
    \+ incomes(2026, 4, 1, _, _, _),
    \+ savings_adjustments(2026, 4, _, _).
 
:- end_tests(savings_cleanup).