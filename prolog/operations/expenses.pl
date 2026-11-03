%===========================================================================================================================
% OPERACIONES DE GASTOS
%===========================================================================================================================
:- ensure_loaded('../datos').
:- ensure_loaded(income).
:- ensure_loaded(auxiliary_methods).

%TOTAL DE GASTO POR CATEGORIA
total_gasto_por_categoria(Categoria, Year, Month, Total):-
    findall(Monto, expenses(Year, Month, _, _, Monto, Categoria), Lista),
    sum_list(Lista, Total).

% TOTAL DE GASTOS
total_gastos(Year, Month, Total):-
findall(Monto, expenses(Year, Month, _, _, Monto, _), Lista),
sum_list(Lista, Total).

% COMPARACION CON EL MES PASADO
compare_expenses(Year, Month, Rest, Message):-
    compare_with_lastmonth(expenses, expenses, Year, Month, Rest, Message).

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

%  Si el ingreso es igual a 0 entonces debo compararlo con el dinero acumulado.