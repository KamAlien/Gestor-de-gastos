%=====================================================================================================================================================
% VALIDAR LOS PORCENTAJES DE LAS CATEGORIAS
%=====================================================================================================================================================
:- ensure_loaded('operations/date').
:- ensure_loaded('../type/categories').
:- ensure_loaded('../operations/auxiliary methods/list_auxiliary_methods').

valid_change_percent(Year, Month, Day, List_changes):-
    valid_day(Year, Month, Day),
    length(List_changes, N),
    N >= 2,
    
    valid_list_changes(List_changes, List_Percent),
    sum_list(List_Percent, Total_Percent),
    Total_Percent =:= 100.


valid_list_changes(List_changes, List_Percent):-
    ( length(List_changes, N),
        N == 0
        ->
        ;
        pop(List_changes, Rest, Category-Percent),
        category_type(Category),
        number(Percent),
        Percent >= 0,,
        valid_list_changes(Rest, List_Percent)
    ).

% Para validar la cantidad maxima de las cosas lo que se me ocurre es hacer un diccionario en donde sea Description : Cantidad
% El usuario agrega esto al diccionario cada vez que el ponga una categoria se busca en el diccionario si esta se le resta uno al valor
% Si no esta no pasa nada, si el elimina una ocurrencia de este en el mes se le suma uno a la instancia.

% Para la descripcion automatica podemos hacer una especie de KMP  o no se la verdad no se me ocurre dado un texto cualquiera deducir 
% que quizo decir el usuario 
