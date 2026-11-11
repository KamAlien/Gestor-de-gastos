%===========================================================================================================================
% OPERACIONES DE GASTOS
%===========================================================================================================================
:- ensure_loaded('../datos').
:- ensure_loaded(income).
:- ensure_loaded('auxiliary methods/compare_with_lastmonth').
:- ensure_loaded('auxiliary methods/historial').

% Conector
expenses_amount(Year, Month, Day, Description, Amount, Category):- 
    expenses(Year, Month, Day, Description, Amount, Category, _).
%TOTAL DE GASTO POR CATEGORIA
total_gasto_por_categoria(Categoria, Year, Month, Total):-
    findall(Monto, expenses_amount(Year, Month, _, _, Monto, Categoria), Lista),
    sum_list(Lista, Total).

% TOTAL DE GASTOS
total_gastos(Year, Month, Total):-
findall(Monto, expenses_amount(Year, Month, _, _, Monto, _), Lista),
sum_list(Lista, Total).

% COMPARACION CON EL MES PASADO
compare_expenses(Year, Month, Rest, Message):-
    compare_with_lastmonth(expenses_amount, expenses_amount, Year, Month, Rest, Message).

% PORCENTAJE DE GASTO POR CATEGORIA
porcentaje_gasto_por_categoria(Category, Year, Month, Porcentaje):-
    total_ingresos(Year, Month, Total),
    Total > 0,
    total_gasto_por_categoria(Category, Year, Month, Gasto),
    Porcentaje is (Gasto / Total) * 100.

% PORCENTAJE DE GASTO TOTAL
porcentaje_gasto_total(Year, Month, Porcentaje):-
    total_ingresos(Year, Month, Total),
    Total > 0,
    total_gastos(Year, Month, Gastos),
    Porcentaje is (Gastos / Total) * 100.

% REGISTRO MENSUAL POR CATEGORIA
% Datos de entrada: Year, Month, Category,
historial_days_by_category(Year, Month, Category, Message):-
    months_or_days_with_data(Year, Month, Category, expenses_amount,Sorteddays),
    format(string(Message), "Historial de gastos por categoria ~w: ~w", [Category, Sorteddays]).

% REGISTRO MENSUAL COMPLETO
historial_days_with_data(Year, Month, Message):-
    months_or_days_with_data(Year, Month, _, expenses_amount,Sorteddays),
    format(string(Message), "Historial de gastos: ~w", [Sorteddays]).
    
% REGISTRO ANUAL DE GASTOS POR CATEGORIA
historial_expenses_by_category(Year, Category, Message):-
    months_or_days_with_data(Year, _, Category, expenses_amount,SortedMonths),
    format(string(Message), "Historial de gastos por categoria ~w: ~w", [Category, SortedMonths]).

% REGISTRO ANUAL DE GASTOS TOTALES
historial_expenses(Year, Message):-
    months_or_days_with_data(Year, _, _, expenses_amount,SortedList),
    format(string(Message), "Historial de gastos totales: ~w", [SortedList]).