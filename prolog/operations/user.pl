%===============================================================================================================================================================================
% OPERACIONES DEL USUARIO
%==============================================================================================================================================================================
:- ensure_loaded('../user_data').
:- ensure_loaded('../datos').
:- ensure_loaded('../rules/valid_user').
:- ensure_loaded('../rules/valid_register_operations').
:- ensure_loaded('../rules/savings_accounts').
:- ensure_loaded('savings_account').


%=============================================================================================================================================================================
% CREAR Y ACTUALIZAR UN USUARIO
%=============================================================================================================================================================================
create_user(Name, Age, Email):-
    valid_user(Name, Age, Email),
    cant_user(N),
    N == 0,
    assertz(user(Name, Age, Email)).

% ACTUALIZAR SUS DATOS
update_user( Name, Age, Email):-
    valid_user(Name, Age, Email),
    cant_user(N),
    N == 1,
    retract(user(_, _, _)),
    assertz(user(Name, Age, Email)).


%=============================================================================================================================================================================
% REGISTRAR SUS INGRESOS.
%=============================================================================================================================================================================
register_incomes(Year, Month, Day, Description, Amount, Category):-
    valid_incomes(Year, Month, Day, Description, Amount, Category),
    assertz(incomes(Year, Month, Day, Description, Amount, Category)). 


%=============================================================================================================================================================================
% REGISTRAR SUS GASTOS
%=============================================================================================================================================================================
register_expenses(Year, Month, Day, Description, Amount, Category):-
    valid_expenses(Year, Month, Day, Description, Amount, Category),
    assertz(expenses(Year, Month, Day, Description, Amount, Category)).

% Solo puede haber a lo sumo un usuario
cant_user(N):-
    findall((Name, Age, Email), user(Name, Age, Email), List),
    length(List, N).

% Metodos auxiliares luego se borra esto es para debuguear
show_user(Message):-
    findall((Name, Age, Email), user( Name, Age, Email), List),
    format(string(Message),"~w", [List]).


%==============================================================================================================================================================================
% CREAR CUENTAS DE AHORRO:
%==============================================================================================================================================================================
create_account(Year, Month, Day, Category, Subcategory, Description, Percent):-
    valid_create_savings_account(Category, Subcategory, Description, Percent),
    create_saving_account(Year, Month, Day, Category, Subcategory, Description, Percent),
    update_global_account(Year, Month, Day).


%==============================================================================================================================================================================
% ACTUALIZAR UNA CUENTA DE AHORRO 
%==============================================================================================================================================================================
update_account(Year, Month, Day, Old_Category, Old_Subcategory, New_Category, New_Subcategory, New_Percent):-
    valid_update_savings_account(Old_Category, Old_Subcategory, New_Category, New_Subcategory, New_Description, New_Percent),
    update_savings_account(Year, Month, Day, Old_Category, Old_Subcategory, New_Category, New_Subcategory, New_Description, New_Percent),
    update_global_account(Year, Month, Day).


%==============================================================================================================================================================================
% ELIMINAR UNA CUENTA DE AHORRO
%==============================================================================================================================================================================
delete_account(Category, Subcategory):-
    exist(Category, Subcategory),
    delete_savings_account(Category, Subcategory).


%==============================================================================================================================================================================
% CREAR UN CAMBIO EN EL AHORRO DE UN MES
%==============================================================================================================================================================================
create_change_saving(Year, Month, Day, Amount):-
    valid_changes_saving(Year, Month, Day, Amount),
    change_saving(Year, Month, Day, Amount).


%==============================================================================================================================================================================
% ELIMINAR UN CAMBIO EN EL AHORRO DE UN MES 
%==============================================================================================================================================================================
delete_adjustments(Year, Month, Day, Amount):-
    exist_adjustment(Year, Month, Day, Amount),
    delete_savings_adjustments(Year, Month, Day, Amount).

%==============================================================================================================================================================================
% PREGUNTAR CUANTO DINERO TIENE UNA CUENTA DE AHORRO
%==============================================================================================================================================================================
saving_account_money(Category, Subcategory, Year, Month, Balance):-
    exist(Category, Subcategory),
    saving_count_money(Category, Subcategory, Year, Month, Balance).