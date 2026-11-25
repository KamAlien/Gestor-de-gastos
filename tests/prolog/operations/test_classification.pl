:- encoding(utf8).
%=========================================================================================
% TESTS FOR prolog/operations/classification.pl
% classify_expense/3 (con datos conocidos y con tus datos por defecto) y rename_category_in_rules/2
% Reemplaza al test_classification.pl anterior (ya incluye lo de renombrar).
%=========================================================================================
:- ensure_loaded('../../helpers_persistence').
:- ensure_loaded('../../helpers_classification').
:- ensure_loaded('../../../prolog/operations/classification').

:- begin_tests(operations_classification, [setup(cl_backup), cleanup(cl_restore)]).

% ---- 1) context exceptions ----
test(exception_beats_general, [setup(cl_fixture), true(C == deseo)]) :-
    classify_expense("Cirugia estetica", "hospital", C).
test(exception_ignores_accents_and_case, [setup(cl_fixture), true(C == deseo)]) :-
    classify_expense("Cirugía Estética", "Hospital", C).
test(no_exception_general_decides, [setup(cl_fixture), true(C == necesidad)]) :-
    classify_expense("Cirugia de apendice", "hospital", C).
test(other_exception, [setup(cl_fixture), true(C == necesidad)]) :-
    classify_expense("Urgencias de madrugada", "hospital", C).
test(exception_only_in_its_context, [setup(cl_fixture), true(C == pendiente)]) :-
    classify_expense("Cirugia estetica", "otros", C).
test(contradictory_exceptions, [setup(cl_fixture), true(C == pendiente)]) :-
    classify_expense("Urgencia estetica", "hospital", C).

% ---- 2) hints in the text ----
test(hint_in_the_text, [setup(cl_fixture), true(C == necesidad)]) :-
    classify_expense("Pan y leche", "otros", C).
test(hint_not_inside_another_word, [setup(cl_fixture), true(C == pendiente)]) :-
    classify_expense("Pantalon nuevo", "otros", C).
test(hint_in_plural, [setup(cl_fixture), true(C == deseo)]) :-
    classify_expense("Zapatos nuevos", "otros", C).
test(same_hint_twice, [setup(cl_fixture), true(C == deseo)]) :-
    classify_expense("pizza pizza", "otros", C).
test(text_beats_general, [setup(cl_fixture), true(C == necesidad)]) :-
    classify_expense("Pan", "salidas", C).
test(contradictory_hints_without_general, [setup(cl_fixture), true(C == pendiente)]) :-
    classify_expense("Pizza con comida", "otros", C).
test(contradictory_hints_general_decides, [setup(cl_fixture), true(C == deseo)]) :-
    classify_expense("Pizza con comida", "salidas", C).

% ---- 3) general description ----
test(only_general, [setup(cl_fixture), true(C == deseo)]) :-
    classify_expense("Algo cualquiera", "compras", C).
test(general_uppercase, [setup(cl_fixture), true(C == deseo)]) :-
    classify_expense("Algo cualquiera", "COMPRAS", C).
test(general_extra_spaces, [setup(cl_fixture), true(C == necesidad)]) :-
    classify_expense("Algo cualquiera", "  Super   Mercado ", C).

% ---- 4) default category ----
test(nothing_known, [setup(cl_fixture), true(C == pendiente)]) :-
    classify_expense("Algo raro", "otros", C).
test(empty_description, [setup(cl_fixture), true(C == pendiente)]) :-
    classify_expense("", "", C).
test(configurable_default, [setup((cl_fixture, cl_set_default(deseo))), true(C == deseo)]) :-
    classify_expense("Algo raro", "otros", C).
test(no_rules_at_all, [setup(cl_clear), fail]) :-
    classify_expense("Pan", "hospital", _).

% ---- rules added by the user ----
test(new_text_rule, [setup((cl_fixture, cl_add_text_rule("gimnasio", deseo))), true(C == deseo)]) :-
    classify_expense("Gimnasio del mes", "otros", C).
test(new_exception, [setup((cl_fixture, cl_add_exception("compras", "colchon", necesidad))), true(C == necesidad)]) :-
    classify_expense("Colchon nuevo", "compras", C).

