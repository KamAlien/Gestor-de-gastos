:- encoding(utf8).
%=========================================================================================
% TESTS FOR prolog/confing/auto_classification/classification.pl (the default data must be coherent)
%=========================================================================================
:- ensure_loaded('../../helpers_classification').
:- ensure_loaded('../../../prolog/rules/operations/classification').

:- begin_tests(confing_auto_classification).

test(there_is_data_of_each_kind, [nondet]) :-
    context_exception(_, _, _), text_rule(_, _), general_description_category(_, _).
test(only_one_default_category, true(N == 1)) :- cl_count(default_category(_), N).
test(default_category_is_pendiente) :- default_category(pendiente).
test(valid_categories_in_exceptions) :-
    \+ ( context_exception(_, _, C), \+ memberchk(C, [necesidad, deseo]) ).
test(valid_categories_in_text_rules) :-
    \+ ( text_rule(_, C), \+ memberchk(C, [necesidad, deseo]) ).
test(valid_categories_in_generals) :-
    \+ ( general_description_category(_, C), \+ memberchk(C, [necesidad, deseo]) ).
test(everything_is_a_string) :-
    \+ ( context_exception(G, H, _), \+ ( string(G), string(H) ) ),
    \+ ( text_rule(H, _), \+ string(H) ),
    \+ ( general_description_category(G, _), \+ string(G) ).
test(no_empty_texts) :-
    \+ ( ( context_exception(G, H, _), ( G == "" ; H == "" )
         ; text_rule(H, _), H == ""
         ; general_description_category(G, _), G == "" ) ).
test(hints_already_normalized) :-
    \+ ( ( text_rule(H, _) ; context_exception(_, H, _) ), normalize_text(H, N), N \== H ).
test(general_descriptions_already_normalized) :-
    \+ ( ( general_description_category(G, _) ; context_exception(G, _, _) ), normalize_text(G, N), N \== G ).
test(hints_are_one_word) :-
    \+ ( ( text_rule(H, _) ; context_exception(_, H, _) ), words_of(H, Ws), Ws \= [_] ).
test(hint_without_two_categories) :-
    \+ ( text_rule(H, C1), text_rule(H, C2), C1 \== C2 ).
test(general_without_two_categories) :-
    \+ ( general_description_category(G, C1), general_description_category(G, C2), C1 \== C2 ).
test(no_repeated_rules) :-
    findall(H-C, text_rule(H, C), L), sort(L, S), length(L, N), length(S, N).
test(exceptions_belong_to_an_existing_general) :-
    \+ ( context_exception(G, _, _), \+ general_description_category(G, _) ).

:- end_tests(confing_auto_classification).