:- encoding(utf8).
%=========================================================================================
% TESTS DE prolog/operations/categories.pl
% create_category/2, update_category/3, delete_category/1, change_percents/1 y set_percent/2
% (usan tu rules/valid_category.pl de verdad). Reemplaza al test_categories.pl anterior.
%=========================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../helpers_persistence').
:- ensure_loaded('../../helpers_classification').
:- ensure_loaded('../../../prolog/operations/categories').
:- isolate_data_files.     % por seguridad: estos tests nunca escriben en data/

%-----------------------------------------------------------------------------------------
% Helpers (fuera de los tests)
%   up_backup / up_restore : UNA vez por unidad (guardan y devuelven tus datos reales)
%   up_fixture             : antes de CADA test (deja los datos conocidos de abajo)
%-----------------------------------------------------------------------------------------
up_specs([categories/3, expenses/7]).

up_backup :- up_specs(Specs), cl_backup, pf_setup(Specs).
up_restore :- up_specs(Specs), pf_cleanup(Specs), cl_restore.

up_fixture :-
    up_specs(Specs),
    pf_clear(Specs),
    pf_assert_all([ categories(necesidad, "Necesidades", 50),
                    categories(deseo, "Deseos", 30),
                    categories(ahorro, "Ahorro", 20),
                    categories(extra, "Extra", 0),
                    expenses(2026, 3, 1, "Renta", 1000, necesidad, "alquiler"),
                    expenses(2026, 3, 3, "Cine", 50, deseo, "salidas"),
                    expenses(2026, 3, 5, "Pan", 10, necesidad, "otros"),
                    expenses(2026, 3, 9, "Cena", 80, deseo, "salidas") ]),
    cl_clear,
    cl_add_text_rule("cine", deseo),
    cl_add_text_rule("pan", necesidad),
    cl_add_exception("hospital", "urgencia", necesidad),
    cl_add_exception("hospital", "estetica", deseo),
    cl_add_general("salidas", deseo),
    cl_add_general("alquiler", necesidad),
    up_mark_files.

% variantes del escenario
up_expense_with_extra :- pf_assert_all([expenses(2026, 3, 20, "Algo", 5, extra, "otros")]).
up_text_rule_with_extra :- cl_add_text_rule("viaje", extra).
up_exception_with_extra :- cl_add_exception("hospital", "dolor", extra).
up_general_with_extra :- cl_add_general("viajes", extra).
up_ahorro_at_zero :-
    retractall(categories(necesidad, _, _)), retractall(categories(ahorro, _, _)),
    assertz(categories(necesidad, "Necesidades", 70)),
    assertz(categories(ahorro, "Ahorro", 0)).

% deja un contenido conocido en el archivo para saber si alguien lo reescribio
up_mark_files :-
    categories_file(C), pf_write_facts(C, [marker(categories)]),
    expenses_file(E), pf_write_facts(E, [marker(expenses)]).

up_files_untouched :-
    categories_file(C), pf_read_facts(C, [marker(categories)]),
    expenses_file(E), pf_read_facts(E, [marker(expenses)]).

up_saved_categories(Terms) :- categories_file(F), pf_read_facts(F, Terms).
up_saved_expenses(Terms)   :- expenses_file(F), pf_read_facts(F, Terms).

up_snapshot(snap(Cats, Exps, Texts, Contexts, Generals)) :-
    pf_facts(categories/3, Cats),
    pf_facts(expenses/7, Exps),
    pf_facts(text_rule/2, Texts),
    pf_facts(context_exception/3, Contexts),
    pf_facts(general_description_category/2, Generals).

% la operacion debe FALLAR sin cambiar nada en memoria ni en los archivos
up_fails_without_changes(Goal) :-
    up_snapshot(Before),
    \+ call(Goal),
    up_snapshot(After),
    Before == After,
    up_files_untouched.

%-----------------------------------------------------------------------------------------
% create_category/2
%-----------------------------------------------------------------------------------------
:- begin_tests(create_category, [setup(up_backup), cleanup(up_restore)]).

test(creates_with_percent_zero, [setup(up_fixture)]) :-
    create_category(viajes, "Para viajar"),
    once(categories(viajes, "Para viajar", 0)),
    pf_facts(categories/3, L), length(L, 5).

test(saves_the_categories_file, [setup(up_fixture)]) :-
    create_category(viajes, "Para viajar"),
    up_saved_categories(Terms),
    pf_facts(categories/3, Terms0),
    Terms == Terms0,
    once(memberchk(categories(viajes, "Para viajar", 0), Terms)).

