%=======================================================================================================================================
% OPERACIONES DEL USUARIO
%=======================================================================================================================================
:- ensure_loaded('../user_data').
:- ensure_loaded('../datos').
:- ensure_loaded('../rules/valid_user').
:- ensure_loaded('../rules/valid_register_operations').


% Registrarse
create_user(Name, Age, Email):-
    valid_user(Name, Age, Email),
    cant_user(N),
    N == 0,
    assertz(user(Name, Age, Email)).

% ACTUALIZAR SUS DATOS
update_user( Name, Age, Email):-
    valid_user(Name, Age, Email),
    cant_user(N),
    N == 1,
    retract(user(_, _, _)),
    assertz(user(Name, Age, Email)).



% REGISTRAR SUS GASTOS E INGRESOS.
% REGISTRAR SUS INGRESOS.
register_incomes(Year, Month, Day, Description, Amount, Category):-
    valid_incomes(Year, Month, Day, Description, Amount, Category),
    assertz(incomes(Year, Month, Day, Description, Amount, Category)). 

% REGISTRAR SUS GASTOS
register_expenses(Year, Month, Day, Description, Amount, Category):-
    valid_expenses(Year, Month, Day, Description, Amount, Category),
    assertz(expenses(Year, Month, Day, Description, Amount, Category)).

% Solo puede haber a lo sumo un usuario
cant_user(N):-
    findall((Name, Age, Email), user(Name, Age, Email), List),
    length(List, N).

% Metodos auxiliares luego se borra esto es para debuguear
show_user(Message):-
    findall((Name, Age, Email), user( Name, Age, Email), List),
    format(string(Message),"~w", [List]).