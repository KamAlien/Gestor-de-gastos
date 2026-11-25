:- encoding(utf8).
%======================================================================================================================
% GUARDAR Y CARGAR DATOS
%======================================================================================================================
:- ensure_loaded('../../datos').
:- ensure_loaded(persistence_common).

:- dynamic expenses_file/1.
expenses_file('data/expenses.pl').

save_expenses:-
    expenses_file(File),
    save_expenses(File).

save_expenses(File):-
    setup_and_call_cleanup(open(File, write, Stream, [encoding(utf8)]),
    forall(expenses(Year, Month, Day, Description, Amount, Category, General),
    portray_clause(Stream, expenses(Year, Month, Day, Description, Amount, Category, General))),
    close(Stream)).

load_expenses:-
    expenses_file(File),
    load_expenses(File).

load_expenses(File):-
    exists_file(File), !,
    setup_call_cleanup(
        open(File, read, Stream, [encoding(utf8)]),
        read_terms(Stream, Terms),
        close(Stream)),
    retractall(expenses(_, _, _, _, _, _, _)),
    forall(
        member(expenses(Year, Month, Day, Description, Amount, Category, General), Terms),
        assertz((expenses(Year, Month, Day, Description, Amount, Category, General)))
        ).
load_expenses(_).