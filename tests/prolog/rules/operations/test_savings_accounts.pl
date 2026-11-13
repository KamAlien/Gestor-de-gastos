%=================================================================================================================================================
% TESTS DEL SALDO DE LAS CUENTAS DE AHORRO (prolog/operations/auxiliary methods/account_balance.pl)
% Correr desde la carpeta del proyecto:
%   swipl -g run_tests -t halt "tests/prolog/operations/auxiliary methods/test_account_balance.pl"
%
% Cada test que usa datos empieza con esto (y al terminar se restauran los datos que habia):
%   Ingresos: marzo 150 y abril 150      Gastos: marzo 50 y abril 50      Ajustes: ninguno   -> se ahorran 100 cada mes
%   hospital: 20% desde marzo y 30% desde abril     viajes: 10% desde marzo
%   global:   70% desde marzo y 60% desde abril     (la global tambien tiene filas, como las demas)
% A mano, para abril: hospital 20 + 30 = 50, viajes 10 + 10 = 20, global 70 + 60 = 130, total 200.
%=================================================================================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../../prolog/operations/auxiliary methods/account_balance').
 
%--------------------------------------------------------------------------
% Ayudas (prefijo ab_)
%--------------------------------------------------------------------------
ab_save :-
    findall(incomes(Y, M, D, De, A, T), incomes(Y, M, D, De, A, T), Incomes),
    findall(expenses(Y, M, D, De, A, C, S), expenses(Y, M, D, De, A, C, S), Expenses),
    findall(savings_adjustments(Y, M, D, A), savings_adjustments(Y, M, D, A), Adjustments),
    findall(savings_account(C, S, De, P), savings_account(C, S, De, P), Accounts),
    findall(savings_account_percent(Y, M, D, C, S, P), savings_account_percent(Y, M, D, C, S, P), Percents),
    nb_setval(ab_saved, [Incomes, Expenses, Adjustments, Accounts, Percents]),
    ab_clear.
 
ab_clear :-
    retractall(incomes(_, _, _, _, _, _)),
    retractall(expenses(_, _, _, _, _, _, _)),
    retractall(savings_adjustments(_, _, _, _)),
    retractall(savings_account(_, _, _, _)),
    retractall(savings_account_percent(_, _, _, _, _, _)).
 
ab_restore :-
    ab_clear,
    nb_getval(ab_saved, Saved),
    forall(( member(Group, Saved), member(Fact, Group) ), assertz(Fact)).
 
ab_with_data :-
    ab_save,
    assertz(incomes(2026, 3, 1, "Salario", 150, salario)),
    assertz(incomes(2026, 4, 1, "Salario", 150, salario)),
    assertz(expenses(2026, 3, 2, "Super", 50, necesidad, "super")),
    assertz(expenses(2026, 4, 2, "Super", 50, necesidad, "super")),
    assertz(savings_account(global, "Cuenta de Ahorro global", "Global", 60)),
    assertz(savings_account(necesidad, "hospital", "Gastos medicos", 30)),
    assertz(savings_account(deseo, "viajes", "Viajes", 10)),
    assertz(savings_account_percent(2026, 3, 1, global, "Cuenta de Ahorro global", 70)),
    assertz(savings_account_percent(2026, 4, 1, global, "Cuenta de Ahorro global", 60)),
    assertz(savings_account_percent(2026, 3, 1, necesidad, "hospital", 20)),
    assertz(savings_account_percent(2026, 4, 1, necesidad, "hospital", 30)),
    assertz(savings_account_percent(2026, 3, 1, deseo, "viajes", 10)).
 
% Sin ingresos ni gastos, solo con las cuentas
ab_only_accounts :-
    ab_save,
    assertz(savings_account(necesidad, "hospital", "Gastos medicos", 20)),
    assertz(savings_account_percent(2026, 3, 1, necesidad, "hospital", 20)).
 
