%=================================================================================================================================================
% TESTS DE LAS OPERACIONES DEL USUARIO (prolog/operations/user.pl)
% Correr desde la carpeta del proyecto:
%   swipl -g run_tests -t halt tests/operations/test_user.pl
% Cada test que toca la base de datos empieza y termina con ella vacia (setup / cleanup),
% asi un test no depende del resultado de otro.
%=================================================================================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../prolog/operations/user').

clean_users :- retractall(user(_, _, _)).
add_user(Name, Age, Email) :- assertz(user(Name, Age, Email)).
setup_with_user :- clean_users, add_user("Kam", 20, "k@x.com").

%--------------------------------------------------------------------------
% create_user/3 : registrar (solo si todavia no hay usuario)
%--------------------------------------------------------------------------
:- begin_tests(create_user).

test(creates_first_user, [setup(clean_users), cleanup(clean_users)]) :-
    create_user("Kam", 20, "k@x.com"),
    user("Kam", 20, "k@x.com").

test(rejects_second_user, [fail, setup(clean_users), cleanup(clean_users)]) :-
    create_user("Kam", 20, "k@x.com"),
    create_user("Otra", 22, "o@x.com").

test(second_user_not_stored, [setup(clean_users), cleanup(clean_users)]) :-
    create_user("Kam", 20, "k@x.com"),
    \+ create_user("Otra", 22, "o@x.com"),
    findall(N, user(N, _, _), Names),
    Names == ["Kam"].

test(invalid_data_not_stored, [setup(clean_users), cleanup(clean_users)]) :-
    \+ create_user("", 20, "k@x.com"),
    \+ user(_, _, _).

:- end_tests(create_user).

%--------------------------------------------------------------------------
% update_user/3 : cambiar datos (solo si ya hay usuario y los datos son validos)
%--------------------------------------------------------------------------
:- begin_tests(update_user).

test(fails_without_user, [fail, setup(clean_users), cleanup(clean_users)]) :-
    update_user("Kam", 21, "n@x.com").

test(updates_data, [setup(setup_with_user), cleanup(clean_users)]) :-
    update_user("Kam", 21, "nuevo@x.com"),
    user("Kam", 21, "nuevo@x.com").

test(keeps_single_user, [setup(setup_with_user), cleanup(clean_users)]) :-
    update_user("Kam", 21, "nuevo@x.com"),
    findall(x, user(_, _, _), List),
    length(List, 1).

test(invalid_update_changes_nothing, [setup(setup_with_user), cleanup(clean_users)]) :-
    \+ update_user("", 21, "x@x.com"),
    user("Kam", 20, "k@x.com").

:- end_tests(update_user).

%--------------------------------------------------------------------------
% show_user/1 : devuelve el usuario como texto
%--------------------------------------------------------------------------
:- begin_tests(show_user).

test(shows_name, [setup(setup_with_user), cleanup(clean_users)]) :-
    show_user(Message),
    once(sub_string(Message, _, _, _, "Kam")).

test(empty_when_no_user, [setup(clean_users)]) :-
    show_user(Message),
    Message == "[]".

:- end_tests(show_user).