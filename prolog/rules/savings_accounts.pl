%================================================================================================================================================
% SAVINGS ACCOUNTS' RULES
%================================================================================================================================================

:- ensure_loaded('../datos').
:- ensure_loaded('operations/savings_accounts').
:- ensure_loaded('../types/types_categories').
:- ensure_loaded('operations/date').
:- ensure_loaded('../operations/auxiliary methods/account_balance').


%================================================================================================================================================
% METHODS
%================================================================================================================================================

%================================================================================================================================================
% METODOS PARA CREAR, ACTUALIZAR, ELIMINAR UNA CUENTA DE AHORRO
%================================================================================================================================================

valid_create_savings_account(Category, Subcategory, Description, Percent):-
    arguments_rules(Category, Subcategory, Description, Percent),
    sum_savings_account_percent(Percent, _),
    get_saving_account(Category, Subcategory, Saving_Account),
    not_exist_sb(Saving_Account).

valid_update_savings_account(Old_Category, Old_Subcategory, New_Category, New_Subcategory, New_Description, New_Percent):-
    arguments_rules(New_Category, New_Subcategory, New_Description, New_Percent),
    get_saving_account(Old_Category, Old_Subcategory, Saving_Account),
    exist_sb(Saving_Account),
    Old_Category \== global,
    new_name_is_free(Old_Category, Old_Subcategory, New_Category, New_Subcategory),
    Saving_Account = [(_, _, Old_Percent)],
    diferent_is_valid(New_Percent, Old_Percent).

valid_delete_saving_account(Year, Month, Day, Category, Subcategory):-
    valid_day(Year, Month, Day),
    get_saving_account(Category, Subcategory, Saving_account),
    exist_sb(Saving_account),
    Category \== global,
    savings_account_balance(Category, Subcategory, Year, Month, Balance),
    abs(Balance) < 0.005.

%================================================================================================================================================
% REGLA PARA TRANSFERIR DINERO
%================================================================================================================================================
valid_transfer(Year, Month, Day, Category_Origin, Subcategory_Origin, Category_Destiny, Subcategory_Destiny, Amount):-
    number(Amount),
    Amount > 0,

    valid_day(Year, Month, Day),

    (Category_Origin, Subcategory_Origin )\== (Category_Destiny, Subcategory_Destiny),

    get_saving_account(Category_Origin, Subcategory_Origin, Saving_account_Origin),
    exist_sb(Saving_account_Origin),

    get_saving_account(Category_Destiny, Subcategory_Destiny, Saving_account_Destiny),
    exist_sb(Saving_account_Destiny),

    savings_account_balance(Category_Origin, Subcategory_Origin, Year, Month, Balance),
    Balance + 0.005 >= Amount.