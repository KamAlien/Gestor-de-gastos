:- use_module(library(plunit)).
:- ensure_loaded('../../../../prolog/rules/operations/category').

:- dynamic cu_saved/1.

cu_save :-
    retractall(cu_saved(_)),
    forall(expenses(A,B,C,D,E,F,G),
           assertz(cu_saved(expenses(A,B,C,D,E,F,G)))),
    forall(categories(X,Y,Z),
           assertz(cu_saved(categories(X,Y,Z)))),
    forall(context_exception(P,Q,R),
           assertz(cu_saved(context_exception(P,Q,R)))),
    forall(text_rule(H,K),
           assertz(cu_saved(text_rule(H,K)))),
    forall(general_description_category(M,N),
           assertz(cu_saved(general_description_category(M,N)))).

cu_clear :-
    retractall(expenses(_,_,_,_,_,_,_)),
    retractall(categories(_,_,_)),
    retractall(context_exception(_,_,_)),
    retractall(text_rule(_,_)),
    retractall(general_description_category(_,_)).

cu_restore :-
    cu_clear,
    forall(cu_saved(Fact), assertz(Fact)),
    retractall(cu_saved(_)).

cu_setup :- cu_save, cu_clear.

cu_delete_category(Cat) :-
    retract(categories(Cat, _, _)).
cu_add_expense(Cat) :-
    assertz(expenses(2026, 5, 10, "x", 100, Cat, "General")).
cu_add_category(Cat) :-
    assertz(categories(Cat, "descripcion", 0)).
cu_add_text(Hint, Cat) :-
    assertz(text_rule(Hint, Cat)).
cu_add_context(Word, Context, Cat) :-
    assertz(context_exception(Word, Context, Cat)).
cu_add_general(Desc, Cat) :-
    assertz(general_description_category(Desc, Cat)).

:- begin_tests(category_existence, [setup(cu_setup), cleanup(cu_restore)]).

test(exists, [setup(cu_add_category(comida)), cleanup(cu_clear)]) :-
    category_exist(comida).

test(does_not_exist, [fail]) :-
    category_exist(comida).

test(exist_is_deterministic,
     [setup((cu_add_category(comida), cu_add_category(comida))), cleanup(cu_clear)]) :-
    findall(x, category_exist(comida), L),
    L == [x].

test(not_exist_true) :-
    category_not_exist(comida).

test(not_exist_false, [fail, setup(cu_add_category(comida)), cleanup(cu_clear)]) :-
    category_not_exist(comida).

test(ahorro_cannot_be_duplicated, [fail, setup(cu_add_category(ahorro)), cleanup(cu_clear)]) :-
    category_not_exist(ahorro).

test(ahorro_free_after_delete,
     [setup(cu_add_category(ahorro)), cleanup(cu_clear)]) :-
    cu_delete_category(ahorro),
    category_not_exist(ahorro).

:- end_tests(category_existence).

:- begin_tests(category_unused, [setup(cu_setup), cleanup(cu_restore)]).

test(free_category) :-
    category_unused(libre).

test(used_by_expense, [fail, setup(cu_add_expense(viaje)), cleanup(cu_clear)]) :-
    category_unused(viaje).

test(used_by_text_rule, [fail, setup(cu_add_text("cine", ocio)), cleanup(cu_clear)]) :-
    category_unused(ocio).

test(used_by_context_exception,
     [fail, setup(cu_add_context("hospital", "urgencia", salud)), cleanup(cu_clear)]) :-
    category_unused(salud).

test(used_by_general_description,
     [fail, setup(cu_add_general("Comida", comida)), cleanup(cu_clear)]) :-
    category_unused(comida).

test(other_category_still_free, [setup(cu_add_text("cine", ocio)), cleanup(cu_clear)]) :-
    category_unused(libre).

:- end_tests(category_unused).
