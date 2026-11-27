:- encoding(utf8).
%=========================================================================================
% GUARDAR Y CARGAR CATEGORIAS
%=========================================================================================
:- ensure_loaded('../../datos').
:- ensure_loaded(persistence_common).

% dinamico para poder cambiarlo en las pruebas y no tocar el archivo real
:- dynamic categories_file/1.
categories_file('data/categories.pl').

% GUARDAR: escribe cada categoria que hay en memoria en el archivo.
% La version con File como argumento existe para poder probarla con un archivo temporal.
save_categories:-
    categories_file(File),
    save_categories(File).

save_categories(File):-
    ensure_parent_directory(File),
    setup_call_cleanup(
        open(File, write, Stream, [encoding(utf8)]),
        forall(categories(Category, Description, Percent),
               portray_clause(Stream, categories(Category, Description, Percent))),
        close(Stream)).               % se cierra siempre, aunque algo falle a la mitad

% CARGAR: primero LEE todo el archivo y solo despues reemplaza la memoria.
% Asi, si el archivo esta roto, no se pierden las categorias que ya estaban cargadas.
% Si el archivo no existe (primera ejecucion) no hace nada y quedan los datos por defecto.
load_categories:-
    categories_file(File),
    load_categories(File).

load_categories(File):-
    exists_file(File), !,
    setup_call_cleanup(
        open(File, read, Stream, [encoding(utf8)]),
        read_terms(Stream, Terms),
        close(Stream)),
    retractall(categories(_, _, _)),
    forall(member(categories(Category, Description, Percent), Terms),   % ignora lo que no sea categories/3
           assertz(categories(Category, Description, Percent))).
load_categories(_).
