:- encoding(utf8).
%=========================================================================================
% TESTS DE prolog/rules/valid_category.pl
% valid_create_category/2, valid_update_category/3, valid_new_name/2, valid_delete_category/1,
% valid_change_percent/1 y valid_list_changes/2. Reemplaza al test_valid_category.pl anterior.
%=========================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../helpers_persistence').
:- ensure_loaded('../../helpers_classification').
:- ensure_loaded('../../../prolog/rules/valid_category').

%-----------------------------------------------------------------------------------------
% Helpers (fuera de los tests)
%   vc_backup / vc_restore : UNA vez por unidad (guardan y devuelven tus datos reales)
%   vc_fixture             : antes de CADA test (deja los datos conocidos de abajo)
%-----------------------------------------------------------------------------------------
vc_specs([categories/3, expenses/7]).

vc_backup  :- vc_specs(Specs), cl_backup, pf_setup(Specs).
vc_restore :- vc_specs(Specs), pf_cleanup(Specs), cl_restore.

vc_fixture :-
    vc_specs(Specs),
    pf_clear(Specs),
    pf_assert_all([ categories(necesidad, "Necesidades", 50),
                    categories(deseo, "Deseos", 30),
                    categories(ahorro, "Ahorro", 20),
                    categories(extra, "Extra", 0),
                    expenses(2026, 3, 1, "Renta", 1000, necesidad, "alquiler"),
                    expenses(2026, 3, 3, "Cine", 50, deseo, "salidas") ]),
    cl_clear,
    cl_add_text_rule("cine", deseo),
    cl_add_exception("hospital", "urgencia", necesidad),
    cl_add_general("alquiler", necesidad).

% variantes: "extra" usada por un gasto / una regla de cada tipo
vc_expense_with_extra :- pf_assert_all([expenses(2026, 3, 20, "Algo", 5, extra, "otros")]).
vc_text_rule_with_extra :- cl_add_text_rule("viaje", extra).
vc_exception_with_extra :- cl_add_exception("hospital", "dolor", extra).
vc_general_with_extra :- cl_add_general("viajes", extra).

vc_delete_category(Category) :- retractall(categories(Category, _, _)).

%-----------------------------------------------------------------------------------------
% valid_create_category/2
%-----------------------------------------------------------------------------------------
:- begin_tests(valid_create_category, [setup(vc_backup), cleanup(vc_restore)]).

test(a_new_name_is_valid, [setup(vc_fixture)]) :-
    valid_create_category(viajes, "Para viajar").

