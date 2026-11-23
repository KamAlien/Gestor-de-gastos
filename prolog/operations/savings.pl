%=======================================================================================================================================================
% OPERACIONES DE AHORROS
%=======================================================================================================================================================
:- ensure_loaded('../datos').
:- ensure_loaded(income).
:- ensure_loaded(expenses).
:- ensure_loaded('auxiliary methods/compare_with_lastmonth').

%======================================================================================================================================================
% TOTAL AHORRADO
%======================================================================================================================================================

total_month_saving(Year, Month, Total):-
    total_gastos(Year, Month, Expenses),
    total_ingresos(Year, Month, Incomes),
    findall(S, savings_adjustments(Year, Month, _, S), List_changes),
    sum_list(List_changes, Change),
    Total is Incomes - Expenses + Change.

%======================================================================================================================================================
% DINERO AHORRADO CON RESPECTO AL MES ANTERIOR
%======================================================================================================================================================

operation_savings(Year, Last_year, Month,Last_month, Rest):-
    total_month_saving(Year, Month, Current_rest),
    total_month_saving(Last_year, Last_month, Last_rest),
    Rest is Current_rest - Last_rest.


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


compare_savings(Year, Month, Rest, Message):-
    compare_savings_with_lastmonth(Year, Month, Rest, Message).


%=======================================================================================================================================================
% PORCENTAJE DE AHORRO
%=======================================================================================================================================================

porcentaje_ahorro(Year, Month, Porcentaje):-
    total_ingresos(Year, Month, Total),
    (Total =:= 0
    -> Porcentaje is 0.0
    ;
    total_month_saving(Year, Month, Rest),
    Porcentaje is (Rest / Total) * 100).