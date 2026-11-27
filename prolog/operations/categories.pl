:- encoding(utf8).
%=========================================================================================
% OPERACIONES SOBRE CATEGORIAS: aqui es donde se modifican los hechos (assert / retract)
% Patron: primero se VALIDA (rules/valid_category.pl), despues se modifica.
% Si la validacion falla, no se toca nada.
%=========================================================================================
:- ensure_loaded('../datos').
:- ensure_loaded('../rules/valid_category').
:- ensure_loaded(classification).
:- ensure_loaded(expenses).
:- ensure_loaded('persistence/persistence_categories').
:- ensure_loaded('persistence/persistence_expenses').




create_category(Category, Description):-
    valid_create_category(Category, Description),
    assertz(categories(Category, Description, 0)),
    save_categories.

update_category(Old, New, New_Description):-
    ground(update(Old, New, New_Description)),
    once(valid_update_category(Old, New, New_Description)),
    once(categories(Old, _, Percent)),
    (Old \== New 
    -> rename_category_in_rules(Old, New),
        rename_category_in_expenses(Old, New)
        ; true),
    once(retract(categories(Old, _, _))),
    assertz(categories(New, New_Description, Percent)),
    save_categories,
    save_expenses.


delete_category(Category):-
    valid_delete_category(Category),
    once(retract(categories(Category, _, _))),
    save_categories.

change_percents(List_changes):-
    valid_change_percent(List_changes),
    forall(member(Category-New_Percent, List_changes),
    set_percent(Category, New_Percent)),
    save_categories.

set_percent(Category, New_Percent):-
    retract(categories(Category, Description, _)),
    assertz(categories(Category, Description, New_Percent)).
