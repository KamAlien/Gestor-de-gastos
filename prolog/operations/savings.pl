%===========================================================================================================================
% OPERACIONES DE AHORROS
%===========================================================================================================================
:- ensure_loaded('../datos').
:- ensure_loaded(income).
:- ensure_loaded(auxiliary_methods).

% TOTAL DE AHORRO
%Caso 1: Si el mes es enero, se compara con diciembre del año anterior
%Caso 2: Si el mes es diferente a enero, se compara con el mes anterior
dinero_restante(Year, Month, Total):-
    findall(Monto, expenses(Year, Month, _, _, Monto, _), List_expenses),
    findall(Monto, incomes(Year, Month, _, _, Monto, _), List_incomes),

    sum_list(List_expenses, Expenses),
    sum_list(List_incomes, Incomes),
    Total is Incomes - Expenses.

% Metodo principal para comparar el ahorro con el mes anterior
compare_savings(Year, Month, Rest, Message):-
    compare_savings_with_lastmonth(Year, Month, Rest, Message).

% Operacion de ahorro
operation_savings(Year, Last_year, Month,Last_month, Rest):-
    dinero_restante(Year, Month, Current_rest),
    dinero_restante(Last_year, Last_month, Last_rest),
    Rest is Current_rest - Last_rest.

% LLamada por casos 
compare_savings_with_lastmonth(Year, 1, Rest, Message):-
    LastMonth = 12,
    LastYear is Year - 1,
    operation_savings(Year, LastYear, 1, LastMonth, Rest),
    compare_result(Rest, Message).

compare_savings_with_lastmonth(Year, Month, Rest, Message):-
    Month > 1,
    LastMonth is Month - 1,
    operation_savings(Year, Year, Month, LastMonth, Rest),
    compare_result(Rest, Message).

% Porcentaje de ahorro
porcentaje_ahorro(Year, Month, Porcentaje):-
    total_ingresos(Year, Month, Total),

    Total > 0,
    dinero_restante(Year, Month, Rest),
    Porcentaje is (Rest / Total) * 100.

% Porcentaje de ahorro 
porcentaje_ahorro_total(Year, Month, Porcentaje):-
    total_ingresos(Year, Month, Total),
    Total = 0,
    Porcentaje is 0.