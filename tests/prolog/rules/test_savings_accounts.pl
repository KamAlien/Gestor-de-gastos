%=================================================================================================================================================
% TESTS DE LAS REGLAS DE LAS CUENTAS DE AHORRO (prolog/rules/savings_accounts.pl)
% Incluye: valid_create_savings_account/4 y valid_update_savings_account/6.
% Correr desde la carpeta del proyecto:
%   swipl -g run_tests -t halt tests/prolog/rules/test_savings_accounts.pl
%
% Cada test empieza con estas cuentas (la global no cuenta, es un hecho aparte):
%   (necesidad, "hospital", 20)   (deseo, "viajes", 10)      -> suman 30
% Al terminar cada test se restauran las cuentas que habia antes, asi los datos de datos.pl no se pierden.
%=================================================================================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../prolog/rules/savings_accounts').

% Foto de las cuentas al cargar este archivo, para comprobar al final que no se perdio nada
:- findall(savings_account(C, S, D, P), savings_account(C, S, D, P), L), nb_setval(sa_original_accounts, L).

%--------------------------------------------------------------------------
% Ayudas
%--------------------------------------------------------------------------
sa_with_accounts :-
    findall(savings_account(C, S, D, P), savings_account(C, S, D, P), Saved),
    nb_setval(sa_saved, Saved),
    retractall(savings_account(_, _, _, _)),
    assertz(savings_account(necesidad, "hospital", "Gastos medicos", 20)),
    assertz(savings_account(deseo, "viajes", "Viajes", 10)).

sa_restore_accounts :-
    retractall(savings_account(_, _, _, _)),
    nb_getval(sa_saved, Saved),
    forall(member(Fact, Saved), assertz(Fact)).

sa_count_accounts(N) :-
    findall(x, savings_account(_, _, _, _), L),
    length(L, N).

%--------------------------------------------------------------------------
% valid_create_savings_account/4
%--------------------------------------------------------------------------
:- begin_tests(valid_create_savings_account, [setup(sa_with_accounts), cleanup(sa_restore_accounts)]).

test(accepts_new_account) :-
    valid_create_savings_account(deseo, "comida", "Comida", 20).

test(accepts_same_name_in_other_category) :-
    valid_create_savings_account(necesidad, "viajes", "Viajes por trabajo", 5).

test(accepts_exactly_100_total) :-
    valid_create_savings_account(deseo, "comida", "Comida", 70).

test(accepts_percent_zero) :-
    valid_create_savings_account(deseo, "comida", "Comida", 0).

test(accepts_decimal_percent) :-
    valid_create_savings_account(deseo, "comida", "Comida", 12.5).

test(rejects_total_over_100, [fail]) :-
    valid_create_savings_account(deseo, "comida", "Comida", 71).

test(rejects_same_name_same_category, [fail]) :-
    valid_create_savings_account(deseo, "viajes", "Otra descripcion", 5).

test(rejects_empty_name, [fail]) :-
    valid_create_savings_account(deseo, "", "Descripcion", 5).

test(rejects_empty_description, [fail]) :-
    valid_create_savings_account(deseo, "comida", "", 5).

test(rejects_unknown_category, [fail]) :-
    valid_create_savings_account(ocio, "comida", "Comida", 5).

test(rejects_negative_percent, [fail]) :-
    valid_create_savings_account(deseo, "comida", "Comida", -1).

test(rejects_percent_as_string, [fail]) :-
    valid_create_savings_account(deseo, "comida", "Comida", "20").

test(rejects_name_as_atom, [fail]) :-
    valid_create_savings_account(deseo, comida, "Comida", 5).

test(rejects_description_as_atom, [fail]) :-
    valid_create_savings_account(deseo, "comida", comida, 5).

% Las reglas solo validan: no deben guardar nada.
test(does_not_change_the_data) :-
    sa_count_accounts(Before),
    valid_create_savings_account(deseo, "comida", "Comida", 20),
    \+ valid_create_savings_account(deseo, "viajes", "Otra", 5),
    sa_count_accounts(After),
    After =:= Before.

:- end_tests(valid_create_savings_account).

