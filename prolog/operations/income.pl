%===========================================================================================================================
% OPERACIONES DE INGRESOS
%===========================================================================================================================
:- ensure_loaded('../datos').
:- ensure_loaded('auxiliary methods/compare_with_lastmonth').
:- ensure_loaded('auxiliary methods/historial').

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

% REGISTRO ANUAL DE DATOS POR CATEGORIA
historial_incomes_by_category(Year, Category, Message):-
    months_or_days_with_data(Year, _, Category, incomes,SortedMonth),
    format(string(Message), "Historial de ingresos por categoria ~w: ~w", [Category, SortedMonth]).

% REGISTRO ANUAL DE DATOS TOTALES
historial_incomes(Year, Message):-
    months_or_days_with_data(Year, _, _,incomes, SortedMonth),
    format(string(Message), "Historial de ingresos totales: ~w", [SortedMonth]).

% REGISTRO MENSUAL POR CATEGORIA
% Datos de entrada: Year, Month, Category,
historial_income_days_by_category(Year, Month, Category, Message):-
    months_or_days_with_data(Year, Month, Category, incomes,Sorteddays),
    format(string(Message), "Historial de ingresos por categoria ~w: ~w", [Category, Sorteddays]).

% REGISTRO MENSUAL COMPLETO
historial_income_days_with_data(Year, Month, Message):-
    months_or_days_with_data(Year, Month, _, incomes, Sorteddays),
    format(string(Message), "Historial de ingresos: ~w", [Sorteddays]).