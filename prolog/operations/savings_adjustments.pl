%==================================================================================================================================
% CONSULTAS DE CAMBIO DE AHORRO
%===================================================================================================================================
:- ensure_loaded('../datos').
:- ensure_loaded('auxiliary methods/historial').
:- ensure_loaded('savings').


%====================================================================================================================================
% CREAR UN NUEVO CAMBIO
%====================================================================================================================================
change_saving(Year, Month, Day, Amount):-
    update_saving(Year, Month, Amount),
    assert(savings_adjustments(Year, Month, Day, Amount)).

%====================================================================================================================================
% ELIMINAR UN CAMBIO
%====================================================================================================================================
delete_savings_adjustments(Year, Month, Day, Amount):-
    retract(savings_adjustments(Year, Month, Day, Amount)),
    Amount_Change is Amount * (-1),
    update_saving(Year, Month, Amount_Change).

%====================================================================================================================================
% HISTORIALES
%====================================================================================================================================

% REGISTRO ANUAL
historial_month(Year, Message):-
    months_or_days_with_data_savings(Year, _, SortedMonths),
    format(string(Message), "Los cambios son: ~w", [SortedMonths]).

% REGISTRO MENSUAL
historial_savings_adj_data(Year, Month, Message):-
    months_or_days_with_data_savings(Year, Month, Sorteddays),
    format(string(Message), "Historial de cambios en los ahorros: ~w", [Sorteddays]).
