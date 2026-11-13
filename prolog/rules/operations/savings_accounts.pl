%=========================================================================================================================
% AUXILIARY METHODS
%=========================================================================================================================
:- ensure_loaded('../../types/categories').


% Comprueba que sea valido los argumentos
arguments_rules(Category, Subcategory, Description, Percent):-
    string(Description),
    expenses_type(Category),
    string(Subcategory),
    number(Percent),
    Subcategory \== "",
    Subcategory \== "Cuenta de Ahorro global",
    Description \== "",
    Description \== "Es una cuenta de ahorro global, no responde a ningun tipo de categorias, sino mas bien, el porcentaje del ahorro del mes que se define para esta cuenta es el sobrante de la suma de las cuentas de ahorro. Esta cuenta no se podra eliminar o actualizar.",
    Percent >= 0.


% Preguntar por una cuenta de ahorro
get_saving_account(Category, Subcategory, Saving_account):-
    findall((Category, Subcategory, Percent), savings_account(Category, Subcategory, _, Percent), Saving_account).


% Calcula la suma de los porcentajes de las cuentas para una cuenta nueva
sum_savings_account_percent(Percent, Total_percents):-
    findall(Percents, (savings_account(Category , _, _, Percents), Category \== global), List_percent),
    sum_list(List_percent, Total_percent),
    Is_valid is Total_percent + Percent,
    Is_valid =< 100,
    Total_percents = Is_valid.


% Pregunta si la subcategoria existe
not_exist_sb(List):-
    length(List, N),
    N == 0.


exist_sb(List):-
    length(List, N),
    N == 1.


% El nombre nuevo sirve si es el mismo de antes o si todavia no existe
new_name_is_free(Old_Category, Old_Subcategory, New_Category, New_Subcategory):-
    (   Old_Category == New_Category,
        Old_Subcategory == New_Subcategory
    -> true
    ;   get_saving_account(New_Category, New_Subcategory, New_account),
    not_exist_sb(New_account)
).


% Metodo de actualizar Pregunta si los porcentajes son distintos si es asi calcula si es valido
diferent_is_valid(New_Percent, Old_Percent):-
    New_Percent \== Old_Percent,
    Percent is New_Percent - Old_Percent,
    sum_savings_account_percent(Percent, _).

diferent_is_valid(New_Percent, Old_Percent):-
    New_Percent == Old_Percent.