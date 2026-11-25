:- encoding(utf8).
%================================================================================================
% GUARDAR Y CARGAR DATOS (archivos de la carpeta datos)
%================================================================================================
:- ensure_loaded('../../datos').
:- ensure_loaded(persistence_common).

% GASTOS: archivo donde se guardan 
:- dynamic incomes_file/1.
incomes_file('data/incomes.pl').

% GUARDAR: escribe cada gasto que hay en memoria en el archivo 
save_incomes:-
    incomes_file(File),
    save_incomes(File).

save_incomes(File):-
    setup_and_call_cleanup(
        open(File, write, Stream, [encoding(utf8)]),
        forall(incomes(Year, Month, Day, Description, Amount, Category),
                portray_clause(Stream, incomes(Year, Month, Day, Description, Amount, Category))),
            close(Stream)).
    
% CARGAR: vacia la memoria y mete los gastos que estan en el archivo
load_incomes:-
    incomes_file(File),
    load_incomes(File).

load_incomes(File):-
    exists_file(File), !,
    setup_call_cleanup(
        open(File, read, Stream, [encoding(utf8)]),
        read_terms(Stream, Terms),
        close(Stream)),
    retractall(incomes(_, _, _, _, _, _)),
    forall( member(incomes(Year, Month, Day, Description, Amount, Category), Terms),
            assertz(incomes(Year, Month, Day, Description, Amount, Category))).
load_incomes(_).