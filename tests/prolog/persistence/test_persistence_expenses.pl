:- encoding(utf8).
%=========================================================================================
% TESTS DE persistence_expenses.pl
%=========================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../helpers_persistence').
:- ensure_loaded('../../../../prolog/operations/persistence/persistence_expenses').

% datos de prueba (fuera de los tests)
exp_sample([expenses(2026, 1, 5, S, 100, necesidad, "alquiler"),
    expenses(2026, 2, 6, "Cine", 50, deseo, "salidas")]) :- pf_special(S).
exp_old([expenses(2025, 12, 31, "Viejo", 1, deseo, "x")]).

:- begin_tests(persistence_expenses, [setup(pf_setup([expenses/7])), cleanup(pf_cleanup([expenses/7]))]).

test(round_trip) :-
    exp_sample(Samples),
    pf_round_trip(save_expenses, load_expenses, expenses/7, Samples).

test(file_has_one_clause_per_fact) :-
    exp_sample(Samples),
    pf_file_content(save_expenses, expenses/7, Samples).

test(load_replaces_memory) :-
    exp_old(Old), exp_sample(New),
    pf_load_replaces(load_expenses, expenses/7, Old, New).

test(missing_file_keeps_memory) :-
    exp_sample(Samples),
    pf_missing_file_keeps(load_expenses, expenses/7, Samples).

test(ignores_other_terms) :-
    exp_sample(Samples),
    pf_ignores_other_terms(load_expenses, expenses/7, Samples).

test(broken_file_keeps_memory) :-
    exp_sample(Samples),
    pf_broken_file_keeps(load_expenses, expenses/7, Samples).

test(empty_memory_gives_empty_file) :-
    exp_sample(Samples),
    pf_empty_memory(save_expenses, load_expenses, expenses/7, Samples).

test(creates_missing_directory) :-
    exp_sample(Samples),
    pf_creates_directory(save_expenses, expenses/7, Samples).

test(written_as_utf8) :-
    exp_sample(Samples),
    pf_written_as_utf8(save_expenses, expenses/7, Samples).

test(default_file_round_trip) :-
    exp_sample(Samples),
    pf_default_file(expenses_file, save_expenses, load_expenses, expenses/7, Samples).

:- end_tests(persistence_expenses).
