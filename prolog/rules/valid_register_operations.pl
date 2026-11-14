%===========================================================================
% VALIDAR QUE LAS OPERACIONES DE PONER INGRESOS, GASTOS O AJUSTAR AHORRO
%===========================================================================

% TIPOS DE INGRESO PERMITIDOS
income_type(salario).
income_type(ingreso_extra).

% TIPOS DE GASTOS PERMITIDOS (CATEGORIAS)
expenses_type(necesidad).
expenses_type(deseo).


%===========================================================================
% FECHAS
%===========================================================================

% ANIO BISIESTO: divisible entre 4, pero los anios de siglo solo si lo son entre 400
leap_year(Year) :-
    Year mod 4 =:= 0,
    ( Year mod 100 =\= 0 ; Year mod 400 =:= 0 ).

% DIAS QUE TIENE UN MES: days_in_month(Anio, Mes, Dias)
days_in_month(_, 1, 31).
days_in_month(Year, 2, 29) :- leap_year(Year).
days_in_month(Year, 2, 28) :- \+ leap_year(Year).
days_in_month(_, 3, 31).
days_in_month(_, 4, 30).
days_in_month(_, 5, 31).
days_in_month(_, 6, 30).
days_in_month(_, 7, 31).
days_in_month(_, 8, 31).
days_in_month(_, 9, 30).
days_in_month(_, 10, 31).
days_in_month(_, 11, 30).
days_in_month(_, 12, 31).

% UN DIA ES VALIDO SI ESTA ENTRE 1 Y LOS DIAS QUE TIENE ESE MES
valid_day(Year, Month, Day) :-
    days_in_month(Year, Month, Days),
    between(1, Days, Day).


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