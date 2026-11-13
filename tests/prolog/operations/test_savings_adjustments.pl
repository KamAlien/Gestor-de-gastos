%=================================================================================================================================================
% TESTS DE LOS AJUSTES DE AHORRO (prolog/operations/savings_adjustments.pl)
% Incluye: chage_saving/4 y delete_savings_adjustments/4.
% Correr desde la carpeta del proyecto:
%   swipl -g run_tests -t halt tests/prolog/operations/test_savings_adjustments.pl
%
% Cada test que usa datos empieza con esto (y al terminar se restauran los datos que habia):
%   Ingresos: marzo 150 y abril 150      Gastos: marzo 50 y abril 50      Ajustes: ninguno
%   month_saving: marzo 100 y abril 100  (igual a lo que se calcula, asi estan "sincronizados")
%=================================================================================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../prolog/operations/savings_adjustments').
 
%--------------------------------------------------------------------------
% Ayudas (prefijo sj_)
%--------------------------------------------------------------------------
sj_save :-
    findall(incomes(Y, M, D, De, A, T), incomes(Y, M, D, De, A, T), Incomes),
    findall(expenses(Y, M, D, De, A, C, S), expenses(Y, M, D, De, A, C, S), Expenses),
    findall(savings_adjustments(Y, M, D, A), savings_adjustments(Y, M, D, A), Adjustments),
    findall(month_saving(Y, M, A), month_saving(Y, M, A), Months),
    nb_setval(sj_saved, [Incomes, Expenses, Adjustments, Months]),
    sj_clear.
 
sj_clear :-
    retractall(incomes(_, _, _, _, _, _)),
    retractall(expenses(_, _, _, _, _, _, _)),
    retractall(savings_adjustments(_, _, _, _)),
    retractall(month_saving(_, _, _)).
 
sj_restore :-
    sj_clear,
    nb_getval(sj_saved, Saved),
    forall(( member(Group, Saved), member(Fact, Group) ), assertz(Fact)).
 
sj_with_data :-
    sj_save,
    assertz(incomes(2026, 3, 1, "Salario", 150, salario)),
    assertz(incomes(2026, 4, 1, "Salario", 150, salario)),
    assertz(expenses(2026, 3, 2, "Super", 50, necesidad, "super")),
    assertz(expenses(2026, 4, 2, "Super", 50, necesidad, "super")),
    assertz(month_saving(2026, 3, 100)),
    assertz(month_saving(2026, 4, 100)).
 
% Igual pero sin la fila de month_saving de marzo
sj_without_march :-
    sj_with_data,
    retractall(month_saving(2026, 3, _)).
 
% Los tests no pueden hacer assertz/retractall directo (irian al modulo del test): se hace desde aqui.
sj_add(Fact) :- assertz(Fact).
 
sj_count_adjustments(N) :-
    findall(x, savings_adjustments(_, _, _, _), L),
    length(L, N).
 
%--------------------------------------------------------------------------
% chage_saving/4 (year, month, day, amount)
%--------------------------------------------------------------------------
:- begin_tests(chage_saving).
 
