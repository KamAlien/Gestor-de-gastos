%===========================================================================
% VALIDAR QUE LAS OPERACIONES DE PONER INGRESOS, GASTOS O AJUSTAR AHORRO
%===========================================================================
%============================================================================
% VALIDACIONES
%============================================================================

% VALIDAR GENERAL
general_validation(Year, Month, Day, Description, Amount):-
    integer(Year),
    integer(Month),
    integer(Day),
    string(Description),
    integer(Amount),
    valid_day(Year, Month, Day),
    Amount >= 0,
    Description \== "".

% VALIDAR EL REGISTRO DE INGRESOS
valid_incomes(Year, Month, Day, Description, Amount, Category):-
    general_validation(Year, Month, Day, Description, Amount),
    income_type(Category).

% VALIDAR EL REGISTRO DE GASTOS
valid_expenses(Year, Month, Day, Description, Amount, Category, General_Description):-
    string(General_Description),
    General_Description \== "",
    general_validation(Year, Month, Day, Description, Amount),
    expenses_type(Category).

% VALIDAR UN CAMBIO EN EL AHORRO.
valid_changes_saving(Year, Month, Day, Amount):-
    number(Amount),
    valid_day(Year, Month, Day).