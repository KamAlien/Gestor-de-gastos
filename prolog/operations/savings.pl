%===========================================================================================================================
% OPERACIONES DE AHORROS
%===========================================================================================================================
:- ensure_loaded('../datos').
:- ensure_loaded(income).
:- ensure_loaded(expenses).
:- ensure_loaded('auxiliary methods/compare_with_lastmonth').


% TOTAL DE AHORRO
dinero_restante(Year, Month, Total):-
    total_gastos(Year, Month, Expenses),
    total_ingresos(Year, Month, Incomes),
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