test(an_existing_name_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_create_category(deseo, "Otra descripcion").

test(pendiente_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_create_category(pendiente, "No vale").

test(an_empty_name_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_create_category('', "Descripcion").

test(the_name_must_be_an_atom, [fail, setup(vc_fixture)]) :-
    valid_create_category("viajes", "Descripcion").

test(the_name_cannot_be_a_number, [fail, setup(vc_fixture)]) :-
    valid_create_category(5, "Descripcion").

test(an_empty_description_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_create_category(viajes, "").

test(the_description_must_be_a_string, [fail, setup(vc_fixture)]) :-
    valid_create_category(viajes, descripcion).

test(unbound_arguments_are_not_valid, [setup(vc_fixture)]) :-
    \+ valid_create_category(_, "Descripcion"),
    \+ valid_create_category(viajes, _).

test(ahorro_cannot_be_created_twice, [fail, setup(vc_fixture)]) :-
    valid_create_category(ahorro, "Otra vez").

test(ahorro_is_free_again_after_deleting_it, [setup(vc_fixture)]) :-
    vc_delete_category(ahorro),
    valid_create_category(ahorro, "De nuevo").

test(is_deterministic, [setup(vc_fixture)]) :-
    findall(x, valid_create_category(viajes, "Para viajar"), L),
    L == [x].

:- end_tests(valid_create_category).

%-----------------------------------------------------------------------------------------
% valid_update_category/3 (renombrar una categoria en uso SI se permite: update_category
% actualiza sus gastos y sus reglas)
%-----------------------------------------------------------------------------------------
:- begin_tests(valid_update_category, [setup(vc_backup), cleanup(vc_restore)]).

test(rename_to_a_free_name, [setup(vc_fixture)]) :-
    valid_update_category(extra, capricho, "Antojos").

test(rename_a_category_used_by_expenses_and_rules, [setup(vc_fixture)]) :-
    valid_update_category(deseo, capricho, "Antojos").

test(rename_a_category_used_by_every_kind_of_rule, [setup(vc_fixture)]) :-
    vc_expense_with_extra, vc_text_rule_with_extra, vc_exception_with_extra, vc_general_with_extra,
    valid_update_category(extra, capricho, "Antojos").

test(only_the_description_changes, [setup(vc_fixture)]) :-
    valid_update_category(deseo, deseo, "Descripcion nueva").

test(rename_and_description_at_once, [setup(vc_fixture)]) :-
    valid_update_category(deseo, capricho, "Otra descripcion").

test(rename_keeping_the_same_description, [setup(vc_fixture)]) :-
    valid_update_category(deseo, capricho, "Deseos").

test(nothing_changes_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_update_category(deseo, deseo, "Deseos").

test(the_old_category_must_exist, [fail, setup(vc_fixture)]) :-
    valid_update_category(viajes, otro, "Descripcion").

test(the_new_name_must_be_free, [fail, setup(vc_fixture)]) :-
    valid_update_category(deseo, necesidad, "Descripcion").

test(pendiente_is_not_a_valid_new_name, [fail, setup(vc_fixture)]) :-
    valid_update_category(deseo, pendiente, "Deseos").

test(pendiente_with_a_new_description_is_not_valid_either, [fail, setup(vc_fixture)]) :-
    valid_update_category(deseo, pendiente, "Otra descripcion").

test(an_empty_description_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_update_category(deseo, capricho, "").

test(the_new_name_must_be_an_atom, [fail, setup(vc_fixture)]) :-
    valid_update_category(deseo, "capricho", "Antojos").

test(an_empty_new_name_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_update_category(deseo, '', "Antojos").

test(unbound_new_data_is_not_valid, [setup(vc_fixture)]) :-
    \+ valid_update_category(deseo, _, "Antojos"),
    \+ valid_update_category(deseo, capricho, _).

test(is_deterministic, [setup(vc_fixture)]) :-
    findall(x, valid_update_category(deseo, capricho, "Antojos"), L),
    L == [x].

test(does_not_change_any_data, [setup(vc_fixture)]) :-
    pf_facts(categories/3, C0), pf_facts(expenses/7, E0), pf_facts(text_rule/2, T0),
    valid_update_category(deseo, capricho, "Antojos"),
    pf_facts(categories/3, C1), pf_facts(expenses/7, E1), pf_facts(text_rule/2, T1),
    C0 == C1, E0 == E1, T0 == T1.

:- end_tests(valid_update_category).

%-----------------------------------------------------------------------------------------
% valid_new_name/2
%-----------------------------------------------------------------------------------------
:- begin_tests(valid_new_name, [setup(vc_backup), cleanup(vc_restore)]).

test(the_same_name_is_always_fine, [setup(vc_fixture)]) :-
    valid_new_name(deseo, deseo).

test(a_free_name, [setup(vc_fixture)]) :-
    valid_new_name(extra, capricho).

test(a_free_name_for_a_category_in_use, [setup(vc_fixture)]) :-
    valid_new_name(deseo, capricho).

test(a_taken_name_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_new_name(deseo, necesidad).

test(is_deterministic, [setup(vc_fixture)]) :-
    findall(x, valid_new_name(deseo, capricho), L),
    L == [x].

:- end_tests(valid_new_name).

%-----------------------------------------------------------------------------------------
% valid_delete_category/1 (solo se borra con 0 % y sin usar)
%-----------------------------------------------------------------------------------------
:- begin_tests(valid_delete_category, [setup(vc_backup), cleanup(vc_restore)]).

test(unused_with_zero_percent, [setup(vc_fixture)]) :-
    valid_delete_category(extra).

test(a_percent_different_from_zero_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_delete_category(ahorro).

test(used_by_an_expense, [fail, setup((vc_fixture, vc_expense_with_extra))]) :-
    valid_delete_category(extra).

test(used_by_a_text_rule, [fail, setup((vc_fixture, vc_text_rule_with_extra))]) :-
    valid_delete_category(extra).

test(used_by_a_context_exception, [fail, setup((vc_fixture, vc_exception_with_extra))]) :-
    valid_delete_category(extra).

test(used_by_a_general_description, [fail, setup((vc_fixture, vc_general_with_extra))]) :-
    valid_delete_category(extra).

test(a_category_that_does_not_exist, [fail, setup(vc_fixture)]) :-
    valid_delete_category(viajes).

test(unbound_name_is_not_valid_for_a_used_category, [setup(vc_fixture)]) :-
    % con el nombre sin valor solo puede salir una categoria con 0 % y sin uso
    forall(valid_delete_category(C), ( categories(C, _, P), P =:= 0 )).

test(is_deterministic, [setup(vc_fixture)]) :-
    findall(x, valid_delete_category(extra), L),
    L == [x].

:- end_tests(valid_delete_category).

%-----------------------------------------------------------------------------------------
% valid_change_percent/1
%-----------------------------------------------------------------------------------------
:- begin_tests(valid_change_percent, [setup(vc_backup), cleanup(vc_restore)]).

test(two_categories_that_keep_the_total, [setup(vc_fixture)]) :-
    valid_change_percent([necesidad-60, deseo-20]).

test(three_categories, [setup(vc_fixture)]) :-
    valid_change_percent([necesidad-40, deseo-30, extra-10]).

test(decimals_are_allowed, [setup(vc_fixture)]) :-
    valid_change_percent([necesidad-49.5, deseo-30.5]).

test(float_rounding_is_tolerated, [setup(vc_fixture)]) :-
    valid_change_percent([necesidad-49.9, deseo-30.1]).

test(the_percent_zero_is_allowed, [setup(vc_fixture)]) :-
    valid_change_percent([ahorro-0, necesidad-70]).

test(the_categories_not_in_the_list_count_for_the_total, [fail, setup(vc_fixture)]) :-
    valid_change_percent([necesidad-60, extra-0]).

test(a_total_over_100_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_change_percent([necesidad-60, deseo-40]).

test(a_total_under_100_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_change_percent([necesidad-40, deseo-20]).

test(one_category_is_not_enough, [fail, setup(vc_fixture)]) :-
    valid_change_percent([necesidad-50]).

test(an_empty_list_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_change_percent([]).

test(a_repeated_category_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_change_percent([necesidad-60, necesidad-20]).

test(an_unknown_category_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_change_percent([necesidad-60, viajes-20]).

test(a_negative_percent_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_change_percent([necesidad-110, deseo- -30]).

test(a_non_numeric_percent_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_change_percent([necesidad-sesenta, deseo-20]).

test(the_name_must_be_an_atom, [fail, setup(vc_fixture)]) :-
    valid_change_percent(["necesidad"-60, deseo-20]).

test(a_list_of_non_pairs_is_not_valid, [fail, setup(vc_fixture)]) :-
    valid_change_percent([necesidad, deseo]).

test(does_not_change_any_data, [setup(vc_fixture)]) :-
    pf_facts(categories/3, C0),
    valid_change_percent([necesidad-60, deseo-20]),
    pf_facts(categories/3, C1),
    C0 == C1.

:- end_tests(valid_change_percent).

%-----------------------------------------------------------------------------------------
% valid_list_changes/2: devuelve cuanto cambia cada categoria
%-----------------------------------------------------------------------------------------
:- begin_tests(valid_list_changes, [setup(vc_backup), cleanup(vc_restore)]).

test(empty_list, [setup(vc_fixture)]) :-
    valid_list_changes([], D),
    D == [].

test(differences_with_sign, [setup(vc_fixture)]) :-
    valid_list_changes([necesidad-60, deseo-20, extra-0], D),
    D == [10, -10, 0].

test(no_change_gives_zero, [setup(vc_fixture)]) :-
    valid_list_changes([necesidad-50], D),
    D == [0].

test(decimals, [setup(vc_fixture)]) :-
    valid_list_changes([necesidad-50.5], D),
    D == [0.5].

test(an_unknown_category_fails, [fail, setup(vc_fixture)]) :-
    valid_list_changes([viajes-10], _).

test(a_negative_percent_fails, [fail, setup(vc_fixture)]) :-
    valid_list_changes([necesidad- -1], _).

test(a_non_numeric_percent_fails, [fail, setup(vc_fixture)]) :-
    valid_list_changes([necesidad-mucho], _).

test(a_non_atom_name_fails, [fail, setup(vc_fixture)]) :-
    valid_list_changes(["necesidad"-60], _).

test(one_bad_item_makes_everything_fail, [fail, setup(vc_fixture)]) :-
    valid_list_changes([necesidad-60, viajes-20], _).

:- end_tests(valid_list_changes).
