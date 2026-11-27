%=========================================================================================================================================================================================================================================================================
% VALIDATE CATEGORIES: CREATE, UPDATE, AND DELETE
%=========================================================================================================================================================================================================================================================================
:- encoding(utf8).
:- ensure_loaded('operations/category').
:- ensure_loaded('../operations/auxiliary methods/list_auxiliaries_methods').


%=========================================================================================================================================================================================================================================================================
% CREATE, UPDATE, DELETE CATEGORIES
%=========================================================================================================================================================================================================================================================================
valid_create_category(Category, Description):-
    valid_arguments(Category, Description),
    category_not_exist(Category).

valid_update_category(Old_Category, New_Category, New_Description):-
    valid_arguments(New_Category, New_Description),
    category_exist(Old_Category),
    categories(Old_Category, Old_Description, _),
    valid_update_arguments(Old_Category, New_Category, Old_Description, New_Description),
    valid_new_name(Old_Category, New_Category).

valid_new_name(Same, Same):- !.
valid_new_name(_, New_Category):-
    category_not_exist(New_Category).

valid_delete_category(Category):-
    category_exist(Category),
    categories(Category, _, Percent),
    Percent =:= 0,
    category_unused(Category).

% CHANGE THE PERCENTAGE OF AT LEAST 2 CATEGORIES
valid_change_percent(List_changes):-
    length(List_changes, N),
    N >= 2,
    pairs_keys(List_changes, Names),
    is_set(Names),
    valid_list_changes(List_changes, Differences),
    sum_list(Differences, Change),
    findall(Percent, categories(_, _, Percent), Percents),
    sum_list(Percents, Current),
    Total is Current + Change,
    abs(Total - 100) < 1.0e-9.

valid_list_changes([], []).
valid_list_changes([Category-New_Percent | Rest], [Difference | Rest_Differences]):-
    atom(Category),
    categories(Category, _, Old_Percent),
    number(New_Percent),
    New_Percent >= 0,
    Difference is New_Percent - Old_Percent,
    valid_list_changes(Rest, Rest_Differences).


% Para validar la cantidad maxima de las cosas lo que se me ocurre es hacer un diccionario en donde sea Description : Cantidad
% El usuario agrega esto al diccionario cada vez que el ponga una categoria se busca en el diccionario si esta se le resta uno al valor
% Si no esta no pasa nada, si el elimina una ocurrencia de este en el mes se le suma uno a la instancia.

% Para la descripcion automatica podemos hacer una especie de KMP  o no se la verdad no se me ocurre dado un texto cualquiera deducir 
% que quizo decir el usuario 