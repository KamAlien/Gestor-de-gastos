%=================================================================================================================================================
% TESTS DE LAS OPERACIONES DE LAS CUENTAS DE AHORRO (prolog/operations/savings_account.pl)
% Incluye: totales hasta un mes, exist/2, saving_count_money/5, create_saving_account/7,
%          update_global_account/3, update_history_percent/5 y update_savings_account/9.
% Correr desde la carpeta del proyecto:
%   swipl -g run_tests -t halt tests/prolog/operations/test_savings_account.pl
%
% Cada test que usa datos empieza con esto (y al terminar se restauran los datos que habia):
%   Ingresos: marzo 150 y abril 150      Gastos: marzo 50 y abril 50      Ajustes: ninguno   -> se ahorran 100 cada mes
%   hospital: 20% desde marzo y 30% desde abril     viajes: 10% desde marzo
%   global:   70% desde marzo y 60% desde abril
%   Cuentas guardadas: global 60, hospital 30, viajes 10 (suman 100)
%=================================================================================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../prolog/operations/savings_account').
 
%--------------------------------------------------------------------------
% Ayudas (prefijo sc_)
%--------------------------------------------------------------------------
sc_save :-
    findall(incomes(Y, M, D, De, A, T), incomes(Y, M, D, De, A, T), Incomes),
    findall(expenses(Y, M, D, De, A, C, S), expenses(Y, M, D, De, A, C, S), Expenses),
    findall(savings_adjustments(Y, M, D, A), savings_adjustments(Y, M, D, A), Adjustments),
    findall(savings_account(C, S, De, P), savings_account(C, S, De, P), Accounts),
    findall(savings_account_percent(Y, M, D, C, S, P), savings_account_percent(Y, M, D, C, S, P), Percents),
    nb_setval(sc_saved, [Incomes, Expenses, Adjustments, Accounts, Percents]),
    sc_clear.
 
sc_clear :-
    retractall(incomes(_, _, _, _, _, _)),
    retractall(expenses(_, _, _, _, _, _, _)),
    retractall(savings_adjustments(_, _, _, _)),
    retractall(savings_account(_, _, _, _)),
    retractall(savings_account_percent(_, _, _, _, _, _)).
 
sc_restore :-
    sc_clear,
    nb_getval(sc_saved, Saved),
    forall(( member(Group, Saved), member(Fact, Group) ), assertz(Fact)).
 
sc_with_data :-
    sc_save,
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
 
% Los tests no pueden hacer assertz/retractall directo (irian al modulo del test): se hace desde aqui.
sc_add(Fact) :- assertz(Fact).
 
sc_count_percents(N) :-
    findall(x, savings_account_percent(_, _, _, _, _, _), L),
    length(L, N).
 
sc_count_percents_of(Category, Subcategory, N) :-
    findall(x, savings_account_percent(_, _, _, Category, Subcategory, _), L),
    length(L, N).
 
sc_count_accounts(N) :-
    findall(x, savings_account(_, _, _, _), L),
    length(L, N).
 
sc_close(A, B) :- abs(A - B) < 1.0e-9.
 
% Suma de los saldos de todas las cuentas (la global tambien) hasta un mes
sc_all_balances(Year, Month, Total) :-
    findall(B,
            (   savings_account(C, S, _, _),
                savings_account_balance(C, S, Year, Month, B)
            ),
            Balances),
    sum_list(Balances, Total).
 
% Suma de los porcentajes guardados de todas las cuentas
sc_percents_sum(Total) :-
    findall(P, savings_account(_, _, _, P), Ps),
    sum_list(Ps, Total).
 
%--------------------------------------------------------------------------
% total_up_to/4 y adjustments_up_to/3
%--------------------------------------------------------------------------
:- begin_tests(totals_up_to).
 
test(incomes_up_to_march, [setup(sc_with_data), cleanup(sc_restore)]) :-
    total_up_to(incomes, 2026, 3, T),
    T =:= 150.
 
test(incomes_up_to_april, [setup(sc_with_data), cleanup(sc_restore)]) :-
    total_up_to(incomes, 2026, 4, T),
    T =:= 300.
 
