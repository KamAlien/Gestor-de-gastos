%===================================================================================================================================================================================
% OPERACIONES DE LAS CUENTAS DE AHORRO
%===================================================================================================================================================================================
:- ensure_loaded('../datos').
:- ensure_loaded('auxiliary methods/calendar').
:- ensure_loaded('auxiliary methods/list_auxiliaries_methods').
:- ensure_loaded('auxiliary methods/account_balance').

%====================================================================================================================================================================================
% CALCULA EL LA CANTIDAD TOTAL DE DINERO HASTA EL MES ACTUAL YA SEA DE GASTOS O INGRESOS
% CALCULA LA CANTIDAD EN QUE CAMBIO EN ESOS MESES
%====================================================================================================================================================================================

% Calcula el total de ahorro de todos los meses 
total_up_to(Table, Year, Month, Total_savings):-
    findall(Amount, (call(Table, Row_year, Row_month, _, _, Amount, _),
    up_to(Row_year, Row_month, Year, Month)), List),
    sum_list(List, Total_savings).

% Calcula la suma de los ajustes que se hicieron hasta la fecha que se le pasa
adjustments_up_to(Year, Month, Total_adjustments):-
    findall( Amount, 
            (savings_adjustments( Row_year, Row_month, _, Amount),
            up_to(Row_year, Row_month, Year, Month)),
            List),
    sum_list(List, Total_adjustments).


%==================================================================================================================================================================================
% CUENTAS DE AHORRO EN PARTICULAR
%==================================================================================================================================================================================

% Existe la cuenta?
exist(Category, Subcategory):-
    findall( _, savings_account(Category, Subcategory, _, _), List),
    length(List, N),
    N == 1.


% CUANTO DINERO TIENE TAL CUENTA DE AHORRO:
saving_count_money(Category, Subcategory, Year, Month, Balance):-
    exist(Category, Subcategory),
    savings_account_balance(Category, Subcategory, Year, Month, Balance).

%===================================================================================================================================================================================
% CREAR UNA CUENTA DE AHORRO
%===================================================================================================================================================================================

create_saving_account(Category, Subcategory, Description, Percent, Year, Month, Day):-
    assertz(savings_account(Category, Subcategory, Description, Percent)),
    assertz(savings_account_percent(Year, Month, Day, Category, Subcategory, Percent)).

%===================================================================================================================================================================================
% ACTUALIZAR CUENTAS
%===================================================================================================================================================================================

% Actualizar la cuenta global:
update_global_account(Year, Month, Day):-
    sum_percent(Total_Percent),
    New_Percent is 100 - Total_Percent,
    update_savings_account(
        Year,
        Month,
        Day,
        global,
        "Cuenta de Ahorro global",
        global,
        "Cuenta de Ahorro global",
        "Es una cuenta de ahorro global, no responde a ningun tipo de categorias, sino mas bien, el porcentaje del ahorro del mes que se define para esta cuenta es el sobrante de la suma de las cuentas de ahorro. Esta cuenta no se podra eliminar o actualizar.",
        New_Percent).

% Funcion recursiva
update_history_percent([], _, _, _, _).
update_history_percent(List, Old_Category, Old_Subcategory, New_Category, New_Subcategory):-
    pop(List, Rest, Year-Month-Day-Percent),
    retract(savings_account_percent(Year, Month, Day, Old_Category, Old_Subcategory, Percent)),
    assertz(savings_account_percent(Year, Month, Day, New_Category, New_Subcategory, Percent)),
    update_history_percent(Rest, Old_Category, Old_Subcategory, New_Category, New_Subcategory).
    
% Metodo principal
update_savings_account(Year, Month, Day, Old_Category, Old_Subcategory, New_Category, New_Subcategory, New_Description, New_Percent):-
    savings_account(Old_Category, Old_Subcategory, _, Old_Percent),

    findall((Y-M-D-P), savings_account_percent(Y, M, D, Old_Category, Old_Subcategory, P), List_Changes),
    update_history_percent(List_Changes, Old_Category, Old_Subcategory, New_Category, New_Subcategory),
    (Old_Percent =\= New_Percent
    -> assertz(savings_account_percent(Year, Month, Day, New_Category, New_Subcategory, New_Percent))
    ;
    true
    ),
    retract(savings_account(
            Old_Category, Old_Subcategory, _, _)),

    assertz(savings_account(
        New_Category, New_Subcategory,
        New_Description, New_Percent)).