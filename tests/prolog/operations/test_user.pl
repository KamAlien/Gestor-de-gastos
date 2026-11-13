%=================================================================================================================================================
% TESTS DE LAS OPERACIONES DEL USUARIO (prolog/operations/user.pl)
% Incluye: crear, actualizar y ver el usuario, y registrar ingresos y gastos.
% Correr desde la carpeta del proyecto:
%   swipl -g run_tests -t halt tests/prolog/operations/test_user.pl
%
% Cada test que toca la base de datos empieza y termina con ella limpia (setup / cleanup),
% asi un test no depende del resultado de otro.
%
% Los tests de registro escriben en incomes/6 y expenses/6, que tambien tienen los datos de prueba de datos.pl.
% Para no mezclarlos, usan los anios 2096 (bisiesto) y 2099, y despues de cada test se borra solo lo de esos anios.
% Los datos de prueba de datos.pl (2026) no se tocan.
%=================================================================================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../prolog/operations/user').

%--------------------------------------------------------------------------
% Ayudas para los tests del usuario
%--------------------------------------------------------------------------
clean_users :- retractall(user(_, _, _)).
add_user(Name, Age, Email) :- assertz(user(Name, Age, Email)).
setup_with_user :- clean_users, add_user("Kam", 20, "k@x.com").

%--------------------------------------------------------------------------
% Ayudas para los tests de registro
%--------------------------------------------------------------------------
clean_test_data :-
    retractall(incomes(2099, _, _, _, _, _)),
    retractall(expenses(2099, _, _, _, _, _)),
    retractall(incomes(2096, _, _, _, _, _)),
    retractall(expenses(2096, _, _, _, _, _)).

count_incomes(N) :-
    findall(x, incomes(_, _, _, _, _, _), L),
    length(L, N).

count_expenses(N) :-
    findall(x, expenses(_, _, _, _, _, _), L),
    length(L, N).

%--------------------------------------------------------------------------
% create_user/3 : registrar (solo si todavia no hay usuario)
%--------------------------------------------------------------------------
:- begin_tests(create_user).

test(creates_first_user, [setup(clean_users), cleanup(clean_users)]) :-
    create_user("Kam", 20, "k@x.com"),
    user("Kam", 20, "k@x.com").

test(rejects_second_user, [fail, setup(clean_users), cleanup(clean_users)]) :-
    create_user("Kam", 20, "k@x.com"),
    create_user("Otra", 22, "o@x.com").

test(second_user_not_stored, [setup(clean_users), cleanup(clean_users)]) :-
    create_user("Kam", 20, "k@x.com"),
    \+ create_user("Otra", 22, "o@x.com"),
    findall(N, user(N, _, _), Names),
    Names == ["Kam"].

test(invalid_data_not_stored, [setup(clean_users), cleanup(clean_users)]) :-
    \+ create_user("", 20, "k@x.com"),
    \+ user(_, _, _).

:- end_tests(create_user).

%--------------------------------------------------------------------------
% update_user/3 : cambiar datos (solo si ya hay usuario y los datos son validos)
%--------------------------------------------------------------------------
:- begin_tests(update_user).

test(fails_without_user, [fail, setup(clean_users), cleanup(clean_users)]) :-
    update_user("Kam", 21, "n@x.com").

test(updates_data, [setup(setup_with_user), cleanup(clean_users)]) :-
    update_user("Kam", 21, "nuevo@x.com"),
    user("Kam", 21, "nuevo@x.com").

test(keeps_single_user, [setup(setup_with_user), cleanup(clean_users)]) :-
    update_user("Kam", 21, "nuevo@x.com"),
    findall(x, user(_, _, _), List),
    length(List, 1).

test(invalid_update_changes_nothing, [setup(setup_with_user), cleanup(clean_users)]) :-
    \+ update_user("", 21, "x@x.com"),
    user("Kam", 20, "k@x.com").

:- end_tests(update_user).

%--------------------------------------------------------------------------
% show_user/1 : devuelve el usuario como texto
%--------------------------------------------------------------------------
:- begin_tests(show_user).

test(shows_name, [setup(setup_with_user), cleanup(clean_users)]) :-
    show_user(Message),
    once(sub_string(Message, _, _, _, "Kam")).

test(empty_when_no_user, [setup(clean_users)]) :-
    show_user(Message),
    Message == "[]".

:- end_tests(show_user).

%--------------------------------------------------------------------------
% register_incomes/6
%--------------------------------------------------------------------------
:- begin_tests(register_incomes).

test(saves_extra_income, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 3, 9, "Beca", 300, ingreso_extra),
    incomes(2099, 3, 9, "Beca", 300, ingreso_extra).

test(saves_salary, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 3, 2, "Salario", 1000, salario),
    incomes(2099, 3, 2, "Salario", 1000, salario).

