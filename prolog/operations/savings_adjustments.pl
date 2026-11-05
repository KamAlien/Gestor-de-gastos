%======================================================================================================================
% CONSULTAS DE CAMBIO DE AHORRO
%======================================================================================================================
:- ensure_loaded('../datos').
:- ensure_loaded('auxiliary methods/historial').

% REGISTRO ANUAL
historial_month(Year, Message):-
    months_or_days_with_data_savings(Year, _, SortedMonths),
    format(string(Message), "Los cambios son: ~w", [SortedMonths]).

% REGISTRO MENSUAL
historial_savings_adj_data(Year, Month, Message):-
    months_or_days_with_data_savings(Year, Month, Sorteddays),
    format(string(Message), "Historial de cambios en los ahorros: ~w", [Sorteddays]).