test(does_not_touch_the_expenses_file, [setup(up_fixture)]) :-
    create_category(viajes, "Para viajar"),
    expenses_file(E), pf_read_facts(E, [marker(expenses)]).

test(is_deterministic, [setup(up_fixture)]) :-
    findall(x, create_category(viajes, "Para viajar"), L),
    L == [x].

test(fails_if_it_already_exists, [setup(up_fixture)]) :-
    up_fails_without_changes(create_category(deseo, "Otra")).

test(fails_for_pendiente, [setup(up_fixture)]) :-
    up_fails_without_changes(create_category(pendiente, "No vale")).

test(fails_with_an_empty_name, [setup(up_fixture)]) :-
    up_fails_without_changes(create_category('', "Descripcion")).

test(fails_with_an_empty_description, [setup(up_fixture)]) :-
    up_fails_without_changes(create_category(viajes, "")).

test(fails_if_the_name_is_not_an_atom, [setup(up_fixture)]) :-
    up_fails_without_changes(create_category("viajes", "Descripcion")).

test(fails_with_unbound_arguments, [setup(up_fixture)]) :-
    up_fails_without_changes(create_category(_, "Descripcion")),
    up_fails_without_changes(create_category(viajes, _)).

test(ahorro_cannot_be_created_twice, [setup(up_fixture)]) :-
    up_fails_without_changes(create_category(ahorro, "Otra vez")).

test(ahorro_can_be_created_again_after_deleting_it, [setup((up_fixture, up_ahorro_at_zero))]) :-
    delete_category(ahorro),
    create_category(ahorro, "De nuevo"),
    once(categories(ahorro, "De nuevo", 0)).

:- end_tests(create_category).

%-----------------------------------------------------------------------------------------
% update_category/3
%-----------------------------------------------------------------------------------------
:- begin_tests(update_category, [setup(up_backup), cleanup(up_restore)]).

test(rename_moves_the_row_with_its_percent, [setup(up_fixture)]) :-
    update_category(deseo, capricho, "Antojos"),
    once(categories(capricho, "Antojos", 30)),
    \+ categories(deseo, _, _),
    pf_facts(categories/3, L), length(L, 4).

test(rename_updates_the_expenses_of_that_category, [setup(up_fixture)]) :-
    update_category(deseo, capricho, "Antojos"),
    pf_facts(expenses/7, L),
    msort(L, Sorted),
    Sorted == [ expenses(2026, 3, 1, "Renta", 1000, necesidad, "alquiler"),
                expenses(2026, 3, 3, "Cine", 50, capricho, "salidas"),
                expenses(2026, 3, 5, "Pan", 10, necesidad, "otros"),
                expenses(2026, 3, 9, "Cena", 80, capricho, "salidas") ].

test(rename_updates_the_three_kinds_of_rules, [setup(up_fixture)]) :-
    update_category(necesidad, basico, "Lo basico"),
    pf_facts(text_rule/2, T), msort(T, TS),
    TS == [text_rule("cine", deseo), text_rule("pan", basico)],
    pf_facts(context_exception/3, C), msort(C, CS),
    CS == [context_exception("hospital", "estetica", deseo), context_exception("hospital", "urgencia", basico)],
    pf_facts(general_description_category/2, G), msort(G, GS),
    GS == [general_description_category("alquiler", basico), general_description_category("salidas", deseo)].

test(rename_does_not_touch_other_categories_rules, [setup(up_fixture)]) :-
    update_category(ahorro, reserva, "Reserva"),
    pf_facts(text_rule/2, T), length(T, 2),
    \+ text_rule(_, reserva).

test(only_description_changes_nothing_else, [setup(up_fixture)]) :-
    up_snapshot(snap(_, Exps, Texts, Contexts, Generals)),
    update_category(deseo, deseo, "Descripcion nueva"),
    once(categories(deseo, "Descripcion nueva", 30)),
    up_snapshot(snap(_, Exps2, Texts2, Contexts2, Generals2)),
    Exps == Exps2, Texts == Texts2, Contexts == Contexts2, Generals == Generals2.

test(rename_and_new_description_at_once, [setup(up_fixture)]) :-
    update_category(deseo, capricho, "Otra descripcion"),
    once(categories(capricho, "Otra descripcion", 30)).

test(a_category_with_percent_zero_keeps_its_zero, [setup(up_fixture)]) :-
    update_category(extra, adicional, "Adicional"),
    once(categories(adicional, "Adicional", 0)).

