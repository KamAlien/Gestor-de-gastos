%=================================================================================================================================================
% OPERACIONES DE LAS CUENTAS DE AHORRO
%=================================================================================================================================================  
:- ensure_loaded('../datos').
:- ensure_loaded('auxiliary methods/calendar').

total_up_to(Table, Year, Month, Total_savings):-
    findall(Amount, (call(Table, Row_year, Row_month, _, _, Amount, _),
    up_to(Row_year, Row_month, Year, Month)), List),
sum_list(List, Total_savings).

adjustments_up_to(Year, Month, Total_adjustments):-
    findall( Amount, 
            (savings_adjustments( Row_year, Row_month, _, Amount),
            up_to(Row_year, Row_month, Year, Month)),
            List),
    sum_list(List, Total_adjustments).

% Cuenta de ahorro completa añadirle la categoria
savings_account(Year, Month, Amount):-
    total_up_to(incomes, Year, Month, Total_incomes),
    total_up_to(expenses, Year, Month, Total_expenses),
    adjustments_up_to(Year, Month, Total_adjustments),
    Amount is Total_incomes - Total_expenses + Total_adjustments.
