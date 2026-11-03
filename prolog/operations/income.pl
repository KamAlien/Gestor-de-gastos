%===========================================================================================================================
% OPERACIONES DE INGRESOS
%===========================================================================================================================
:- ensure_loaded('../datos').
:- ensure_loaded(auxiliary_methods).
% TOTAL DE INGRESO POR TIPO
total_ingreso_por_tipo(Tipo, Year, Month, Total):-
    findall(Monto, incomes(Year, Month, _, _, Monto, Tipo), Lista),
    sum_list(Lista, Total).

% TOTAL DE INGRESOS
total_ingresos(Year, Month, Total):-
    findall(Monto, incomes(Year, Month, _, _, Monto, _), Lista),
    sum_list(Lista, Total).

% COMPARACION CON EL MES PASADO
compare_income(Year, Month, Rest, Message):-
    compare_with_lastmonth(incomes, incomes, Year, Month, Rest, Message).
