%================================================================================================
% GUARDAR Y CARGAR DATOS (archivos de la carpeta datos)
%================================================================================================

:- ensure_loaded('../../datos').

% GASTOS: archivo donde se guardan 
expenses_file('data/expenses.pl').

% GUARDAR: escribe cada gasto que hay en memoria en el archivo 
save_expenses:-
    expenses_file(File),
    open(File, write, Stream),
    forall(expenses(Year, Month, Day, Description, Amount, Category),
            portray_clause(Stream, expenses(Year, Month, Day, Description, Amount, Category))),
    close(Stream).

% CARGAR: vacia la memoria y mete los gastos que estan en el archivo
load_expenses:-
    expenses_file(File),
    retractall(expenses(_, _, _, _, _, _)),
    open(File, read, Stream),
    read_expenses(Stream),
    close(Stream).

% Lee el archivo hecho por hecho hasta llegar al final
read_expenses(Stream):-
    read(Stream, Term),
    (Term == end_of_file
    -> true
    ; assertz(Term),
    read_expenses(Stream)
    ).