test(incomes_before_everything_is_zero, [setup(sc_with_data), cleanup(sc_restore)]) :-
    total_up_to(incomes, 2026, 2, T),
    T =:= 0.
 
test(includes_earlier_years, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_add(incomes(2025, 12, 1, "Salario", 40, salario)),
    total_up_to(incomes, 2026, 3, T),
    T =:= 190.
 
test(does_not_include_later_years, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_add(incomes(2027, 1, 1, "Salario", 40, salario)),
    total_up_to(incomes, 2026, 4, T),
    T =:= 300.
 
test(works_with_expenses, [setup(sc_with_data), cleanup(sc_restore)]) :-
    total_up_to(expenses_amount, 2026, 4, T),
    T =:= 100.
 
test(adjustments_up_to_a_month, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_add(savings_adjustments(2026, 3, 5, 50)),
    sc_add(savings_adjustments(2026, 4, 5, -20)),
    adjustments_up_to(2026, 3, A3),
    adjustments_up_to(2026, 4, A4),
    A3 =:= 50,
    A4 =:= 30.
 
test(no_adjustments_is_zero, [setup(sc_with_data), cleanup(sc_restore)]) :-
    adjustments_up_to(2026, 4, A),
    A =:= 0.
 
:- end_tests(totals_up_to).
 
%--------------------------------------------------------------------------
% exist/2 y saving_count_money/5
%--------------------------------------------------------------------------
:- begin_tests(exist).
 
test(normal_account_exists, [setup(sc_with_data), cleanup(sc_restore)]) :-
    exist(necesidad, "hospital").
 
test(global_account_exists, [setup(sc_with_data), cleanup(sc_restore)]) :-
    exist(global, "Cuenta de Ahorro global").
 
test(unknown_account_does_not_exist, [fail, setup(sc_with_data), cleanup(sc_restore)]) :-
    exist(necesidad, "nada").
 
test(same_name_other_category_does_not_exist, [fail, setup(sc_with_data), cleanup(sc_restore)]) :-
    exist(deseo, "hospital").
 
% Una cuenta repetida no cuenta como "existe una" (el invariante es: nombre unico)
test(duplicated_account_does_not_count, [fail, setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_add(savings_account(necesidad, "hospital", "Repetida", 5)),
    exist(necesidad, "hospital").
 
:- end_tests(exist).
 
:- begin_tests(saving_count_money).
 
test(gives_the_balance, [setup(sc_with_data), cleanup(sc_restore)]) :-
    saving_count_money(necesidad, "hospital", 2026, 4, B),
    B =:= 50.
 
test(gives_the_balance_of_the_global, [setup(sc_with_data), cleanup(sc_restore)]) :-
    saving_count_money(global, "Cuenta de Ahorro global", 2026, 4, B),
    B =:= 130.
 
test(unknown_account_fails, [fail, setup(sc_with_data), cleanup(sc_restore)]) :-
    saving_count_money(necesidad, "nada", 2026, 4, _).
 
test(before_the_account_starts_is_zero, [setup(sc_with_data), cleanup(sc_restore)]) :-
    saving_count_money(necesidad, "hospital", 2026, 2, B),
    B =:= 0.
 
:- end_tests(saving_count_money).
 
%--------------------------------------------------------------------------
% create_saving_account/7 (category, name, description, percent, year, month, day)
%--------------------------------------------------------------------------
:- begin_tests(create_saving_account).
 
test(saves_the_account, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    savings_account(deseo, "ropa", "Ropa", 5).
 
test(saves_the_first_percent_in_the_history, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    savings_account_percent(2026, 4, 2, deseo, "ropa", 5).
 
test(adds_one_account_and_one_history_row, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_count_accounts(A0),
    sc_count_percents(P0),
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    sc_count_accounts(A1),
    sc_count_percents(P1),
    A1 =:= A0 + 1,
    P1 =:= P0 + 1.
 
test(other_accounts_are_not_touched, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    savings_account(necesidad, "hospital", "Gastos medicos", 30),
    savings_account(deseo, "viajes", "Viajes", 10),
    savings_account(global, "Cuenta de Ahorro global", "Global", 60).
 
test(balance_starts_in_the_creation_month, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    savings_account_balance(deseo, "ropa", 2026, 3, March),
    savings_account_balance(deseo, "ropa", 2026, 4, April),
    March =:= 0,
    April =:= 5.
 
test(does_not_change_the_global, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    savings_account(global, "Cuenta de Ahorro global", _, G),
    G =:= 60,
    sc_count_percents_of(global, "Cuenta de Ahorro global", N),
    N =:= 2.
 
:- end_tests(create_saving_account).
 
%--------------------------------------------------------------------------
% update_global_account/3 : la global se queda con lo que sobra (100 - suma de las demas)
%--------------------------------------------------------------------------
:- begin_tests(update_global_account).
 
test(nothing_changes_if_it_already_adds_up, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_count_percents(P0),
    update_global_account(2026, 4, 2),
    sc_count_percents(P1),
    P1 =:= P0,
    savings_account(global, "Cuenta de Ahorro global", _, G),
    G =:= 60.
 
test(takes_what_is_left_after_a_new_account, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    update_global_account(2026, 4, 2),
    savings_account(global, "Cuenta de Ahorro global", _, G),
    G =:= 55.
 
test(adds_a_row_to_the_global_history, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    update_global_account(2026, 4, 2),
    savings_account_percent(2026, 4, 2, global, "Cuenta de Ahorro global", 55).
 
test(keeps_the_old_history, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    update_global_account(2026, 4, 2),
    savings_account_percent(2026, 3, 1, global, "Cuenta de Ahorro global", 70),
    savings_account_percent(2026, 4, 1, global, "Cuenta de Ahorro global", 60).
 
test(past_balance_of_the_global_does_not_change, [setup(sc_with_data), cleanup(sc_restore)]) :-
    savings_account_balance(global, "Cuenta de Ahorro global", 2026, 3, Before),
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    update_global_account(2026, 4, 2),
    savings_account_balance(global, "Cuenta de Ahorro global", 2026, 3, After),
    Before =:= After.
 
test(percents_add_up_to_100, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    update_global_account(2026, 4, 2),
    sc_percents_sum(Sum),
    Sum =:= 100.
 
test(balances_add_up_to_the_total_saving, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 1),
    update_global_account(2026, 4, 1),
    sc_all_balances(2026, 4, Sum),
    sc_close(Sum, 200).
 
test(calling_it_twice_is_the_same_as_once, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    update_global_account(2026, 4, 2),
    sc_count_percents(P1),
    update_global_account(2026, 4, 2),
    sc_count_percents(P2),
    P2 =:= P1.
 
test(can_leave_the_global_with_zero, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 60, 2026, 4, 2),
    update_global_account(2026, 4, 2),
    savings_account(global, "Cuenta de Ahorro global", _, G),
    G =:= 0.
 
test(works_with_decimals, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 12.5, 2026, 4, 2),
    update_global_account(2026, 4, 2),
    savings_account(global, "Cuenta de Ahorro global", _, G),
    sc_close(G, 47.5).
 
test(follows_a_lowered_percent, [setup(sc_with_data), cleanup(sc_restore)]) :-
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 10),
    update_global_account(2026, 5, 1),
    savings_account(global, "Cuenta de Ahorro global", _, G),
    G =:= 80.
 
test(there_is_still_only_one_global, [setup(sc_with_data), cleanup(sc_restore)]) :-
    create_saving_account(deseo, "ropa", "Ropa", 5, 2026, 4, 2),
    update_global_account(2026, 4, 2),
    findall(x, savings_account(global, _, _, _), L),
    length(L, 1).
 
:- end_tests(update_global_account).
 
%--------------------------------------------------------------------------
% update_history_percent/5 : pasa el historial de una cuenta a otro nombre
%--------------------------------------------------------------------------
:- begin_tests(update_history_percent).
 
test(empty_list_changes_nothing, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_count_percents(P0),
    update_history_percent([], necesidad, "hospital", necesidad, "salud"),
    sc_count_percents(P1),
    P1 =:= P0.
 
test(renames_every_row, [setup(sc_with_data), cleanup(sc_restore)]) :-
    update_history_percent([2026-3-1-20, 2026-4-1-30], necesidad, "hospital", necesidad, "salud"),
    savings_account_percent(2026, 3, 1, necesidad, "salud", 20),
    savings_account_percent(2026, 4, 1, necesidad, "salud", 30).
 
test(old_rows_disappear, [fail, setup(sc_with_data), cleanup(sc_restore)]) :-
    update_history_percent([2026-3-1-20, 2026-4-1-30], necesidad, "hospital", necesidad, "salud"),
    savings_account_percent(_, _, _, necesidad, "hospital", _).
 
test(can_change_the_category, [setup(sc_with_data), cleanup(sc_restore)]) :-
    update_history_percent([2026-3-1-20, 2026-4-1-30], necesidad, "hospital", deseo, "hospital"),
    savings_account_percent(2026, 3, 1, deseo, "hospital", 20),
    savings_account_percent(2026, 4, 1, deseo, "hospital", 30).
 
test(does_not_touch_other_accounts, [setup(sc_with_data), cleanup(sc_restore)]) :-
    update_history_percent([2026-3-1-20, 2026-4-1-30], necesidad, "hospital", necesidad, "salud"),
    savings_account_percent(2026, 3, 1, deseo, "viajes", 10),
    savings_account_percent(2026, 3, 1, global, "Cuenta de Ahorro global", 70).
 
test(keeps_the_number_of_rows, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_count_percents(P0),
    update_history_percent([2026-3-1-20, 2026-4-1-30], necesidad, "hospital", necesidad, "salud"),
    sc_count_percents(P1),
    P1 =:= P0.
 
:- end_tests(update_history_percent).
 
%--------------------------------------------------------------------------
% update_savings_account/9
% (year, month, day, old_category, old_name, new_category, new_name, new_description, new_percent)
%--------------------------------------------------------------------------
:- begin_tests(update_savings_account).
 
test(changes_the_description, [setup(sc_with_data), cleanup(sc_restore)]) :-
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "hospital", "Nueva descripcion", 30),
    savings_account(necesidad, "hospital", "Nueva descripcion", 30).
 
test(rename_removes_the_old_account, [fail, setup(sc_with_data), cleanup(sc_restore)]) :-
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "salud", "Salud", 30),
    savings_account(necesidad, "hospital", _, _).
 
test(rename_creates_the_new_account, [setup(sc_with_data), cleanup(sc_restore)]) :-
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "salud", "Salud", 30),
    savings_account(necesidad, "salud", "Salud", 30).
 
test(rename_keeps_the_number_of_accounts, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_count_accounts(A0),
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "salud", "Salud", 30),
    sc_count_accounts(A1),
    A1 =:= A0.
 
% El historial se va con la cuenta: el saldo con el nombre nuevo es el mismo
test(rename_keeps_the_balance, [setup(sc_with_data), cleanup(sc_restore)]) :-
    savings_account_balance(necesidad, "hospital", 2026, 4, Before),
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "salud", "Salud", 30),
    savings_account_balance(necesidad, "salud", 2026, 4, After),
    Before =:= After.
 
test(rename_does_not_add_a_history_row_if_the_percent_is_the_same, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_count_percents(P0),
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "salud", "Salud", 30),
    sc_count_percents(P1),
    P1 =:= P0.
 
test(new_percent_adds_a_history_row, [setup(sc_with_data), cleanup(sc_restore)]) :-
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 40),
    savings_account_percent(2026, 5, 1, necesidad, "hospital", 40).
 
test(new_percent_updates_the_account, [setup(sc_with_data), cleanup(sc_restore)]) :-
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 40),
    savings_account(necesidad, "hospital", _, 40).
 
test(new_percent_keeps_the_old_history, [setup(sc_with_data), cleanup(sc_restore)]) :-
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 40),
    savings_account_percent(2026, 3, 1, necesidad, "hospital", 20),
    savings_account_percent(2026, 4, 1, necesidad, "hospital", 30).
 
% Lo importante: cambiar el porcentaje no reescribe el pasado
test(new_percent_does_not_rewrite_the_past, [setup(sc_with_data), cleanup(sc_restore)]) :-
    savings_account_balance(necesidad, "hospital", 2026, 4, Before),
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 40),
    savings_account_balance(necesidad, "hospital", 2026, 4, After),
    Before =:= After.
 
test(new_percent_is_used_from_its_month, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_add(incomes(2026, 5, 1, "Salario", 150, salario)),
    sc_add(expenses(2026, 5, 2, "Super", 50, necesidad, "super")),
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 40),
    savings_account_balance(necesidad, "hospital", 2026, 5, May),
    May =:= 90.
 
test(same_percent_adds_no_history_row, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_count_percents(P0),
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "hospital", "Otra descripcion", 30),
    sc_count_percents(P1),
    P1 =:= P0.
 
% 30 y 30.0 son el mismo porcentaje: no deberia agregar una fila repetida.
% Falla mientras se compare con \== ; al cambiarlo por =\= se quita el "blocked" y debe pasar.
test(same_percent_as_decimal_adds_no_history_row,
     [blocked('cambiar \\== por =\\= en update_savings_account'), setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_count_percents(P0),
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 30.0),
    sc_count_percents(P1),
    P1 =:= P0.
 
test(change_category_keeps_the_balance, [setup(sc_with_data), cleanup(sc_restore)]) :-
    savings_account_balance(necesidad, "hospital", 2026, 4, Before),
    update_savings_account(2026, 5, 1, necesidad, "hospital", deseo, "hospital", "Gastos medicos", 30),
    savings_account_balance(deseo, "hospital", 2026, 4, After),
    Before =:= After.
 
test(other_accounts_are_not_touched, [setup(sc_with_data), cleanup(sc_restore)]) :-
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "salud", "Salud", 40),
    savings_account(deseo, "viajes", "Viajes", 10),
    savings_account(global, "Cuenta de Ahorro global", "Global", 60),
    savings_account_percent(2026, 3, 1, deseo, "viajes", 10),
    sc_count_percents_of(global, "Cuenta de Ahorro global", N),
    N =:= 2.
 
test(same_name_in_other_category_is_not_touched, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_add(savings_account(deseo, "hospital", "Hospital deseo", 5)),
    sc_add(savings_account_percent(2026, 3, 1, deseo, "hospital", 5)),
    update_savings_account(2026, 5, 1, necesidad, "hospital", necesidad, "salud", "Salud", 30),
    savings_account(deseo, "hospital", "Hospital deseo", 5),
    savings_account_percent(2026, 3, 1, deseo, "hospital", 5).
 
test(unknown_account_fails, [fail, setup(sc_with_data), cleanup(sc_restore)]) :-
    update_savings_account(2026, 5, 1, necesidad, "nada", necesidad, "nada", "Nada", 10).
 
test(unknown_account_changes_nothing, [setup(sc_with_data), cleanup(sc_restore)]) :-
    sc_count_accounts(A0),
    sc_count_percents(P0),
    \+ update_savings_account(2026, 5, 1, necesidad, "nada", necesidad, "nada", "Nada", 10),
    sc_count_accounts(A1),
    sc_count_percents(P1),
    A1 =:= A0,
    P1 =:= P0.
 
% El flujo completo: cambiar una cuenta y luego ajustar la global deja todo cuadrado
test(update_then_global_balances_add_up, [setup(sc_with_data), cleanup(sc_restore)]) :-
    update_savings_account(2026, 4, 2, necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 25),
    update_global_account(2026, 4, 2),
    sc_percents_sum(Sum),
    Sum =:= 100,
    sc_all_balances(2026, 4, Total),
    sc_close(Total, 200).
 
:- end_tests(update_savings_account).
 
%--------------------------------------------------------------------------
% Detector de basura: si algun test dejo los datos cambiados, falla.
%--------------------------------------------------------------------------
:- begin_tests(savings_account_cleanup).
 
test(sample_data_is_back, [nondet]) :-
    incomes(2026, 3, 2, "Salario", 1000, salario),
    savings_account_percent(2026, 3, 2, necesidad, "hospital", 20),
    \+ savings_account_percent(_, _, _, necesidad, "salud", _),
    \+ savings_account(deseo, "ropa", _, _),
    \+ incomes(2026, 4, 1, _, _, _).
 
:- end_tests(savings_account_cleanup).