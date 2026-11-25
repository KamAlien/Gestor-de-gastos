:- encoding(utf8).
%=========================================================================================
% TESTS DE persistence_categories.pl
%=========================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../helpers_persistence').
:- ensure_loaded('../../../prolog/operations/persistence/persistence_categories').

% datos de prueba (fuera de los tests)
cat_sample([categories(necesidad, S, 50),
    categories(deseo, "Ocio", 30),
    categories(ahorro, "Ahorro", 20)]) :- pf_special(S).
cat_old([categories(deseo, "Otra", 100)]).

:- begin_tests(persistence_categories, [setup(pf_setup([categories/3])), cleanup(pf_cleanup([categories/3]))]).

test(round_trip) :-
    cat_sample(Samples),
    pf_round_trip(save_categories, load_categories, categories/3, Samples).

test(file_has_one_clause_per_fact) :-
    cat_sample(Samples),
    pf_file_content(save_categories, categories/3, Samples).

test(load_replaces_memory) :-
    cat_old(Old), cat_sample(New),
    pf_load_replaces(load_categories, categories/3, Old, New).

test(missing_file_keeps_memory) :-
    cat_sample(Samples),
    pf_missing_file_keeps(load_categories, categories/3, Samples).

test(ignores_other_terms) :-
    cat_sample(Samples),
    pf_ignores_other_terms(load_categories, categories/3, Samples).

test(broken_file_keeps_memory) :-
    cat_sample(Samples),
    pf_broken_file_keeps(load_categories, categories/3, Samples).

test(empty_memory_gives_empty_file) :-
    cat_sample(Samples),
    pf_empty_memory(save_categories, load_categories, categories/3, Samples).

test(creates_missing_directory) :-
    cat_sample(Samples),
    pf_creates_directory(save_categories, categories/3, Samples).

test(written_as_utf8) :-
    cat_sample(Samples),
    pf_written_as_utf8(save_categories, categories/3, Samples).

test(default_file_round_trip) :-
    cat_sample(Samples),
    pf_default_file(categories_file, save_categories, load_categories, categories/3, Samples).

:- end_tests(persistence_categories).