% Los tests no pueden hacer assertz/retractall directo (irian al modulo del test): se hace desde aqui.
ab_add(Fact) :- assertz(Fact).
ab_remove_percents(Category, Subcategory) :- retractall(savings_account_percent(_, _, _, Category, Subcategory, _)).
 
% Solo la global, sin cuentas normales
ab_only_global :-
    ab_with_data,
    retractall(savings_account(necesidad, _, _, _)),
    retractall(savings_account(deseo, _, _, _)).
 
% Crea una cuenta con su primer porcentaje
ab_new_account(Category, Subcategory, Year, Month, Percent) :-
    assertz(savings_account(Category, Subcategory, "Descripcion", Percent)),
    assertz(savings_account_percent(Year, Month, 1, Category, Subcategory, Percent)).
 
ab_close(A, B) :- abs(A - B) < 1.0e-9.
 
ab_idx(Year, Month, Index) :- Index is Year * 12 + Month.
 
% Suma de los saldos de todas las cuentas (la global tambien) hasta un mes
ab_all_balances(Year, Month, Total) :-
    findall(B,
            (   savings_account(C, S, _, _),
                savings_account_balance(C, S, Year, Month, B)
            ),
            Balances),
    sum_list(Balances, Total).
 
% Lo que se ahorro en los meses de la lista (se pasan a mano, sin usar saving_between)
ab_saving_of(Months, Total) :-
    findall(S, ( member(Y-M, Months), total_month_saving(Y, M, S) ), Savings),
    sum_list(Savings, Total).
 
%--------------------------------------------------------------------------
% month_index/3
%--------------------------------------------------------------------------
:- begin_tests(month_index).
 
test(is_year_times_12_plus_month) :-
    month_index(2026, 3, I),
    I =:= 2026 * 12 + 3.
 
test(next_month_is_one_more) :-
    month_index(2026, 3, A),
    month_index(2026, 4, B),
    B =:= A + 1.
 
test(december_to_january_is_one_more) :-
    month_index(2026, 12, A),
    month_index(2027, 1, B),
    B =:= A + 1.
 
test(later_date_gives_bigger_number) :-
    month_index(2026, 12, A),
    month_index(2027, 1, B),
    A < B.
 
:- end_tests(month_index).
 
%--------------------------------------------------------------------------
% saving_between/3 : cuenta desde Start y NO cuenta End
%--------------------------------------------------------------------------
:- begin_tests(saving_between).
 
