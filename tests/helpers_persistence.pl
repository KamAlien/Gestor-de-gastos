:- encoding(utf8).
%=========================================================================================
% HELPERS PARA LOS TESTS DE PERSISTENCIA (nombres con prefijo pf_)
% IMPORTANTE: un assertz/retractall escrito DENTRO de un test crea predicados locales al
% test y no toca los datos reales; por eso todo lo que cambia hechos vive aqui.
%=========================================================================================
:- ensure_loaded('../prolog/operations/persistence/persistence_common').
:- ensure_loaded('../prolog/operations/persistence/persistence_categories').
:- ensure_loaded('../prolog/operations/persistence/persistence_expenses').
:- ensure_loaded('../prolog/operations/persistence/persistence_incomes').
%:- ensure_loaded('../prolog/operations/persistence/persistence_savings_accounts').
%:- ensure_loaded('../prolog/operations/persistence/persistence_savings_adjustments').
%:- ensure_loaded('../prolog/operations/persistence/persistence_savings_percents').
%:- ensure_loaded('../prolog/operations/persistence/persistence_transfers').

%-----------------------------------------------------------------------------------------
% 1. AISLAR LOS ARCHIVOS REALES: se llama UNA vez al principio de tests.pl.
%    Desde ahi, save_* y load_* trabajan con archivos temporales y nunca tocan data/.
%-----------------------------------------------------------------------------------------
pf_file_predicates([categories_file, expenses_file, incomes_file, savings_accounts_file,
                    savings_adjustments_file, savings_percents_file, transfers_file]).

isolate_data_files :-
    pf_file_predicates(Names),
    forall(member(Name, Names),
           ( tmp_file(Name, Tmp),
             Old =.. [Name, _],
             retractall(Old),
             New =.. [Name, Tmp],
             assertz(New) )).

%-----------------------------------------------------------------------------------------
% 2. COPIA DE SEGURIDAD DE LOS HECHOS (para setup/cleanup de cada unidad)
%    Specs es una lista Nombre/Aridad, por ejemplo [categories/3, expenses/7]
%-----------------------------------------------------------------------------------------
:- dynamic pf_backup/1.

pf_setup(Specs) :-
    retractall(pf_backup(_)),
    forall(( member(Name/Arity, Specs), functor(Head, Name, Arity), call(Head) ),
           assertz(pf_backup(Head))),
    pf_clear(Specs).

pf_cleanup(Specs) :-
    pf_clear(Specs),
    forall(pf_backup(Head), assertz(Head)),
    retractall(pf_backup(_)).

pf_clear(Specs) :-
    forall(( member(Name/Arity, Specs), functor(Head, Name, Arity) ),
           retractall(Head)).

pf_assert_all(Facts) :- forall(member(F, Facts), assertz(F)).

pf_facts(Name/Arity, Facts) :-
    functor(Head, Name, Arity),
    findall(Head, Head, Facts).

pf_set(Specs, Facts) :- pf_clear(Specs), pf_assert_all(Facts).

%-----------------------------------------------------------------------------------------
% 3. ARCHIVOS TEMPORALES
%-----------------------------------------------------------------------------------------
pf_tmp(File) :- tmp_file(pf, File).

pf_delete(File) :- ( exists_file(File) -> delete_file(File) ; true ).

pf_write_text(File, Text) :-
    setup_call_cleanup(open(File, write, S, [encoding(utf8)]), write(S, Text), close(S)).

pf_write_facts(File, Facts) :-
    setup_call_cleanup(open(File, write, S, [encoding(utf8)]),
                       forall(member(F, Facts), portray_clause(S, F)),
                       close(S)).

pf_read_facts(File, Terms) :-
    setup_call_cleanup(open(File, read, S, [encoding(utf8)]), read_terms(S, Terms), close(S)).

% Texto con acento, ene y comillas escritos con CODIGOS (sirve aunque el archivo se lea con otra codificacion)
pf_special(Text) :- format(string(Text), "Caf~c \"con\" ~c", [233, 241]).