% ---- always one answer and it does not change the data ----
test(single_answer, [setup(cl_fixture), true(L == [necesidad])]) :-
    findall(C, classify_expense("Pan y comida", "hospital", C), L).
test(does_not_change_the_data, [setup(cl_fixture), true(Before == After)]) :-
    cl_count(text_rule(_, _), Before),
    classify_expense("Pan y leche", "otros", _),
    cl_count(text_rule(_, _), After).

% ---- categories_by_exception/3, categories_by_text/2, categories_by_general/2 ----
test(by_exception_one, [setup(cl_fixture), true(L == [deseo])]) :-
    categories_by_exception("hospital", ["estetica"], L).
test(by_exception_none, [setup(cl_fixture), true(L == [])]) :-
    categories_by_exception("compras", ["estetica"], L).
test(by_exception_two, [setup(cl_fixture), true(L == [deseo, necesidad])]) :-
    categories_by_exception("hospital", ["estetica", "urgencia"], L).
test(by_text_without_repeated, [setup(cl_fixture), true(L == [deseo])]) :-
    categories_by_text(["pizza", "cine"], L).
test(by_text_two, [setup(cl_fixture), true(L == [deseo, necesidad])]) :-
    categories_by_text(["pan", "cine"], L).
test(by_text_none, [setup(cl_fixture), true(L == [])]) :-
    categories_by_text(["xyz"], L).
test(by_general_one, [setup(cl_fixture), true(L == [deseo])]) :-
    categories_by_general("salidas", L).
test(by_general_none, [setup(cl_fixture), true(L == [])]) :-
    categories_by_general("otros", L).

% ---- decide/4 ----
test(decide_exception, [true(C == deseo)]) :- decide([deseo], [necesidad], [necesidad], C).
test(decide_contradictory_exceptions, [setup(cl_fixture), true(C == pendiente)]) :-
    decide([deseo, necesidad], [], [], C).
test(decide_one_text, [true(C == deseo)]) :- decide([], [deseo], [necesidad], C).
test(decide_contradictory_texts_with_general, [true(C == necesidad)]) :-
    decide([], [deseo, necesidad], [necesidad], C).
test(decide_contradictory_texts_without_general, [setup(cl_fixture), true(C == pendiente)]) :-
    decide([], [deseo, necesidad], [], C).
test(decide_only_general, [true(C == deseo)]) :- decide([], [], [deseo], C).
test(decide_nothing, [setup(cl_fixture), true(C == pendiente)]) :- decide([], [], [], C).

% ---- fallback_category/1 ----
test(fallback_is_pendiente, [setup(cl_fixture), true(C == pendiente)]) :- fallback_category(C).
test(fallback_changed, [setup((cl_fixture, cl_set_default(deseo))), true(C == deseo)]) :- fallback_category(C).

:- end_tests(operations_classification).

%=========================================================================================
% WITH THE DEFAULT DATA OF prolog/confing/auto_classification/classification.pl (nothing is cleared)
%=========================================================================================
:- begin_tests(operations_classification_default_data, [setup(cl_backup), cleanup(cl_restore)]).

test(aesthetic_surgery, true(C == deseo)) :- classify_expense("Cirugía estética", "hospital", C).
test(necessary_surgery, true(C == necesidad)) :- classify_expense("Cirugía de apéndice", "hospital", C).
test(botox, true(C == deseo)) :- classify_expense("Botox", "hospital", C).
test(pain_in_the_hospital, true(C == necesidad)) :- classify_expense("Consulta por dolor", "hospital", C).
test(trousers_are_not_bread, true(C == deseo)) :- classify_expense("Pantalón nuevo", "compras", C).
test(barber_is_not_bar, true(C == necesidad)) :- classify_expense("Barbero", "servicios", C).
test(gasto_is_not_gas, true(C == pendiente)) :- classify_expense("Gasto raro", "otros", C).
test(pizza_in_outings, true(C == deseo)) :- classify_expense("Pizza con amigos", "salidas", C).
test(taxi, true(C == necesidad)) :- classify_expense("Taxi al trabajo", "transporte", C).
test(guagua, true(C == necesidad)) :- classify_expense("Guagua", "otros", C).
test(food_at_a_restaurant, true(C == deseo)) :- classify_expense("Comida en el restaurante", "restaurante", C).
test(unknown, true(C == pendiente)) :- classify_expense("Cosa rara", "otros", C).

