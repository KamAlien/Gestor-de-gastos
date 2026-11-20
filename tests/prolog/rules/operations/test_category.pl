:- encoding(utf8).
%=========================================================================================
% PRUEBAS DE prolog/rules/operations/category.pl
% Solo este archivo: valid_arguments, valid_update_arguments, category_exist,
% category_not_exist y category_unused. Son consultas: no modifican nada.
%=========================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../helpers').
:- ensure_loaded('../../../../prolog/rules/operations/category').

:- begin_tests(regla_valid_arguments, [setup(backup), cleanup(restore)]).

test(ok)                          :- valid_arguments(salud, "Gastos de salud").
test(nombre_vacio, fail)          :- valid_arguments('', "algo").
test(nombre_no_atomo, fail)       :- valid_arguments("salud", "algo").
test(nombre_libre, fail)          :- valid_arguments(_, "algo").
test(descripcion_vacia, fail)     :- valid_arguments(salud, "").
test(descripcion_no_cadena, fail) :- valid_arguments(salud, algo).
test(descripcion_libre, fail)     :- valid_arguments(salud, _).

:- end_tests(regla_valid_arguments).

:- begin_tests(regla_consultas, [setup(backup), cleanup(restore)]).

test(exist_si_existe, [setup(fx)])           :- category_exist(deseo).
test(exist_no_existe, [setup(fx), fail])     :- category_exist(inventada).
test(exist_da_una_sola_respuesta, [setup(fx), true(N == 1)]) :-
    aggregate_all(count, category_exist(deseo), N).

test(not_exist_si_no_existe, [setup(fx)])    :- category_not_exist(inventada).
test(not_exist_si_existe, [setup(fx), fail]) :- category_not_exist(deseo).

test(unused_sin_gastos, [setup(fx)])         :- category_unused(deseo).
test(unused_con_gasto_de_otra_categoria, [setup(fx)]) :-
    add_expense(necesidad),
    category_unused(deseo).
test(unused_con_gasto_propio, [setup(fx), fail]) :-
    add_expense(deseo),
    category_unused(deseo).

:- end_tests(regla_consultas).

:- begin_tests(regla_valid_update_arguments).   % algo debe cambiar: nombre o descripcion

test(cambia_nombre)        :- valid_update_arguments(a, b, "x", "x").
test(cambia_descripcion)   :- valid_update_arguments(a, a, "x", "y").
test(nada_cambia, fail)    :- valid_update_arguments(a, a, "x", "x").
test(cambian_ambos_una_sola_respuesta, [true(N == 1)]) :-
    aggregate_all(count, valid_update_arguments(a, b, "x", "y"), N).

:- end_tests(regla_valid_update_arguments).
