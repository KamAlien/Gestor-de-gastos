:- encoding(utf8).
%=========================================================================================
% AYUDAS COMPARTIDAS POR TODOS LOS ARCHIVOS DE PRUEBAS
% Cada prueba arranca con los mismos datos y al final todo queda como estaba.
%=========================================================================================
:- ensure_loaded('../prolog/datos').
:- ensure_loaded('../prolog/operations/persistence/persistence_categories').

% fixture: datos conocidos que usan las pruebas
fx :-
    retractall(categories(_, _, _)),
    retractall(expenses(_, _, _, _, _, _, _)),
    assertz(categories(necesidad, "Gastos esenciales", 50)),
    assertz(categories(deseo,     "Gastos de ocio",    30)),
    assertz(categories(ahorro,    "Lo que se ahorra",  20)).

% copia de seguridad / restauracion de los datos reales de datos.pl
backup :-
    findall(categories(C, D, P), categories(C, D, P), Cats),
    findall(expenses(A, B, E, F, G, H, I), expenses(A, B, E, F, G, H, I), Exps),
    findall(F, categories_file(F), Files),
    nb_setval(backup_cats, Cats),
    nb_setval(backup_exps, Exps),
    nb_setval(backup_files, Files).

restore :-
    retractall(categories(_, _, _)),
    retractall(expenses(_, _, _, _, _, _, _)),
    nb_getval(backup_cats, Cats), forall(member(T, Cats), assertz(T)),
    nb_getval(backup_exps, Exps), forall(member(T, Exps), assertz(T)),
    retractall(categories_file(_)),
    nb_getval(backup_files, Files), forall(member(F, Files), assertz(categories_file(F))).

percents(Percents) :- findall(P, categories(_, _, P), Percents).

% IMPORTANTE: dentro de begin_tests/end_tests, un assertz o retractall escrito en el cuerpo de
% una prueba crea un predicado LOCAL de la prueba y no toca los datos reales. Por eso todo lo
% que modifica los hechos se hace con estas ayudas, que viven fuera de las pruebas.
clear_categories :- retractall(categories(_, _, _)).
add_category(Category, Description, Percent) :- assertz(categories(Category, Description, Percent)).
set_categories_file(File) :- retractall(categories_file(_)), assertz(categories_file(File)).
add_expense(Category) :- assertz(expenses(2026, 3, 3, "Gasto de prueba", 10, Category, "prueba")).
