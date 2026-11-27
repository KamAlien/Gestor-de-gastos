%=========================================================================================================================================================================================================================================================================
% AUXILIARY METHODS
%=========================================================================================================================================================================================================================================================================
:- ensure_loaded('../../datos').
:- ensure_loaded('../../confing/auto_classification').


valid_arguments(Category, Description):-
    atom(Category),
    Category \== '',
    Category \== pendiente,
    string(Description),
    string_length(Description, N),
    N > 0.

valid_update_arguments(Old_Category, New_Category, _, _):-
    Old_Category \== New_Category,
    New_Category \== pendiente, !.

valid_update_arguments(_, New_Category, Old_Description, New_Description):-
    Old_Description \== New_Description,
    New_Category \== pendiente, !.

category_exist(Category):-
    categories(Category, _, _), !.

category_not_exist(Category):-
    \+categories(Category, _, _).

category_unused(Category):-
    \+ expenses(_, _, _, _, _, Category, _),
    \+ context_exception(_, _, Category),
    \+ text_rule(_, Category),
    \+ general_description_category(_, Category).