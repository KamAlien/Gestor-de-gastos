:- encoding(utf8).
%=========================================================================================
% TESTS DE persistence_incomes.pl
%=========================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../helpers_persistence').
:- ensure_loaded('../../../../prolog/operations/persistence/persistence_incomes').

% datos de prueba (fuera de los tests)
inc_sample([incomes(2026, 1, 5, S, 1000, salario),
    incomes(2026, 2, 6, "Venta", 50, ingreso_extra)]) :- pf_special(S).
inc_old([incomes(2025, 12, 31, "Viejo", 1, salario)]).

:- begin_tests(persistence_incomes, [setup(pf_setup([incomes/6])), cleanup(pf_cleanup([incomes/6]))]).

test(round_trip) :-
    inc_sample(Samples),
    pf_round_trip(save_incomes, load_incomes, incomes/6, Samples).

test(file_has_one_clause_per_fact) :-
    inc_sample(Samples),
    pf_file_content(save_incomes, incomes/6, Samples).

test(load_replaces_memory) :-
    inc_old(Old), inc_sample(New),
    pf_load_replaces(load_incomes, incomes/6, Old, New).

test(missing_file_keeps_memory) :-
    inc_sample(Samples),
    pf_missing_file_keeps(load_incomes, incomes/6, Samples).

test(ignores_other_terms) :-
    inc_sample(Samples),
    pf_ignores_other_terms(load_incomes, incomes/6, Samples).

test(broken_file_keeps_memory) :-
    inc_sample(Samples),
    pf_broken_file_keeps(load_incomes, incomes/6, Samples).

test(empty_memory_gives_empty_file) :-
    inc_sample(Samples),
    pf_empty_memory(save_incomes, load_incomes, incomes/6, Samples).

test(creates_missing_directory) :-
    inc_sample(Samples),
    pf_creates_directory(save_incomes, incomes/6, Samples).

test(written_as_utf8) :-
    inc_sample(Samples),
    pf_written_as_utf8(save_incomes, incomes/6, Samples).

test(default_file_round_trip) :-
    inc_sample(Samples),
    pf_default_file(incomes_file, save_incomes, load_incomes, incomes/6, Samples).

:- end_tests(persistence_incomes).