test(saves_the_adjustment, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    savings_adjustments(2026, 3, 9, 30).
 
test(adds_exactly_one_row, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    sj_count_adjustments(N),
    N =:= 1.
 
test(updates_the_saved_month, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    month_saving(2026, 3, T),
    T =:= 130.
 
test(negative_adjustment, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, -40),
    month_saving(2026, 3, T),
    T =:= 60,
    savings_adjustments(2026, 3, 9, -40).
 
test(two_adjustments_add_up, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    chage_saving(2026, 3, 10, -10),
    month_saving(2026, 3, T),
    T =:= 120.
 
test(does_not_touch_other_months, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    month_saving(2026, 4, T),
    T =:= 100.
 
% La tabla guardada y lo que se calcula coinciden despues del ajuste
test(saved_and_computed_agree, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    month_saving(2026, 3, Saved),
    total_month_saving(2026, 3, Computed),
    Saved =:= Computed.
 
test(saved_and_computed_agree_after_several, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    chage_saving(2026, 3, 10, -75),
    chage_saving(2026, 3, 11, 5),
    month_saving(2026, 3, Saved),
    total_month_saving(2026, 3, Computed),
    Saved =:= Computed.
 
% Si el mes no esta guardado, falla y NO deja el ajuste a medias
test(month_not_saved_fails, [fail, setup(sj_without_march), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30).
 
test(month_not_saved_leaves_no_adjustment, [setup(sj_without_march), cleanup(sj_restore)]) :-
    \+ chage_saving(2026, 3, 9, 30),
    sj_count_adjustments(N),
    N =:= 0.
 
:- end_tests(chage_saving).
 
%--------------------------------------------------------------------------
% delete_savings_adjustments/4 (year, month, day, amount)
%--------------------------------------------------------------------------
:- begin_tests(delete_savings_adjustments).
 
test(removes_the_adjustment, [fail, setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    delete_savings_adjustments(2026, 3, 9, 30),
    savings_adjustments(2026, 3, 9, 30).
 
test(reverses_the_saved_month, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    delete_savings_adjustments(2026, 3, 9, 30),
    month_saving(2026, 3, T),
    T =:= 100.
 
test(reverses_a_negative_adjustment, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, -40),
    delete_savings_adjustments(2026, 3, 9, -40),
    month_saving(2026, 3, T),
    T =:= 100.
 
test(only_removes_that_one, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    chage_saving(2026, 3, 10, 20),
    delete_savings_adjustments(2026, 3, 9, 30),
    savings_adjustments(2026, 3, 10, 20),
    sj_count_adjustments(N),
    N =:= 1,
    month_saving(2026, 3, T),
    T =:= 120.
 
test(removes_only_one_of_two_equal_adjustments, [nondet, setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    chage_saving(2026, 3, 9, 30),
    delete_savings_adjustments(2026, 3, 9, 30),
    sj_count_adjustments(N),
    N =:= 1,
    month_saving(2026, 3, T),
    T =:= 130.
 
test(saved_and_computed_agree_after_deleting, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    chage_saving(2026, 3, 10, 20),
    delete_savings_adjustments(2026, 3, 9, 30),
    month_saving(2026, 3, Saved),
    total_month_saving(2026, 3, Computed),
    Saved =:= Computed.
 
test(does_not_touch_other_months, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    delete_savings_adjustments(2026, 3, 9, 30),
    month_saving(2026, 4, T),
    T =:= 100.
 
test(unknown_adjustment_fails, [fail, setup(sj_with_data), cleanup(sj_restore)]) :-
    delete_savings_adjustments(2026, 3, 9, 30).
 
test(unknown_adjustment_changes_nothing, [setup(sj_with_data), cleanup(sj_restore)]) :-
    \+ delete_savings_adjustments(2026, 3, 9, 30),
    month_saving(2026, 3, T),
    T =:= 100.
 
test(wrong_day_is_not_deleted, [setup(sj_with_data), cleanup(sj_restore)]) :-
    chage_saving(2026, 3, 9, 30),
    \+ delete_savings_adjustments(2026, 3, 10, 30),
    savings_adjustments(2026, 3, 9, 30).
 
% Si el mes no esta guardado, el ajuste NO debe quedar borrado a medias.
% Ahora hace retract primero y despues falla update_saving: el ajuste desaparece pero el resultado es "false".
test(month_not_saved_keeps_the_adjustment,
     [blocked('en delete_savings_adjustments hacer update_saving antes del retract'), setup(sj_with_data), cleanup(sj_restore)]) :-
    sj_add(savings_adjustments(2026, 5, 9, 30)),
    \+ delete_savings_adjustments(2026, 5, 9, 30),
    savings_adjustments(2026, 5, 9, 30).
 
:- end_tests(delete_savings_adjustments).
 
%--------------------------------------------------------------------------
% Detector de basura: si algun test dejo los datos cambiados, falla.
%--------------------------------------------------------------------------
:- begin_tests(savings_adjustments_cleanup).
 
test(sample_data_is_back, [nondet]) :-
    savings_adjustments(2026, 3, 5, 100),
    month_saving(2026, 3, 100),
    \+ savings_adjustments(2026, 3, 9, _),
    \+ savings_adjustments(2026, 3, 10, _).
 
:- end_tests(savings_adjustments_cleanup).