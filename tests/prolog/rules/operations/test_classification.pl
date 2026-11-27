:- encoding(utf8).
%=========================================================================================
% TESTS FOR prolog/rules/operations/classification.pl
%=========================================================================================
:- ensure_loaded('../../../../prolog/rules/operations/classification').

:- begin_tests(rules_operations_classification).

% ---- remove_accent/2 ----
test(accent_vowel, true(S == a)) :- remove_accent('á', S).
test(accent_enie, true(S == n)) :- remove_accent('ñ', S).
test(accent_dieresis, true(S == u)) :- remove_accent('ü', S).
test(accent_normal_letter, true(S == b)) :- remove_accent(b, S).
test(accent_symbol, true(S == '!')) :- remove_accent('!', S).

% ---- remove_accents/2 ----
test(remove_accents_text, true(L == "cirugia estetica")) :- remove_accents("Cirugía Estética", L).
test(remove_accents_uppercase, true(L == "telefono")) :- remove_accents("TELÉFONO", L).
test(remove_accents_empty, true(L == "")) :- remove_accents("", L).
test(remove_accents_enie, true(L == "ano")) :- remove_accents("Año", L).

% ---- normalize_text/2 ----
test(normalize_spaces, true(N == "super mercado")) :- normalize_text("  Súper   Mercado ", N).
test(normalize_already_normal, true(N == "hospital")) :- normalize_text("hospital", N).

% ---- words_of/2 ----
test(words_by_spaces, true(W == ["pan", "y", "leche"])) :- words_of("Pan y leche", W).
test(words_with_punctuation, true(W == ["compre", "zapatos", "camisa"])) :- words_of("Compré zapatos, camisa.", W).
test(words_repeated_spaces, true(W == ["a", "b"])) :- words_of("  a    b  ", W).
test(words_hyphen_and_slash, true(W == ["auto", "bus", "ida", "vuelta"])) :- words_of("auto-bus ida/vuelta", W).
test(words_empty, true(W == [])) :- words_of("", W).
test(words_only_punctuation, true(W == [])) :- words_of(" ,.;: ", W).

% ---- hint_in_words/2 ----
test(hint_exact_word) :- hint_in_words("pan", ["pan", "y", "leche"]).
test(hint_not_inside_another_word, [fail]) :- hint_in_words("pan", ["pantalon", "nuevo"]).
test(hint_bar_in_barbero, [fail]) :- hint_in_words("bar", ["barbero"]).
test(hint_gas_in_gasto, [fail]) :- hint_in_words("gas", ["gasto", "raro"]).
test(hint_plural_s) :- hint_in_words("zapato", ["zapatos"]).
test(hint_plural_es) :- hint_in_words("doctor", ["doctores"]).
test(hint_with_accents_and_uppercase) :- hint_in_words("Teléfono", ["telefono"]).
test(hint_not_found, [fail]) :- hint_in_words("cine", ["pan", "leche"]).
test(hint_empty_list, [fail]) :- hint_in_words("pan", []).
test(hint_empty_hint, [fail]) :- hint_in_words("", ["", "a"]).
test(hint_stem_does_not_count, [fail]) :- hint_in_words("estetic", ["estetica"]).
test(hint_is_deterministic) :- hint_in_words("pan", ["pan", "pan"]).

% ---- word_matches/2 ----
test(matches_equal, [nondet]) :- word_matches("pan", "pan").
test(matches_plural, [nondet]) :- word_matches("pan", "panes").
test(matches_different, [fail]) :- word_matches("pan", "pantalon").

:- end_tests(rules_operations_classification).