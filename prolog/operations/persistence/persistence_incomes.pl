%================================================================================================
% GUARDAR Y CARGAR DATOS (archivos de la carpeta datos)
%================================================================================================

:- ensure_loaded('../../datos').

% GASTOS: archivo donde se guardan 
incomes_file('data/incomes.pl').

% GUARDAR: escribe cada gasto que hay en memoria en el archivo 
save_incomes:-
    incomes_file(File),
    open(File, write, Stream),
    forall(incomes(Year, Month, Day, Description, Amount, Category),
            portray_clause(Stream, incomes(Year, Month, Day, Description, Amount, Category))),
    close(Stream).

% CARGAR: vacia la memoria y mete los gastos que estan en el archivo
load_incomes:-
    incomes_file(File),
    retractall(incomes(_, _, _, _, _, _)),
    open(File, read, Stream),
    read_incomes(Stream),
    close(Stream).

% Lee el archivo hecho por hecho hasta llegar al final
read_incomes(Stream):-
    read(Stream, Term),
    (Term == end_of_file
    -> true
    ; assertz(Term),
    read_incomes(Stream)
    ).