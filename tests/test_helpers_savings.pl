:- encoding(utf8).
%=========================================================================================
% AYUDAS PARA LAS PRUEBAS DE AHORROS (los nombres empiezan con sv_ para no chocar con helpers.pl)
% IMPORTANTE: assertz/retractall escritos DENTRO de una prueba crean predicados locales de la
% prueba y no tocan los datos reales; por eso todo lo que modifica hechos vive aqui, fuera.
%=========================================================================================
:- ensure_loaded('../prolog/datos').

sv_tables([savings_account/4, savings_account_percent/6, transfer_money/8,
           savings_adjustments/4, expenses/7, incomes/6]).

% copia de seguridad / restauracion de los datos reales
sv_backup :-
    sv_tables(Tables),
    forall(member(Name/Arity, Tables),
           ( functor(Head, Name, Arity),
             findall(Head, catch(Head, _, fail), Facts),
             nb_setval(Name, Facts) )).

sv_restore :-
    sv_tables(Tables),
    forall(member(Name/Arity, Tables),
           ( functor(Head, Name, Arity),
             retractall(Head),
             nb_getval(Name, Facts),
             forall(member(F, Facts), assertz(F)) )).

sv_clear :-
    sv_tables(Tables),
    forall(member(Name/Arity, Tables),
           ( functor(Head, Name, Arity), retractall(Head) )).

sv_add_income(Year, Month, Amount)  :- assertz(incomes(Year, Month, 1, "ingreso", Amount, salario)).
sv_add_expense(Year, Month, Amount) :- assertz(expenses(Year, Month, 1, "gasto", Amount, necesidad, "sub")).
sv_add_adjustment(Year, Month, Day, Amount) :- assertz(savings_adjustments(Year, Month, Day, Amount)).
sv_add_account(Category, Subcategory, Description, Percent) :-
    assertz(savings_account(Category, Subcategory, Description, Percent)).
sv_add_percent(Year, Month, Day, Category, Subcategory, Percent) :-
    assertz(savings_account_percent(Year, Month, Day, Category, Subcategory, Percent)).
sv_add_transfer(Y, M, D, CO, SO, CD, SD, Amount) :-
    assertz(transfer_money(Y, M, D, CO, SO, CD, SD, Amount)).

% Datos conocidos:
%   marzo: ingresos 1500, gastos 1200, ajuste +50  -> ahorro 350
%   abril: ingresos 1000, gastos 800               -> ahorro 200
%   mayo : gastos 150                              -> ahorro -150
%   cuentas: global 60 (70 desde 2026-3, 60 desde 2026-5), necesidad/"hospital" 30 (20 desde 2026-3,
%   30 desde 2026-5), deseo/"viajes" 10 (desde 2026-3)
sv_fixture :-
    sv_clear,
    sv_add_income(2026, 3, 1500), sv_add_expense(2026, 3, 1200), sv_add_adjustment(2026, 3, 5, 50),
    sv_add_income(2026, 4, 1000), sv_add_expense(2026, 4, 800),
    sv_add_expense(2026, 5, 150),
    sv_add_account(global, "Cuenta de Ahorro global", "global", 60),
    sv_add_account(necesidad, "hospital", "gastos medicos", 30),
    sv_add_account(deseo, "viajes", "vacaciones", 10),
    sv_add_percent(2026, 3, 1, global, "Cuenta de Ahorro global", 70),
    sv_add_percent(2026, 5, 1, global, "Cuenta de Ahorro global", 60),
    sv_add_percent(2026, 3, 1, necesidad, "hospital", 20),
    sv_add_percent(2026, 5, 1, necesidad, "hospital", 30),
    sv_add_percent(2026, 3, 1, deseo, "viajes", 10).

sv_percent_history(Category, Subcategory, List) :-
    findall(Y-M-D-P, savings_account_percent(Y, M, D, Category, Subcategory, P), List).
sv_count_accounts(Category, Subcategory, N) :-
    findall(x, savings_account(Category, Subcategory, _, _), L), length(L, N).
sv_account_percent(Category, Subcategory, P) :- savings_account(Category, Subcategory, _, P).
sv_count_adjustments(Y, M, D, A, N) :-
    findall(x, savings_adjustments(Y, M, D, A), L), length(L, N).
sv_count_transfers(N) :- findall(x, transfer_money(_, _, _, _, _, _, _, _), L), length(L, N).
