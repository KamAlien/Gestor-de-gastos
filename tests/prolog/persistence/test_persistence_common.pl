:- encoding(utf8).
%=========================================================================================
% TESTS DE persistence_common.pl
%=========================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../helpers_persistence').
:- ensure_loaded('../../../../prolog/operations/persistence/persistence_common').

% lee un texto con read_terms y devuelve la lista
pc_terms_of(Text, Terms) :-
    pf_tmp(File),
    pf_write_text(File, Text),
    pf_read_facts(File, Terms),
    pf_delete(File).

:- begin_tests(persistence_common_read_terms).

test(empty_file) :-
    pc_terms_of("", Terms),
    Terms == [].

test(one_term) :-
    pc_terms_of("a(1).\n", Terms),
    Terms == [a(1)].

test(keeps_order) :-
    pc_terms_of("a(1).\nb(2).\nc(3).\n", Terms),
    Terms == [a(1), b(2), c(3)].

test(strings_and_atoms) :-
    pc_terms_of("f(\"texto\", atomo, 3).\n", Terms),
    Terms == [f("texto", atomo, 3)].

test(syntax_error_is_an_error, [throws(error(syntax_error(_), _))]) :-
    pc_terms_of("a( .\n", _).

:- end_tests(persistence_common_read_terms).

:- begin_tests(persistence_common_parent_directory).

test(creates_nested_directories) :-
    tmp_file(pc_dir, Dir),
    directory_file_path(Dir, 'uno/dos/file.pl', File),
    \+ exists_directory(Dir),
    ensure_parent_directory(File),
    directory_file_path(Dir, 'uno/dos', Parent),
    exists_directory(Parent),
    delete_directory_and_contents(Dir).

test(existing_directory_is_fine) :-
    tmp_file(pc_dir, Dir),
    make_directory(Dir),
    directory_file_path(Dir, 'file.pl', File),
    ensure_parent_directory(File),
    ensure_parent_directory(File),
    exists_directory(Dir),
    delete_directory_and_contents(Dir).

test(file_without_directory) :-
    ensure_parent_directory('file_in_current_directory.pl').

test(deterministic) :-
    tmp_file(pc_dir, Dir),
    directory_file_path(Dir, 'x/file.pl', File),
    findall(x, ensure_parent_directory(File), L),
    L == [x],
    delete_directory_and_contents(Dir).

:- end_tests(persistence_common_parent_directory).
