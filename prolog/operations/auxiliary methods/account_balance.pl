%============================================================================================================
% SALDO DE UNA CUENTA DE AHORRO, POR TRAMOS
% Un tramo va desde un porcentaje, empieza a regir hasta que empieza el siguiente
%============================================================================================================

:- ensure_loaded('../../datos').
:- ensure_loaded('list_auxiliaries_methods').
:- ensure_loaded('../savings').

% Un mes como un solo numero: asi comparar fechas es comparar numeros
month_index(Year, Month, Index):-
    Index is Year * 12 + Month.


% Lo que se ahorro entre 2 meses (como numeros): cuenta desde Start y no cuenta END
saving_between(Start, End, Saving):-
    Last is End -1,
    findall(S, (between(Start, Last, Index),
                Year is (Index -1) // 12,
                Month is (Index - 1) mod 12 + 1,
                total_month_saving(Year, Month, S)
                ),
            Savings),
    sum_list(Savings, Saving).


% Cambios de porcentaje de una cuenta hasta un mes, ordenados por fecha
account_changes(Category, Subcategory, Year, Month, Changes):-
    month_index(Year, Month, Last),
    findall(Start-Percent,
            (savings_account_percent( Y, M , _,Category, Subcategory, Percent),
            month_index(Y, M, Start),
            Start =< Last),
            Unsorted),
    keysort(Unsorted, Changes).


% Recorre los cambios. Se lleva el inicio y el porcentaje del tramo actual, y va armano la lista de lo que le toco a la cuenta en cada tramo
tramos_share(Changes, Start, Percent, End, Shares):-
    ( Changes == []
    -> % Ya no quedan cambios es el ultimo tramo desde el ultimo cambio hasta la fecha actual 
    saving_between(Start, End, Saving),
    Share is Saving * Percent / 100,
    Shares = [Share]
    ;
    pop(Changes, Rest, Next_start-Next_percent),
    saving_between(Start, Next_start, Saving),
    Share is Saving * Percent / 100,
    tramos_share(Rest, Next_start, Next_percent, End, Rest_shares),
    Shares = [Share | Rest_shares]).


% Saldo de una cuenta hasta un mes. Falla si la cuenta no existe
savings_account_balance(Category, Subcategory, Year, Month, Balance):-
    once(savings_account_percent(_, _, _, Category, Subcategory, _)),
    account_changes(Category, Subcategory, Year, Month, Changes),
    month_index(Year, Month, Last),
    End is Last + 1,
    (Changes == []
    -> Balance = 0
    ;
    pop(Changes, Rest, First_start-First_percent),
    tramos_share(Rest, First_start, First_percent, End, Shares),
    sum_list(Shares, Balance)).


%===============================================================================================================================================================================================================
% CALCULA EL PORCENTAJE TOTAL Y LO QUE SOBRE SE QUEDA EN LA CUENTA GLOBAL
%===============================================================================================================================================================================================================

sum_percent(Total_Percent):-
    findall(Percent, (savings_account(Category, _, _, Percent), Category \== global), List_Percent),
    sum_list(List_Percent, Total_Percent).