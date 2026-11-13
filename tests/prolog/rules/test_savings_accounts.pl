%=================================================================================================================================================
% TESTS DE LAS REGLAS DE LAS CUENTAS DE AHORRO (prolog/rules/savings_accounts.pl)
% Incluye: valid_create_savings_account/4 y valid_update_savings_account/6.
% Correr desde la carpeta del proyecto:
%   swipl -g run_tests -t halt tests/prolog/rules/test_savings_accounts.pl
%
% Cada test empieza con estas cuentas (la global esta, pero no cuenta en la suma):
%   (global, "Cuenta de Ahorro global", 70)  (necesidad, "hospital", 20)  (deseo, "viajes", 10)
% Al terminar cada test se restauran las cuentas que habia antes, asi los datos de datos.pl no se pierden.
%=================================================================================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../prolog/rules/savings_accounts').

% Foto de las cuentas y de sus porcentajes al cargar este archivo, para comprobar al final que no se perdio nada
:- findall(savings_account(C, S, D, P), savings_account(C, S, D, P), L), nb_setval(sa_original_accounts, L).
:- findall(savings_account_percent(Y, M, D, C, S, P), savings_account_percent(Y, M, D, C, S, P), L), nb_setval(sa_original_percents, L).

%--------------------------------------------------------------------------
% Ayudas
%--------------------------------------------------------------------------
sa_with_accounts :-
    findall(savings_account(C, S, D, P), savings_account(C, S, D, P), Saved),
    nb_setval(sa_saved, Saved),
    retractall(savings_account(_, _, _, _)),
    assertz(savings_account(global, "Cuenta de Ahorro global", "Descripcion global", 70)),
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

% La global tiene 70 pero no cuenta: 20 + 10 + 70 = 100 es lo maximo que se puede crear.
test(accepts_exactly_100_total_not_counting_global) :-
    valid_create_savings_account(deseo, "comida", "Comida", 70).

test(accepts_percent_zero) :-
    valid_create_savings_account(deseo, "comida", "Comida", 0).

test(accepts_decimal_percent) :-
    valid_create_savings_account(deseo, "comida", "Comida", 12.5).

test(accepts_name_global_as_a_normal_name) :-
    valid_create_savings_account(deseo, "global", "Otra global", 5).

test(accepts_name_that_only_contains_global) :-
    valid_create_savings_account(deseo, "globalizacion", "Cursos", 5).

test(rejects_total_over_100, [fail]) :-
    valid_create_savings_account(deseo, "comida", "Comida", 71).

test(rejects_same_name_same_category, [fail]) :-
    valid_create_savings_account(deseo, "viajes", "Otra descripcion", 5).

test(rejects_the_name_of_the_global_account, [fail]) :-
    valid_create_savings_account(deseo, "Cuenta de Ahorro global", "Otra", 5).

test(rejects_creating_in_category_global, [fail]) :-
    valid_create_savings_account(global, "comida", "Comida", 5).

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

test(accepts_rename_to_the_word_global, [nondet]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "global", "Salud", 20).

test(rejects_rename_over_100, [fail]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "salud", "Salud", 100).

test(rejects_rename_to_existing_account, [fail]) :-
    valid_update_savings_account(necesidad, "hospital", deseo, "viajes", "Viajes", 20).

test(rejects_rename_to_the_global_account_name, [fail]) :-
    valid_update_savings_account(necesidad, "hospital", necesidad, "Cuenta de Ahorro global", "Salud", 20).

test(rejects_unknown_old_account, [fail]) :-
    valid_update_savings_account(necesidad, "nada", necesidad, "nada", "Nada", 5).

test(rejects_old_account_in_wrong_category, [fail]) :-
    valid_update_savings_account(deseo, "hospital", deseo, "hospital", "Gastos medicos", 5).

% La cuenta global no se actualiza por aqui: su categoria (global) no es de gastos.
test(global_cannot_be_updated, [fail]) :-
    valid_update_savings_account(global, "Cuenta de Ahorro global", global, "Cuenta de Ahorro global", "Otra", 50).

test(cannot_turn_an_account_into_global, [fail]) :-
    valid_update_savings_account(necesidad, "hospital", global, "hospital", "Gastos medicos", 20).

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

% Solo cuenta la diferencia: subir 20 -> 90 con otra cuenta de 10 llega justo a 100 (no cuenta el 20 viejo otra vez).
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
    savings_account(global, Name, Description, Percent),
    string(Name),
    string(Description),
    number(Percent).

test(only_one_global_account) :-
    findall(x, savings_account(global, _, _, _), L),
    length(L, 1).

% Si no fueran dynamic, no se podrian actualizar con retract/assertz.
test(savings_account_is_dynamic) :-
    predicate_property(savings_account(_, _, _, _), dynamic).

test(savings_account_percent_is_dynamic) :-
    predicate_property(savings_account_percent(_, _, _, _, _, _), dynamic).

% Invariante: la global se queda con lo que sobra, asi que global + las demas = 100.
test(global_plus_accounts_is_100, [nondet]) :-
    findall(P, savings_account(_, _, _, P), Percents),
    sum_list(Percents, Sum),
    Sum =:= 100.

% Todas las cuentas (global incluida) tienen al menos un porcentaje en el historial
test(every_account_has_a_percent_history) :-
    forall(savings_account(C, S, _, _),
        once(savings_account_percent(_, _, _, C, S, _))).

% Y todo porcentaje del historial es de una cuenta que existe
test(every_percent_belongs_to_an_account) :-
    forall(savings_account_percent(_, _, _, C, S, _),
        once(savings_account(C, S, _, _))).

test(history_percents_are_numbers) :-
    forall(savings_account_percent(_, _, _, _, _, P), number(P)).

:- end_tests(savings_data).

%--------------------------------------------------------------------------
% Detector: si algun test anterior dejo las cuentas cambiadas, falla.
%--------------------------------------------------------------------------
:- begin_tests(savings_accounts_cleanup).

test(accounts_are_as_before_the_tests) :-
    findall(savings_account(C, S, D, P), savings_account(C, S, D, P), Now),
    nb_getval(sa_original_accounts, Original),
    Now == Original.

test(percents_are_as_before_the_tests) :-
    findall(savings_account_percent(Y, M, D, C, S, P), savings_account_percent(Y, M, D, C, S, P), Now),
    nb_getval(sa_original_percents, Original),
    Now == Original.

:- end_tests(savings_accounts_cleanup).
