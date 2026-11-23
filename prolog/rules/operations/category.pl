%=========================================================================================================================================================================================================================================================================
% AUXILIARY METHODS
%=========================================================================================================================================================================================================================================================================
:- ensure_loaded('../../datos').

valid_arguments(Category, Description):-
    atom(Category),
    Category \== '',
    string(Description),
    string_length(Description, N),
    N > 0.

valid_update_arguments(Old_Category, New_Category, _, _):-
    Old_Category \== New_Category, !.

valid_update_arguments(_, _, Old_Description, New_Description):-
    Old_Description \== New_Description.

category_exist(Category):-
    categories(Category, _, _), !.

category_not_exist(Category):-
    \+categories(Category, _, _).

category_unused(Category):-
    \+ expenses(_, _, _, _, _, Category, _).