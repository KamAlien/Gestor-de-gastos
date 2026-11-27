:- encoding(utf8).
%=========================================================================================
% HELPERS FOR THE CLASSIFICATION TESTS (names start with cl_)
% IMPORTANT: an assertz/retractall written INSIDE a test creates predicates local to the test
% and does not touch the real data; that is why everything that changes facts lives here.
%=========================================================================================
:- ensure_loaded('../prolog/confing/auto_classification').

cl_tables([context_exception/3, text_rule/2, general_description_category/2, default_category/1]).

cl_backup :-
    cl_tables(Tables),
    forall(member(Name/Arity, Tables),
           ( functor(Head, Name, Arity),
             findall(Head, Head, Facts),
             atom_concat(cl_saved_, Name, Key),
             nb_setval(Key, Facts) )).

cl_restore :-
    cl_tables(Tables),
    forall(member(Name/Arity, Tables),
           ( functor(Head, Name, Arity),
             retractall(Head),
             atom_concat(cl_saved_, Name, Key),
             nb_getval(Key, Facts),
             forall(member(F, Facts), assertz(F)) )).

cl_clear :-
    cl_tables(Tables),
    forall(member(Name/Arity, Tables),
           ( functor(Head, Name, Arity), retractall(Head) )).

cl_add_exception(General, Hint, Category) :- assertz(context_exception(General, Hint, Category)).
cl_add_text_rule(Hint, Category)          :- assertz(text_rule(Hint, Category)).
cl_add_general(General, Category)         :- assertz(general_description_category(General, Category)).
cl_set_default(Category)                  :- retractall(default_category(_)), assertz(default_category(Category)).

% small known data
cl_fixture :-
    cl_clear,
    cl_add_exception("hospital", "estetica", deseo),
    cl_add_exception("hospital", "urgencia", necesidad),
    cl_add_text_rule("pan", necesidad),
    cl_add_text_rule("comida", necesidad),
    cl_add_text_rule("zapato", deseo),
    cl_add_text_rule("pizza", deseo),
    cl_add_text_rule("cine", deseo),
    cl_add_general("hospital", necesidad),
    cl_add_general("salidas", deseo),
    cl_add_general("compras", deseo),
    cl_add_general("super mercado", necesidad),
    cl_set_default(pendiente).

cl_count(Head, N) :- findall(x, Head, L), length(L, N).