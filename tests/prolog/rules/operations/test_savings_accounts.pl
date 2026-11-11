%=================================================================================================================================================
% TESTS DE LOS METODOS AUXILIARES DE LAS CUENTAS DE AHORRO (prolog/rules/operations/savings_accounts.pl)
% Correr desde la carpeta del proyecto:
%   swipl -g run_tests -t halt tests/prolog/rules/operations/test_savings_accounts.pl
%
% Cada test empieza con estas cuentas y al terminar se restauran las que habia antes:
%   (necesidad, "hospital", 20)   (deseo, "viajes", 10)      -> suman 30
%=================================================================================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../../prolog/datos').
:- ensure_loaded('../../../../prolog/rules/operations/savings_accounts').

%--------------------------------------------------------------------------
% Ayudas (con prefijo sx_ para no chocar con las de otros archivos de tests)
%--------------------------------------------------------------------------
sx_with_accounts :-
    findall(savings_account(C, S, D, P), savings_account(C, S, D, P), Saved),
    nb_setval(sx_saved, Saved),
    retractall(savings_account(_, _, _, _)),
    assertz(savings_account(necesidad, "hospital", "Gastos medicos", 20)),
    assertz(savings_account(deseo, "viajes", "Viajes", 10)).

sx_without_accounts :-
    findall(savings_account(C, S, D, P), savings_account(C, S, D, P), Saved),
    nb_setval(sx_saved, Saved),
    retractall(savings_account(_, _, _, _)).

sx_restore_accounts :-
    retractall(savings_account(_, _, _, _)),
    nb_getval(sx_saved, Saved),
    forall(member(Fact, Saved), assertz(Fact)).

%--------------------------------------------------------------------------
% get_saving_account/3
%--------------------------------------------------------------------------
:- begin_tests(get_saving_account, [setup(sx_with_accounts), cleanup(sx_restore_accounts)]).

test(finds_existing_account) :-
    get_saving_account(necesidad, "hospital", L),
    L == [(necesidad, "hospital", 20)].

test(has_exactly_three_parts) :-
    get_saving_account(deseo, "viajes", [(Category, Name, Percent)]),
    Category == deseo,
    Name == "viajes",
    Percent == 10.

test(unknown_account_gives_empty_list) :-
    get_saving_account(necesidad, "nada", L),
    L == [].

test(same_name_other_category_is_not_found) :-
    get_saving_account(deseo, "hospital", L),
    L == [].

:- end_tests(get_saving_account).

%--------------------------------------------------------------------------
% sum_savings_account_percent/2 : devuelve lo que sumarian las cuentas con el porcentaje nuevo
%--------------------------------------------------------------------------
:- begin_tests(sum_savings_account_percent, [setup(sx_with_accounts), cleanup(sx_restore_accounts)]).

test(zero_gives_current_total) :-
    sum_savings_account_percent(0, Total),
    Total =:= 30.

test(returns_total_with_new_percent) :-
    sum_savings_account_percent(5, Total),
    Total =:= 35.

test(accepts_exactly_100) :-
    sum_savings_account_percent(70, Total),
    Total =:= 100.

test(rejects_over_100, [fail]) :-
    sum_savings_account_percent(71, _).

test(negative_difference_lowers_total) :-
    sum_savings_account_percent(-10, Total),
    Total =:= 20.

:- end_tests(sum_savings_account_percent).

:- begin_tests(sum_without_accounts, [setup(sx_without_accounts), cleanup(sx_restore_accounts)]).

test(empty_total_is_zero) :-
    sum_savings_account_percent(0, Total),
    Total =:= 0.

test(empty_accepts_100) :-
    sum_savings_account_percent(100, Total),
    Total =:= 100.

test(empty_rejects_101, [fail]) :-
    sum_savings_account_percent(101, _).

:- end_tests(sum_without_accounts).

%--------------------------------------------------------------------------
% not_exist_sb/1 y exist_sb/1
%--------------------------------------------------------------------------
:- begin_tests(exist_sb).

test(empty_list_does_not_exist, [fail]) :- exist_sb([]).
test(one_element_exists) :- exist_sb([(necesidad, "hospital", 20)]).
test(two_elements_do_not_count_as_one, [fail]) :- exist_sb([a, b]).

test(empty_list_is_free) :- not_exist_sb([]).
test(one_element_is_not_free, [fail]) :- not_exist_sb([(necesidad, "hospital", 20)]).

:- end_tests(exist_sb).

%--------------------------------------------------------------------------
% new_name_is_free/4
%--------------------------------------------------------------------------
:- begin_tests(new_name_is_free, [setup(sx_with_accounts), cleanup(sx_restore_accounts)]).

test(same_name_is_allowed) :-
    new_name_is_free(necesidad, "hospital", necesidad, "hospital").

test(unused_name_is_allowed) :-
    new_name_is_free(necesidad, "hospital", necesidad, "salud").

test(same_name_other_category_is_allowed_if_free) :-
    new_name_is_free(necesidad, "hospital", deseo, "hospital").

test(name_of_another_account_is_rejected, [fail]) :-
    new_name_is_free(necesidad, "hospital", deseo, "viajes").

:- end_tests(new_name_is_free).

%--------------------------------------------------------------------------
% arguments_rules/4
%--------------------------------------------------------------------------
:- begin_tests(arguments_rules).

test(valid_arguments) :- arguments_rules(deseo, "comida", "Comida", 10).
test(accepts_necesidad) :- arguments_rules(necesidad, "salud", "Salud", 10).
test(accepts_percent_zero) :- arguments_rules(deseo, "comida", "Comida", 0).
test(accepts_decimal) :- arguments_rules(deseo, "comida", "Comida", 2.5).

test(rejects_unknown_category, [fail]) :- arguments_rules(ocio, "comida", "Comida", 10).
test(rejects_empty_name, [fail]) :- arguments_rules(deseo, "", "Comida", 10).
test(rejects_empty_description, [fail]) :- arguments_rules(deseo, "comida", "", 10).
test(rejects_name_as_atom, [fail]) :- arguments_rules(deseo, comida, "Comida", 10).
test(rejects_description_as_atom, [fail]) :- arguments_rules(deseo, "comida", comida, 10).
test(rejects_negative_percent, [fail]) :- arguments_rules(deseo, "comida", "Comida", -1).
test(rejects_percent_as_string, [fail]) :- arguments_rules(deseo, "comida", "Comida", "10").
test(rejects_percent_as_atom, [fail]) :- arguments_rules(deseo, "comida", "Comida", diez).
test(accepts_name_global) :- arguments_rules(deseo, "global", "Comida", 10).

:- end_tests(arguments_rules).

%--------------------------------------------------------------------------
% diferent_is_valid/2 (porcentaje nuevo, porcentaje viejo)
%--------------------------------------------------------------------------
:- begin_tests(diferent_is_valid, [setup(sx_with_accounts), cleanup(sx_restore_accounts)]).

test(same_percent_is_valid, [nondet]) :-
    diferent_is_valid(20, 20).

test(raise_within_limit, [nondet]) :-
    diferent_is_valid(25, 20).

test(raise_up_to_exactly_100, [nondet]) :-
    diferent_is_valid(90, 20).

test(raise_over_100_is_rejected, [fail]) :-
    diferent_is_valid(91, 20).

test(lowering_is_valid, [nondet]) :-
    diferent_is_valid(5, 20).

test(lowering_to_zero_is_valid, [nondet]) :-
    diferent_is_valid(0, 20).

:- end_tests(diferent_is_valid).