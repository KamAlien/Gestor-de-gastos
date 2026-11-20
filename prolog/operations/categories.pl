:- encoding(utf8).
%=========================================================================================
% OPERACIONES SOBRE CATEGORIAS: aqui es donde se modifican los hechos (assert / retract)
% Patron: primero se VALIDA (rules/valid_category.pl), despues se modifica.
% Si la validacion falla, no se toca nada.
%=========================================================================================
:- ensure_loaded('../datos').
:- ensure_loaded('../rules/valid_category').

create_category(Category, Description):-
    valid_create_category(Category, Description),
    assertz(categories(Category, Description, 0)).

update_category(Old_Category, New_Category, New_Description):-
    valid_update_category(Old_Category, New_Category, New_Description),
    categories(Old_Category, _, Percent),
    retract(categories(Old_Category, _, _)),
    assertz(categories(New_Category, New_Description, Percent)).

delete_category(Category):-
    valid_delete_category(Category),
    retract(categories(Category, _, _)).

change_percents(List_changes):-
    valid_change_percent(List_changes),
    forall(member(Category-New_Percent, List_changes),
    set_percent(Category, New_Percent)).

set_percent(Category, New_Percent):-
    retract(categories(Category, Description, _)),
    assertz(categories(Category, Description, New_Percent)).