%===========================================================================
% VALIDAR QUE LAS OPERACIONES DE PONER INGRESOS, GASTOS O AJUSTAR AHORRO
%===========================================================================
:- ensure_loaded('operations/date').
% TIPOS DE INGRESO PERMITIDOS
income_type(salario).
income_type(ingreso_extra).

% TIPOS DE GASTOS PERMITIDOS (CATEGORIAS)
expenses_type(necesidad).
expenses_type(deseo).

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
valid_expenses(Year, Month, Day, Description, Amount, Category):-
    general_validation(Year, Month, Day, Description, Amount),
    expenses_type(Category).