test(saves_the_categories_file, [setup(up_fixture)]) :-
    update_category(deseo, capricho, "Antojos"),
    up_saved_categories(Terms),
    msort(Terms, S),
    S == [ categories(ahorro, "Ahorro", 20),
           categories(capricho, "Antojos", 30),
           categories(extra, "Extra", 0),
           categories(necesidad, "Necesidades", 50) ].

test(saves_the_expenses_file, [setup(up_fixture)]) :-
    update_category(deseo, capricho, "Antojos"),
    up_saved_expenses(Terms),
    \+ memberchk(expenses(_, _, _, _, _, deseo, _), Terms),
    once(memberchk(expenses(2026, 3, 3, "Cine", 50, capricho, "salidas"), Terms)),
    length(Terms, 4).

test(is_deterministic, [setup(up_fixture)]) :-
    findall(x, update_category(deseo, capricho, "Antojos"), L),
    L == [x].

test(fails_if_the_category_does_not_exist, [setup(up_fixture)]) :-
    up_fails_without_changes(update_category(viajes, otro, "Descripcion")).

test(fails_if_the_new_name_already_exists, [setup(up_fixture)]) :-
    up_fails_without_changes(update_category(deseo, necesidad, "Descripcion")).

test(fails_if_nothing_changes, [setup(up_fixture)]) :-
    up_fails_without_changes(update_category(deseo, deseo, "Deseos")).

test(fails_if_the_new_name_is_pendiente, [setup(up_fixture)]) :-
    up_fails_without_changes(update_category(deseo, pendiente, "Deseos")).

test(fails_if_renaming_to_pendiente_with_new_description, [setup(up_fixture)]) :-
    up_fails_without_changes(update_category(deseo, pendiente, "Otra descripcion")).

test(fails_with_an_empty_description, [setup(up_fixture)]) :-
    up_fails_without_changes(update_category(deseo, capricho, "")).

test(fails_if_the_new_name_is_not_an_atom, [setup(up_fixture)]) :-
    up_fails_without_changes(update_category(deseo, "capricho", "Antojos")).

test(fails_with_an_unbound_old_name, [setup(up_fixture)]) :-
    up_fails_without_changes(update_category(_, capricho, "Antojos")).

test(fails_with_an_unbound_new_name, [setup(up_fixture)]) :-
    up_fails_without_changes(update_category(deseo, _, "Antojos")).

test(fails_with_an_unbound_description, [setup(up_fixture)]) :-
    up_fails_without_changes(update_category(deseo, capricho, _)).

:- end_tests(update_category).

%-----------------------------------------------------------------------------------------
% update_category/3 y valid_update_category/3 tienen que estar de acuerdo:
% si update_category renombra una categoria en uso, la validacion tambien debe aceptarlo.
%-----------------------------------------------------------------------------------------
:- begin_tests(update_category_agrees_with_its_validation, [setup(up_backup), cleanup(up_restore)]).

test(renaming_a_used_category_is_valid, [setup(up_fixture), nondet]) :-
    valid_update_category(deseo, capricho, "Antojos").

test(changing_only_the_description_is_valid, [setup(up_fixture), nondet]) :-
    valid_update_category(deseo, deseo, "Descripcion nueva").

test(renaming_to_an_existing_name_is_not_valid, [fail, setup(up_fixture)]) :-
    valid_update_category(deseo, necesidad, "Descripcion").

:- end_tests(update_category_agrees_with_its_validation).

%-----------------------------------------------------------------------------------------
% delete_category/1 (solo se borra con 0 % y sin usar)
%-----------------------------------------------------------------------------------------
:- begin_tests(delete_category, [setup(up_backup), cleanup(up_restore)]).

test(deletes_an_unused_category_with_zero_percent, [setup(up_fixture)]) :-
    delete_category(extra),
    \+ categories(extra, _, _),
    pf_facts(categories/3, L), length(L, 3).

test(saves_the_categories_file, [setup(up_fixture)]) :-
    delete_category(extra),
    up_saved_categories(Terms),
    pf_facts(categories/3, Terms0),
    Terms == Terms0,
    \+ memberchk(categories(extra, _, _), Terms).

test(is_deterministic, [setup(up_fixture)]) :-
    findall(x, delete_category(extra), L),
    L == [x].

test(a_deleted_name_can_be_created_again, [setup(up_fixture)]) :-
    delete_category(extra),
    create_category(extra, "Otra vez"),
    once(categories(extra, "Otra vez", 0)).