test(adds_exactly_one_fact, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    count_incomes(Before),
    register_incomes(2099, 3, 9, "Beca", 300, ingreso_extra),
    count_incomes(After),
    After =:= Before + 1.

test(does_not_touch_expenses, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    count_expenses(Before),
    register_incomes(2099, 3, 9, "Beca", 300, ingreso_extra),
    count_expenses(After),
    After =:= Before.

test(registered_income_can_be_summed, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 3, 9, "Beca", 300, ingreso_extra),
    register_incomes(2099, 3, 10, "Venta", 200, ingreso_extra),
    findall(M, incomes(2099, 3, _, _, M, _), Montos),
    sum_list(Montos, Total),
    Total =:= 500.

% Dos ingresos iguales el mismo dia son legitimos: se guardan los dos.
test(same_income_twice_is_kept, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 3, 9, "Beca", 300, ingreso_extra),
    register_incomes(2099, 3, 9, "Beca", 300, ingreso_extra),
    findall(x, incomes(2099, 3, 9, "Beca", 300, ingreso_extra), L),
    length(L, 2).

% Documenta la decision actual (Amount >= 0). Si cambias a > 0, cambia este test a [fail].
test(amount_zero_is_accepted, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 3, 9, "Nada", 0, ingreso_extra),
    incomes(2099, 3, 9, "Nada", 0, ingreso_extra).

test(leap_day_is_accepted, [nondet, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2096, 2, 29, "Regalo", 50, ingreso_extra),
    incomes(2096, 2, 29, "Regalo", 50, ingreso_extra).

% --- lo que NO debe guardarse: la operacion falla y la base queda igual ---

test(rejects_unknown_type, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 3, 9, "Beca", 300, foo).

test(rejects_expense_category, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 3, 9, "Beca", 300, deseo).

test(rejects_impossible_date, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 4, 31, "Beca", 300, ingreso_extra).

test(rejects_feb_29_not_leap, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 2, 29, "Beca", 300, ingreso_extra).

test(rejects_month_13, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 13, 1, "Beca", 300, ingreso_extra).

test(rejects_empty_description, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 3, 9, "", 300, ingreso_extra).

test(rejects_negative_amount, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 3, 9, "Beca", -300, ingreso_extra).

test(rejects_amount_as_string, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_incomes(2099, 3, 9, "Beca", "300", ingreso_extra).

test(invalid_income_leaves_database_unchanged, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    count_incomes(Before),
    \+ register_incomes(2099, 4, 31, "Beca", 300, ingreso_extra),
    \+ register_incomes(2099, 3, 9, "Beca", 300, foo),
    \+ register_incomes(2099, 3, 9, "", 300, ingreso_extra),
    count_incomes(After),
    After =:= Before.

:- end_tests(register_incomes).

%--------------------------------------------------------------------------
% register_expenses/6
%--------------------------------------------------------------------------
:- begin_tests(register_expenses).

test(saves_need, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 3, 2, "Super mercado", 200, necesidad),
    expenses(2099, 3, 2, "Super mercado", 200, necesidad).

test(saves_want, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 3, 3, "Restaurante", 500, deseo),
    expenses(2099, 3, 3, "Restaurante", 500, deseo).

test(adds_exactly_one_fact, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    count_expenses(Before),
    register_expenses(2099, 3, 2, "Super mercado", 200, necesidad),
    count_expenses(After),
    After =:= Before + 1.

test(does_not_touch_incomes, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    count_incomes(Before),
    register_expenses(2099, 3, 2, "Super mercado", 200, necesidad),
    count_incomes(After),
    After =:= Before.

test(registered_expense_can_be_summed, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 3, 2, "Super mercado", 200, necesidad),
    register_expenses(2099, 3, 3, "Restaurante", 500, deseo),
    findall(M, expenses(2099, 3, _, _, M, _), Montos),
    sum_list(Montos, Total),
    Total =:= 700.

test(same_expense_twice_is_kept, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 3, 2, "Cafe", 5, deseo),
    register_expenses(2099, 3, 2, "Cafe", 5, deseo),
    findall(x, expenses(2099, 3, 2, "Cafe", 5, deseo), L),
    length(L, 2).

% Documenta la decision actual (Amount >= 0). Si cambias a > 0, cambia este test a [fail].
test(amount_zero_is_accepted, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 3, 2, "Regalo recibido", 0, deseo),
    expenses(2099, 3, 2, "Regalo recibido", 0, deseo).

test(leap_day_is_accepted, [nondet, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2096, 2, 29, "Cine", 50, deseo),
    expenses(2096, 2, 29, "Cine", 50, deseo).

% --- lo que NO debe guardarse ---

test(rejects_unknown_category, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 3, 9, "Cine", 50, foo).

test(rejects_income_type, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 3, 9, "Cine", 50, salario).

test(rejects_impossible_date, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 4, 31, "Cine", 50, deseo).

test(rejects_feb_29_not_leap, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 2, 29, "Cine", 50, deseo).

test(rejects_month_13, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 13, 1, "Cine", 50, deseo).

test(rejects_empty_description, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 3, 9, "", 50, deseo).

test(rejects_negative_amount, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 3, 9, "Cine", -50, deseo).

test(rejects_amount_as_string, [fail, setup(clean_test_data), cleanup(clean_test_data)]) :-
    register_expenses(2099, 3, 9, "Cine", "50", deseo).

test(invalid_expense_leaves_database_unchanged, [setup(clean_test_data), cleanup(clean_test_data)]) :-
    count_expenses(Before),
    \+ register_expenses(2099, 4, 31, "Cine", 50, deseo),
    \+ register_expenses(2099, 3, 9, "Cine", 50, foo),
    \+ register_expenses(2099, 3, 9, "", 50, deseo),
    count_expenses(After),
    After =:= Before.

:- end_tests(register_expenses).

%--------------------------------------------------------------------------
% Detector de basura: corre al final y falla si algun test anterior dejo datos
% en los anios de prueba, o si se perdieron los datos de datos.pl.
%--------------------------------------------------------------------------
:- begin_tests(register_cleanup).

test(no_leftovers_in_test_years) :-
    \+ incomes(2099, _, _, _, _, _),
    \+ expenses(2099, _, _, _, _, _),
    \+ incomes(2096, _, _, _, _, _),
    \+ expenses(2096, _, _, _, _, _).

test(sample_data_still_there, [nondet]) :-
    incomes(2026, 3, 2, "Salario", 1000, salario),
    expenses(2026, 3, 2, "Super mercado", 200, necesidad).

:- end_tests(register_cleanup).