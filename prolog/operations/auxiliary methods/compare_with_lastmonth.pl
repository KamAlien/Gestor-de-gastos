:- ensure_loaded('../../datos').
:- encoding(utf8).

%==========================================================================================================================
% COMPARACION CON EL MES PASADO
%==========================================================================================================================

compare_result(Rest, Message):-
    Rest > 0,
    format(string(Message), "Se ha aumentado con respecto al mes anterior", []).

compare_result(Rest, Message):-
    Rest < 0,
    format(string(Message), "Se ha disminuido con respecto con el mes anterior", []).

compare_result(0, Message):-
    format(string(Message), "Se es lo mismo que el mes pasado", []).

compare_with_lastmonth(Table_1, Table_2, Year, 1, Rest, Message):- 
    LastMonth = 12,
    LastYear is Year - 1,
    summ_list_table(Table_1, LastYear, LastMonth, Last_rest),
    summ_list_table(Table_2, Year, 1, Current_rest),
    Rest is Current_rest - Last_rest,
    compare_result(Rest, Message).

compare_with_lastmonth(Table_1, Table_2, Year, Month, Rest, Message):-
    Month > 1,
    LastMonth is Month - 1,
    summ_list_table(Table_1, Year, LastMonth, Last_rest),
    summ_list_table(Table_2, Year, Month, Current_rest),
    Rest is Current_rest - Last_rest,
    compare_result(Rest, Message).

summ_list_table(Table, Year, Month, Total):-
    findall(Monto, call(Table, Year, Month, _, _, Monto, _), List_monto),
    sum_list(List_monto, Total).