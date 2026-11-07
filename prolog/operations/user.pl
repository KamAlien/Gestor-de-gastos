%=======================================================================================================================================
% OPERACIONES DEL USUARIO
%=======================================================================================================================================
:- ensure_loaded('../rules/valid_user').
:- ensure_loaded('../user_data').


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


% Solo puede haber a lo sumo un usuario
cant_user(N):-
    findall((Name, Age, Email), user(Name, Age, Email), List),
    length(List, N).

% Metodos auxiliares luego se borra esto es para debuguear
show_user(Message):-
    findall((Name, Age, Email), user( Name, Age, Email), List),
    format(string(Message),"~w", [List]).