%--------------------------------------------------------------------------
% valid_update_savings_account/6
% (old_category, old_name, new_category, new_name, new_description, new_percent)
%--------------------------------------------------------------------------
:- begin_tests(valid_update_savings_account, [setup(sa_with_accounts), cleanup(sa_restore_accounts)]).

test(accepts_change_percent_same_name, [nondet]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 25).

test(accepts_change_description_only, [nondet]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "Otra descripcion", 20).

test(accepts_lowering_percent, [nondet]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 5).

test(accepts_up_to_exactly_100, [nondet]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 90).

test(rejects_over_100_same_name, [fail]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 91).

test(accepts_rename_to_free_name, [nondet]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "salud", "Salud", 25).

test(accepts_rename_and_change_category, [nondet]) :-
    valid_update_savings_account(necesidad, "hospital", deseo, "salud", "Salud", 20).

test(rejects_rename_over_100, [fail]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "salud", "Salud", 100).

test(rejects_rename_to_existing_account, [fail]) :-
    valid_update_savings_account(necesidad, "hospital", deseo, "viajes", "Viajes", 20).

test(accepts_rename_to_global, [nondet]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "global", "Global", 20).

test(rejects_unknown_old_account, [fail]) :-
    valid_update_savings_account(necesidad, "nada", necesidad, "nada", "Nada", 5).

test(rejects_old_account_in_wrong_category, [fail]) :-
    valid_update_savings_account(deseo, "hospital", deseo, "hospital", "Gastos medicos", 5).


test(rejects_empty_new_name, [fail]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "", "Salud", 20).

test(rejects_empty_new_description, [fail]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "", 20).

test(rejects_unknown_new_category, [fail]) :-
    valid_update_savings_account(necesidad, "hospital", ocio, "hospital", "Gastos medicos", 20).

test(rejects_negative_new_percent, [fail]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "Gastos medicos", -5).

test(rejects_new_percent_as_string, [fail]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "Gastos medicos", "25").

% Solo cuenta la diferencia: subir 20 -> 25 con otra cuenta de 10 no debe contar el 20 viejo otra vez.
test(old_percent_is_not_counted_twice, [nondet]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 90),
    \+ valid_update_savings_account(necesidad, "hospital", necesidad, "hospital", "Gastos medicos", 91).

test(does_not_change_the_data, [nondet]) :-
    sa_count_accounts(Before),
    valid_update_savings_account(necesidad, "hospital", necesidad, "salud", "Salud", 25),
    \+ valid_update_savings_account(necesidad, "hospital", deseo, "viajes", "Viajes", 20),
    sa_count_accounts(After),
    After =:= Before,
    savings_account(necesidad, "hospital", "Gastos medicos", 20).

:- end_tests(valid_update_savings_account).

%--------------------------------------------------------------------------
% Datos reales (datos.pl): la cuenta global y que todo cuadre
%--------------------------------------------------------------------------
:- begin_tests(savings_data).

test(global_account_exists, [nondet]) :-
    savings_account_global(Name, Description, Percent),
    string(Name),
    string(Description),
    number(Percent).

% Si no fuera dynamic, no se podria actualizar con retract/assertz.
test(global_account_is_dynamic) :-
    predicate_property(savings_account_global(_, _, _), dynamic).

test(only_one_global_account) :-
    findall(x, savings_account_global(_, _, _), L),
    length(L, 1).

% Invariante: la global se queda con lo que sobra, asi que global + las demas = 100.
test(global_plus_accounts_is_100, [nondet]) :-
    savings_account_global(_, _, Global),
    findall(P, savings_account(_, _, _, P), Percents),
    sum_list(Percents, Sum),
    Global + Sum =:= 100.

:- end_tests(savings_data).

%--------------------------------------------------------------------------
% Detector: si algun test anterior dejo las cuentas cambiadas, falla.
%--------------------------------------------------------------------------
:- begin_tests(savings_accounts_cleanup).

test(accounts_are_as_before_the_tests) :-
    findall(savings_account(C, S, D, P), savings_account(C, S, D, P), Now),
    nb_getval(sa_original_accounts, Original),
    Now == Original.

:- end_tests(savings_accounts_cleanup).