test(fails_if_the_percent_is_not_zero, [setup(up_fixture)]) :-
    up_fails_without_changes(delete_category(ahorro)).

test(fails_if_an_expense_uses_it, [setup((up_fixture, up_expense_with_extra))]) :-
    up_fails_without_changes(delete_category(extra)).

test(fails_if_a_text_rule_uses_it, [setup((up_fixture, up_text_rule_with_extra))]) :-
    up_fails_without_changes(delete_category(extra)).

test(fails_if_a_context_exception_uses_it, [setup((up_fixture, up_exception_with_extra))]) :-
    up_fails_without_changes(delete_category(extra)).

test(fails_if_a_general_description_uses_it, [setup((up_fixture, up_general_with_extra))]) :-
    up_fails_without_changes(delete_category(extra)).

test(fails_if_it_does_not_exist, [setup(up_fixture)]) :-
    up_fails_without_changes(delete_category(viajes)).

test(fails_with_an_unbound_name, [setup(up_fixture)]) :-
    up_fails_without_changes(delete_category(_)).

test(ahorro_can_be_deleted_once_it_has_zero_percent, [setup((up_fixture, up_ahorro_at_zero))]) :-
    delete_category(ahorro),
    \+ categories(ahorro, _, _).

:- end_tests(delete_category).

%-----------------------------------------------------------------------------------------
% change_percents/1 y set_percent/2
%-----------------------------------------------------------------------------------------
:- begin_tests(change_percents, [setup(up_backup), cleanup(up_restore)]).

test(changes_and_saves, [setup(up_fixture)]) :-
    change_percents([necesidad-60, deseo-20]),
    once(categories(necesidad, "Necesidades", 60)),
    once(categories(deseo, "Deseos", 20)),
    once(categories(ahorro, "Ahorro", 20)),
    up_saved_categories(Terms),
    msort(Terms, S),
    S == [ categories(ahorro, "Ahorro", 20),
           categories(deseo, "Deseos", 20),
           categories(extra, "Extra", 0),
           categories(necesidad, "Necesidades", 60) ].

test(keeps_the_descriptions, [setup(up_fixture)]) :-
    change_percents([necesidad-60, deseo-20]),
    once(categories(necesidad, "Necesidades", _)),
    once(categories(deseo, "Deseos", _)).

test(percent_zero_is_allowed, [setup(up_fixture)]) :-
    change_percents([necesidad-70, ahorro-0]),
    once(categories(ahorro, "Ahorro", 0)).

test(after_zero_the_category_can_be_deleted, [setup(up_fixture)]) :-
    change_percents([necesidad-70, ahorro-0]),
    delete_category(ahorro),
    \+ categories(ahorro, _, _).

test(does_not_touch_the_expenses_file, [setup(up_fixture)]) :-
    change_percents([necesidad-60, deseo-20]),
    expenses_file(E), pf_read_facts(E, [marker(expenses)]).

test(fails_with_only_one_category, [setup(up_fixture)]) :-
    up_fails_without_changes(change_percents([necesidad-100])).

test(fails_if_the_total_is_not_100, [setup(up_fixture)]) :-
    up_fails_without_changes(change_percents([necesidad-60, deseo-30])).

test(fails_for_an_unknown_category, [setup(up_fixture)]) :-
    up_fails_without_changes(change_percents([viajes-10, deseo-20])).

test(fails_with_a_repeated_category, [setup(up_fixture)]) :-
    up_fails_without_changes(change_percents([necesidad-60, necesidad-40])).

test(fails_with_a_negative_percent, [setup(up_fixture)]) :-
    up_fails_without_changes(change_percents([necesidad-110, deseo-(-30)])).

test(fails_with_a_non_numeric_percent, [setup(up_fixture)]) :-
    up_fails_without_changes(change_percents([necesidad-60, deseo-abc])).

test(fails_with_an_empty_list, [setup(up_fixture)]) :-
    up_fails_without_changes(change_percents([])).

:- end_tests(change_percents).

:- begin_tests(set_percent, [setup(up_backup), cleanup(up_restore)]).

test(changes_only_the_percent, [setup(up_fixture)]) :-
    set_percent(deseo, 45),
    once(categories(deseo, "Deseos", 45)).

test(does_not_save_by_itself, [setup(up_fixture)]) :-
    set_percent(deseo, 45),
    up_files_untouched.

test(fails_for_an_unknown_category, [setup(up_fixture)]) :-
    up_fails_without_changes(set_percent(viajes, 10)).

:- end_tests(set_percent).