test(one_month_only_counts_the_start, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_idx(2026, 3, Start), ab_idx(2026, 4, End),
    saving_between(Start, End, S),
    S =:= 100.
 
test(two_months, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_idx(2026, 3, Start), ab_idx(2026, 5, End),
    saving_between(Start, End, S),
    S =:= 200.
 
test(same_start_and_end_is_zero, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_idx(2026, 3, I),
    saving_between(I, I, S),
    S =:= 0.
 
test(start_after_end_is_zero, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_idx(2026, 5, Start), ab_idx(2026, 3, End),
    saving_between(Start, End, S),
    S =:= 0.
 
test(months_without_data_are_zero, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_idx(2026, 6, Start), ab_idx(2026, 9, End),
    saving_between(Start, End, S),
    S =:= 0.
 
test(crosses_the_year, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(incomes(2026, 12, 1, "Salario", 80, salario)),
    ab_add(incomes(2027, 1, 1, "Salario", 20, salario)),
    ab_idx(2026, 12, Start), ab_idx(2027, 2, End),
    saving_between(Start, End, S),
    S =:= 100.
 
test(december_is_read_as_month_12, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(incomes(2026, 12, 1, "Salario", 80, salario)),
    ab_idx(2026, 12, Start), ab_idx(2027, 1, End),
    saving_between(Start, End, S),
    S =:= 80.
 
test(adjustments_count, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(savings_adjustments(2026, 3, 5, 50)),
    ab_idx(2026, 3, Start), ab_idx(2026, 4, End),
    saving_between(Start, End, S),
    S =:= 150.
 
test(negative_adjustment_lowers_it, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(savings_adjustments(2026, 3, 5, -30)),
    ab_idx(2026, 3, Start), ab_idx(2026, 4, End),
    saving_between(Start, End, S),
    S =:= 70.
 
test(negative_month_is_negative, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(expenses(2026, 3, 9, "Gasto grande", 300, necesidad, "x")),
    ab_idx(2026, 3, Start), ab_idx(2026, 4, End),
    saving_between(Start, End, S),
    S =:= -200.
 
:- end_tests(saving_between).
 
%--------------------------------------------------------------------------
% account_changes/5 : cambios de porcentaje hasta un mes, ordenados por mes
%--------------------------------------------------------------------------
:- begin_tests(account_changes).
 
test(all_changes_up_to_a_month_sorted, [setup(ab_with_data), cleanup(ab_restore)]) :-
    account_changes(necesidad, "hospital", 2026, 4, Changes),
    ab_idx(2026, 3, I3), ab_idx(2026, 4, I4),
    Changes == [I3-20, I4-30].
 
test(only_the_changes_up_to_the_month, [setup(ab_with_data), cleanup(ab_restore)]) :-
    account_changes(necesidad, "hospital", 2026, 3, Changes),
    ab_idx(2026, 3, I3),
    Changes == [I3-20].
 
test(a_later_month_includes_everything, [setup(ab_with_data), cleanup(ab_restore)]) :-
    account_changes(necesidad, "hospital", 2030, 1, Changes),
    length(Changes, N),
    N =:= 2.
 
test(before_the_first_change_is_empty, [setup(ab_with_data), cleanup(ab_restore)]) :-
    account_changes(necesidad, "hospital", 2026, 2, Changes),
    Changes == [].
 
test(unknown_account_is_empty, [setup(ab_with_data), cleanup(ab_restore)]) :-
    account_changes(necesidad, "nada", 2026, 4, Changes),
    Changes == [].
 
test(other_accounts_are_not_mixed, [setup(ab_with_data), cleanup(ab_restore)]) :-
    account_changes(deseo, "viajes", 2026, 4, Changes),
    ab_idx(2026, 3, I3),
    Changes == [I3-10].
 
test(same_name_other_category_is_not_mixed, [setup(ab_with_data), cleanup(ab_restore)]) :-
    account_changes(deseo, "hospital", 2026, 4, Changes),
    Changes == [].
 
test(global_has_its_own_changes, [setup(ab_with_data), cleanup(ab_restore)]) :-
    account_changes(global, "Cuenta de Ahorro global", 2026, 4, Changes),
    ab_idx(2026, 3, I3), ab_idx(2026, 4, I4),
    Changes == [I3-70, I4-60].
 
% Aunque se guarden desordenados, salen ordenados por fecha
test(sorted_even_if_saved_in_other_order, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_remove_percents(necesidad, "hospital"),
    ab_add(savings_account_percent(2026, 4, 1, necesidad, "hospital", 30)),
    ab_add(savings_account_percent(2026, 3, 1, necesidad, "hospital", 20)),
    account_changes(necesidad, "hospital", 2026, 4, Changes),
    ab_idx(2026, 3, I3), ab_idx(2026, 4, I4),
    Changes == [I3-20, I4-30].
 
test(year_change_is_sorted_right, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(savings_account_percent(2027, 1, 1, necesidad, "hospital", 40)),
    ab_add(savings_account_percent(2026, 12, 1, necesidad, "hospital", 35)),
    account_changes(necesidad, "hospital", 2027, 1, Changes),
    ab_idx(2026, 3, I3), ab_idx(2026, 4, I4), ab_idx(2026, 12, I12), ab_idx(2027, 1, I1),
    Changes == [I3-20, I4-30, I12-35, I1-40].
 
:- end_tests(account_changes).
 
%--------------------------------------------------------------------------
% tramos_share/5 : lo que le toco a la cuenta en cada tramo
%--------------------------------------------------------------------------
:- begin_tests(tramos_share).
 
% Sin mas cambios: un solo tramo hasta End (sin contar End)
test(single_tramo, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_idx(2026, 3, Start), ab_idx(2026, 5, End),
    tramos_share([], Start, 20, End, Shares),
    Shares = [A],
    A =:= 40.
 
test(two_tramos_give_two_shares, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_idx(2026, 3, I3), ab_idx(2026, 4, I4), ab_idx(2026, 5, End),
    tramos_share([I4-30], I3, 20, End, Shares),
    Shares = [A, B],
    A =:= 20,
    B =:= 30.
 
test(three_tramos, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_idx(2026, 3, I3), ab_idx(2026, 4, I4), ab_idx(2026, 5, I5), ab_idx(2026, 6, End),
    tramos_share([I4-30, I5-50], I3, 20, End, Shares),
    Shares = [A, B, C],
    A =:= 20,
    B =:= 30,
    C =:= 0.
 
test(tramo_with_no_months_is_zero, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_idx(2026, 3, I3),
    tramos_share([], I3, 20, I3, Shares),
    Shares = [A],
    A =:= 0.
 
test(share_is_percent_of_the_saving, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_idx(2026, 3, I3), ab_idx(2026, 4, End),
    tramos_share([], I3, 50, End, Shares),
    Shares = [A],
    A =:= 50.
 
test(gives_a_list_not_a_number, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_idx(2026, 3, I3), ab_idx(2026, 4, End),
    tramos_share([], I3, 50, End, Shares),
    is_list(Shares).
 
:- end_tests(tramos_share).
 
%--------------------------------------------------------------------------
% savings_account_balance/5
%--------------------------------------------------------------------------
:- begin_tests(savings_account_balance).
 
test(first_month, [setup(ab_with_data), cleanup(ab_restore)]) :-
    savings_account_balance(necesidad, "hospital", 2026, 3, B),
    B =:= 20.
 
test(adds_each_month_with_its_own_percent, [setup(ab_with_data), cleanup(ab_restore)]) :-
    savings_account_balance(necesidad, "hospital", 2026, 4, B),
    B =:= 50.
 
test(other_account, [setup(ab_with_data), cleanup(ab_restore)]) :-
    savings_account_balance(deseo, "viajes", 2026, 4, B),
    B =:= 20.
 
test(before_the_account_exists_is_zero, [setup(ab_with_data), cleanup(ab_restore)]) :-
    savings_account_balance(necesidad, "hospital", 2026, 2, B),
    B =:= 0.
 
test(unknown_account_fails, [fail, setup(ab_with_data), cleanup(ab_restore)]) :-
    savings_account_balance(necesidad, "nada", 2026, 4, _).
 
test(same_name_other_category_fails, [fail, setup(ab_with_data), cleanup(ab_restore)]) :-
    savings_account_balance(deseo, "hospital", 2026, 4, _).
 
% Si no hay movimientos despues, el saldo se queda igual.
test(balance_stays_when_nothing_happens, [setup(ab_with_data), cleanup(ab_restore)]) :-
    savings_account_balance(necesidad, "hospital", 2026, 4, B1),
    savings_account_balance(necesidad, "hospital", 2027, 6, B2),
    B1 =:= B2.
 
% Lo importante: cambiar el porcentaje NO reescribe los meses ya pasados.
test(changing_percent_does_not_rewrite_the_past, [setup(ab_with_data), cleanup(ab_restore)]) :-
    savings_account_balance(necesidad, "hospital", 2026, 3, Before),
    ab_add(savings_account_percent(2026, 5, 1, necesidad, "hospital", 90)),
    savings_account_balance(necesidad, "hospital", 2026, 3, After),
    savings_account_balance(necesidad, "hospital", 2026, 4, April),
    Before =:= After,
    April =:= 50.
 
% Los cambios pueden estar guardados en cualquier orden: el saldo es el mismo.
test(order_of_the_changes_does_not_matter, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_remove_percents(necesidad, "hospital"),
    ab_add(savings_account_percent(2026, 4, 1, necesidad, "hospital", 30)),
    ab_add(savings_account_percent(2026, 3, 1, necesidad, "hospital", 20)),
    savings_account_balance(necesidad, "hospital", 2026, 4, B),
    B =:= 50.
 
test(new_percent_only_affects_from_its_month, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(incomes(2026, 5, 1, "Salario", 150, salario)),
    ab_add(expenses(2026, 5, 2, "Super", 50, necesidad, "super")),
    ab_add(savings_account_percent(2026, 5, 1, necesidad, "hospital", 10)),
    savings_account_balance(necesidad, "hospital", 2026, 5, B),
    B =:= 60.
 
test(account_created_later_only_gets_later_months, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_new_account(deseo, "ropa", 2026, 4, 5),
    savings_account_balance(deseo, "ropa", 2026, 4, B),
    B =:= 5.
 
test(zero_percent_gets_nothing, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_new_account(deseo, "nada", 2026, 3, 0),
    savings_account_balance(deseo, "nada", 2026, 4, B),
    B =:= 0.
 
test(decimal_percent, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_new_account(deseo, "extra", 2026, 3, 12.5),
    savings_account_balance(deseo, "extra", 2026, 3, B),
    ab_close(B, 12.5).
 
% Un mes en que se gasto mas de lo que se gano reparte numeros negativos.
test(negative_month_lowers_the_balance, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(expenses(2026, 4, 9, "Gasto grande", 200, necesidad, "x")),
    savings_account_balance(necesidad, "hospital", 2026, 4, B),
    ab_close(B, 20 + (-100 * 30 / 100)).
 
test(adjustments_are_shared_too, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(savings_adjustments(2026, 3, 5, 50)),
    savings_account_balance(necesidad, "hospital", 2026, 3, B),
    ab_close(B, 30).
 
test(percent_in_the_same_month_it_changes_uses_the_new_one, [setup(ab_with_data), cleanup(ab_restore)]) :-
    savings_account_balance(necesidad, "hospital", 2026, 4, B),
    B =:= 50.
 
% Con la cuenta global ahora con filas, se calcula igual que las demas
test(global_in_march, [setup(ab_with_data), cleanup(ab_restore)]) :-
    savings_account_balance(global, "Cuenta de Ahorro global", 2026, 3, B),
    B =:= 70.
 
test(global_in_april, [setup(ab_with_data), cleanup(ab_restore)]) :-
    savings_account_balance(global, "Cuenta de Ahorro global", 2026, 4, B),
    B =:= 130.
 
test(global_before_it_exists_is_zero, [setup(ab_with_data), cleanup(ab_restore)]) :-
    savings_account_balance(global, "Cuenta de Ahorro global", 2026, 2, B),
    B =:= 0.
 
% La cuenta debe tener historial de porcentajes: si no, el saldo falla.
test(account_without_history_fails, [fail, setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(savings_account(deseo, "sin_historial", "x", 5)),
    savings_account_balance(deseo, "sin_historial", 2026, 4, _).
 
:- end_tests(savings_account_balance).
 
%--------------------------------------------------------------------------
% sum_percent/1 : suma de las cuentas normales (la global NO cuenta)
%--------------------------------------------------------------------------
:- begin_tests(sum_percent).
 
test(without_the_global, [setup(ab_with_data), cleanup(ab_restore)]) :-
    sum_percent(T),
    T =:= 40.
 
test(adding_an_account_raises_it, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_new_account(deseo, "ropa", 2026, 4, 5),
    sum_percent(T),
    T =:= 45.
 
test(only_global_is_zero, [setup(ab_only_global), cleanup(ab_restore)]) :-
    sum_percent(T),
    T =:= 0.
 
test(no_accounts_is_zero, [setup(ab_save), cleanup(ab_restore)]) :-
    sum_percent(T),
    T =:= 0.
 
:- end_tests(sum_percent).
 
%--------------------------------------------------------------------------
% Invariante: la suma de los saldos de TODAS las cuentas (con la global) es lo que se ahorro en total
%--------------------------------------------------------------------------
:- begin_tests(accounts_add_up_to_total).
 
test(in_march, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_all_balances(2026, 3, Sum),
    ab_saving_of([2026-3], Total),
    ab_close(Sum, Total),
    ab_close(Total, 100).
 
test(in_april, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_all_balances(2026, 4, Sum),
    ab_saving_of([2026-3, 2026-4], Total),
    ab_close(Sum, Total),
    ab_close(Total, 200).
 
test(with_a_negative_month, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(expenses(2026, 4, 9, "Gasto grande", 200, necesidad, "x")),
    ab_all_balances(2026, 4, Sum),
    ab_saving_of([2026-3, 2026-4], Total),
    ab_close(Sum, Total),
    ab_close(Total, 0).
 
test(with_adjustments, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(savings_adjustments(2026, 3, 5, 50)),
    ab_add(savings_adjustments(2026, 4, 6, -20)),
    ab_all_balances(2026, 4, Sum),
    ab_saving_of([2026-3, 2026-4], Total),
    ab_close(Sum, Total),
    ab_close(Total, 230).
 
% Si se crea una cuenta, la global baja lo mismo (esto lo hace update_global_account)
test(with_an_account_created_later, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_new_account(deseo, "ropa", 2026, 4, 5),
    ab_add(savings_account_percent(2026, 4, 2, global, "Cuenta de Ahorro global", 55)),
    ab_all_balances(2026, 4, Sum),
    ab_saving_of([2026-3, 2026-4], Total),
    ab_close(Sum, Total).
 
test(after_changing_percents, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_add(incomes(2026, 5, 1, "Salario", 300, salario)),
    ab_add(savings_account_percent(2026, 5, 1, necesidad, "hospital", 50)),
    ab_add(savings_account_percent(2026, 5, 1, deseo, "viajes", 25)),
    ab_add(savings_account_percent(2026, 5, 1, global, "Cuenta de Ahorro global", 25)),
    ab_all_balances(2026, 5, Sum),
    ab_saving_of([2026-3, 2026-4, 2026-5], Total),
    ab_close(Sum, Total),
    ab_close(Total, 500).
 
test(in_a_distant_future_month, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_all_balances(2030, 12, Sum),
    ab_saving_of([2026-3, 2026-4], Total),
    ab_close(Sum, Total),
    ab_close(Total, 200).
 
% Si la global NO se ajusta cuando cambia otra cuenta, los saldos dejan de cuadrar
% (por eso hay que llamar a update_global_account despues de crear o actualizar una cuenta).
test(forgetting_the_global_breaks_it, [setup(ab_with_data), cleanup(ab_restore)]) :-
    ab_new_account(deseo, "ropa", 2026, 4, 5),
    ab_all_balances(2026, 4, Sum),
    ab_saving_of([2026-3, 2026-4], Total),
    \+ ab_close(Sum, Total).
 
:- end_tests(accounts_add_up_to_total).
 
%--------------------------------------------------------------------------
% Detector de basura: si algun test dejo los datos cambiados, falla.
%--------------------------------------------------------------------------
:- begin_tests(account_balance_cleanup).
 
test(sample_data_is_back, [nondet]) :-
    incomes(2026, 3, 2, "Salario", 1000, salario),
    savings_account_percent(2026, 3, 2, necesidad, "hospital", 20),
    savings_account(global, "Cuenta de Ahorro global", _, _),
    \+ incomes(2026, 4, 1, _, _, _),
    \+ savings_account_percent(2026, 4, _, _, _, _).
 
:- end_tests(account_balance_cleanup).