%================================================================================================================================================
% SAVINGS ACCOUNTS' RULES
%================================================================================================================================================

:- ensure_loaded('../datos').
:- ensure_loaded('operations/savings_accounts').
:- ensure_loaded('../types/categories').


%================================================================================================================================================
% METHODS
%================================================================================================================================================

% Reglas para crear una subcategoria
valid_create_savings_account(Category, Subcategory, Description, Percent):-
    arguments_rules(Category, Subcategory, Description, Percent),
    sum_savings_account_percent(Percent, _),
    get_saving_account(Category, Subcategory, Saving_Account),
    not_exist_sb(Saving_Account).


% Actualizar una cuenta de ahorro
valid_update_savings_account(Old_Category, Old_Subcategory, New_Category, New_Subcategory, New_Description, New_Percent):-
    arguments_rules(New_Category, New_Subcategory, New_Description, New_Percent),
    get_saving_account(Old_Category, Old_Subcategory, Saving_Account),
    exist_sb(Saving_Account),
    new_name_is_free(Old_Category, Old_Subcategory, New_Category, New_Subcategory),
    Saving_Account = [(_, _, Old_Percent)],
    diferent_is_valid(New_Percent, Old_Percent).