%-----------------------------------------------------------------------------------------
% 4. COMPROBACIONES GENERICAS (las usan los tests de cada archivo de persistencia)
%    Save y Load son las versiones con File: save_expenses, load_expenses ...
%-----------------------------------------------------------------------------------------
pf_round_trip(Save, Load, Spec, Samples) :-
    pf_set([Spec], Samples),
    pf_tmp(File),
    call(Save, File),
    pf_clear([Spec]),
    call(Load, File),
    pf_facts(Spec, Facts),
    pf_delete(File),
    Facts == Samples.

pf_file_content(Save, Spec, Samples) :-
    pf_set([Spec], Samples),
    pf_tmp(File),
    call(Save, File),
    pf_read_facts(File, Terms),
    pf_delete(File),
    Terms == Samples.

pf_load_replaces(Load, Spec, Old, New) :-
    pf_set([Spec], Old),
    pf_tmp(File),
    pf_write_facts(File, New),
    call(Load, File),
    pf_facts(Spec, Facts),
    pf_delete(File),
    Facts == New.

pf_missing_file_keeps(Load, Spec, Samples) :-
    pf_set([Spec], Samples),
    pf_tmp(File),
    pf_delete(File),
    call(Load, File),
    pf_facts(Spec, Facts),
    Facts == Samples.

pf_ignores_other_terms(Load, Spec, Samples) :-
    pf_set([Spec], []),
    pf_tmp(File),
    pf_write_facts(File, [other_fact(1, 2)|Samples]),
    call(Load, File),
    pf_facts(Spec, Facts),
    pf_delete(File),
    Facts == Samples.

% archivo roto: debe dar error y NO borrar lo que ya estaba en memoria
pf_broken_file_keeps(Load, Spec, Samples) :-
    pf_set([Spec], Samples),
    pf_tmp(File),
    pf_write_text(File, "this is ( not valid prolog.\n"),
    catch(call(Load, File), error(syntax_error(_), _), true),
    pf_facts(Spec, Facts),
    pf_delete(File),
    Facts == Samples.

pf_empty_memory(Save, Load, Spec, Samples) :-
    pf_set([Spec], []),
    pf_tmp(File),
    call(Save, File),
    pf_read_facts(File, Terms),
    Terms == [],
    pf_set([Spec], Samples),
    call(Load, File),
    pf_facts(Spec, Facts),
    pf_delete(File),
    Facts == [].

pf_creates_directory(Save, Spec, Samples) :-
    pf_set([Spec], Samples),
    tmp_file(pf_dir, Dir),
    directory_file_path(Dir, 'sub/data.pl', File),
    \+ exists_directory(Dir),
    call(Save, File),
    exists_file(File),
    delete_directory_and_contents(Dir).

% el archivo en disco esta en UTF-8: la e con acento ocupa los bytes 195,169
pf_written_as_utf8(Save, Spec, Samples) :-
    pf_set([Spec], Samples),
    pf_tmp(File),
    call(Save, File),
    setup_call_cleanup(open(File, read, S, [type(binary)]), pf_read_bytes(S, Bytes), close(S)),
    pf_delete(File),
    append(_, [195, 169 | _], Bytes), !.

pf_read_bytes(S, Bytes) :-
    get_byte(S, B),
    ( B == -1 -> Bytes = [] ; Bytes = [B|Rest], pf_read_bytes(S, Rest) ).

% las versiones sin argumento usan el archivo que dice File_predicate
pf_default_file(File_predicate, Save0, Load0, Spec, Samples) :-
    Old =.. [File_predicate, _Original],
    call(Old),
    pf_tmp(Tmp),
    New =.. [File_predicate, Tmp],
    setup_call_cleanup(
        ( retractall(Old), assertz(New) ),
        ( pf_set([Spec], Samples),
          call(Save0),
          pf_clear([Spec]),
          call(Load0),
          pf_facts(Spec, Facts),
          Facts == Samples ),
        ( retractall(New), assertz(Old), pf_delete(Tmp) ) ).