:- end_tests(operations_classification_default_data).

%=========================================================================================
% rename_category_in_rules/2
%=========================================================================================
rr_hints(Name/Arity, Hints) :-
    functor(Head, Name, Arity),
    findall(First, ( Head, arg(1, Head, First) ), List),
    msort(List, Hints).

:- begin_tests(rename_category_in_rules, [setup(cl_backup), cleanup(cl_restore)]).

test(renames_the_text_rules, [setup(cl_fixture)]) :-
    rename_category_in_rules(deseo, capricho),
    pf_facts(text_rule/2, L), msort(L, S),
    S == [ text_rule("cine", capricho), text_rule("comida", necesidad), text_rule("pan", necesidad),
           text_rule("pizza", capricho), text_rule("zapato", capricho) ].

test(renames_the_context_exceptions, [setup(cl_fixture)]) :-
    rename_category_in_rules(deseo, capricho),
    pf_facts(context_exception/3, L), msort(L, S),
    S == [ context_exception("hospital", "estetica", capricho),
           context_exception("hospital", "urgencia", necesidad) ].

test(renames_the_general_descriptions, [setup(cl_fixture)]) :-
    rename_category_in_rules(deseo, capricho),
    pf_facts(general_description_category/2, L), msort(L, S),
    S == [ general_description_category("compras", capricho),
           general_description_category("hospital", necesidad),
           general_description_category("salidas", capricho),
           general_description_category("super mercado", necesidad) ].

test(the_old_name_disappears, [setup(cl_fixture)]) :-
    rename_category_in_rules(deseo, capricho),
    \+ text_rule(_, deseo),
    \+ context_exception(_, _, deseo),
    \+ general_description_category(_, deseo).

test(keeps_the_number_of_rules_and_the_hints, [setup(cl_fixture)]) :-
    rr_hints(text_rule/2, T0), rr_hints(context_exception/3, C0), rr_hints(general_description_category/2, G0),
    rename_category_in_rules(necesidad, basico),
    rr_hints(text_rule/2, T1), rr_hints(context_exception/3, C1), rr_hints(general_description_category/2, G1),
    T0 == T1, C0 == C1, G0 == G1.

test(other_categories_stay_the_same, [setup(cl_fixture)]) :-
    rename_category_in_rules(necesidad, basico),
    once(text_rule("cine", deseo)),
    once(context_exception("hospital", "estetica", deseo)),
    once(general_description_category("salidas", deseo)).

test(default_category_is_not_touched, [setup(cl_fixture)]) :-
    rename_category_in_rules(deseo, capricho),
    pf_facts(default_category/1, L),
    L == [default_category(pendiente)].

test(a_category_without_rules_changes_nothing, [setup(cl_fixture)]) :-
    pf_facts(text_rule/2, T0), pf_facts(context_exception/3, C0),
    rename_category_in_rules(viajes, otro),
    pf_facts(text_rule/2, T1), pf_facts(context_exception/3, C1),
    T0 == T1, C0 == C1.

test(the_classifier_uses_the_new_name, [setup(cl_fixture), nondet]) :-
    rename_category_in_rules(deseo, capricho),
    classify_expense("Cine con amigos", "otros", Category),
    Category == capricho.

test(is_deterministic, [setup(cl_fixture)]) :-
    findall(x, rename_category_in_rules(deseo, capricho), L),
    L == [x].

test(fails_if_old_and_new_are_equal, [fail, setup(cl_fixture)]) :-
    rename_category_in_rules(deseo, deseo).

test(fails_with_an_unbound_old_name, [fail, setup(cl_fixture)]) :-
    rename_category_in_rules(_, capricho).

test(fails_with_an_unbound_new_name, [fail, setup(cl_fixture)]) :-
    rename_category_in_rules(deseo, _).

test(failing_does_not_change_the_rules, [setup(cl_fixture)]) :-
    pf_facts(text_rule/2, T0),
    \+ rename_category_in_rules(_, capricho),
    pf_facts(text_rule/2, T1),
    T0 == T1.

:- end_tests(rename_category_in_rules).
