:- encoding(utf8).
%=========================================================================================================================
% AUTOMATIC CLASSIFICATION OF AN EXPENSE
% Priority:  1) context exceptions   2) hints in the text   3) general description   4) default category
% With contradictory answers nothing is guessed: the default category (pendiente) is returned so the user is asked
%=========================================================================================================================
:- ensure_loaded('../confing/auto_classification').
:- ensure_loaded('../rules/operations/classification').

%=========================================================================================================================
% CLASSIFY AN EXPENSE: always gives exactly one category
%=========================================================================================================================
classify_expense(Description, General_description, Category):-
    words_of(Description, Words),
    normalize_text(General_description, General),
    categories_by_exception(General, Words, Exceptions),
    categories_by_text(Words, Texts),
    categories_by_general(General, Generals),
    decide(Exceptions, Texts, Generals, Category).


%=========================================================================================================================
% THE THREE SOURCES: each one returns the list of distinct categories it found
%=========================================================================================================================
categories_by_exception(General, Words, Categories):-
    findall(Category, (context_exception(Row_general, Hint, Category),
                        normalize_text(Row_general, General),
                        hint_in_words(Hint, Words)),
                    List),
    sort(List, Categories).

categories_by_text(Words, Categories):-
    findall(Category, (text_rule(Hint, Category),
                    hint_in_words(Hint, Words)), List),
    sort(List, Categories).

categories_by_general(General, Categories):-
    findall(Category, (general_description_category(Row_general, Category),
                    normalize_text(Row_general, General)), List),
    sort(List, Categories).

%=========================================================================================================================
% DECIDE (exceptions, texts, generals): the clauses cover every case and each one ends with a cut
%=========================================================================================================================
decide([Category], _, _, Category):- !.
decide([_, _ | _], _, _, Category):- !, fallback_category(Category).
decide([], [Category], _, Category):- !.
decide([], [_, _ | _], [Category | _], Category):- !.
decide([], [], [Category | _], Category):- !.
decide([], _, [], Category):- fallback_category(Category).

fallback_category(Category):- once(default_category(Category)).


%=========================================================================================================================
% Actualiza las reglas cuando se cambia el nombre de las categorias
%=========================================================================================================================
rename_category_in_rules(Old, New):-
    ground(Old), ground(New), Old \== New,
    forall( retract(text_rule(Hint, Old)),
            assertz(text_rule(Hint, New))),
    forall( retract(context_exception(Word, Context, Old)),
            assertz(context_exception(Word, Context, New))),
    forall(retract(general_description_category(Description, Old)),
            assertz(general_description_category(Description, New))).
