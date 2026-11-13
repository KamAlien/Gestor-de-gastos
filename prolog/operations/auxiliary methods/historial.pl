%===========================================================================================================================
% REGISTO ANUAL DE DATOS
%===========================================================================================================================
:- ensure_loaded('../../datos').

months_or_days_with_data(Year, Month, Category, Table,SortedList):-
    findall((Month, D, DE, M), call(Table, Year, Month, D, DE, M, Category), List),
    sort(List, SortedList).

months_or_days_with_data_savings(Year, Month, SortedList):-
    findall((Month, D, M), savings_adjustments( Year, Month, D, M), List),
    sort(List, SortedList).
