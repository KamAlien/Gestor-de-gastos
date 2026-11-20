:- encoding(utf8).
%=========================================================================================
% PRUEBAS DE prolog/rules/valid_category.pl
% Solo este archivo: valid_create_category, valid_update_category, valid_new_name,
% valid_delete_category, valid_change_percent y valid_list_changes.
% Solo responden true/false: tambien se comprueba que NO modifican nada.
%=========================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../helpers').
:- ensure_loaded('../../../prolog/rules/valid_category').

:- begin_tests(regla_valid_create, [setup(backup), cleanup(restore)]).

test(valida_si_no_existe, [setup(fx)]) :-
    valid_create_category(salud, "Gastos de salud").
test(invalida_si_ya_existe, [setup(fx), fail]) :-
    valid_create_category(deseo, "Otra descripcion").
test(invalida_nombre_vacio, [setup(fx), fail]) :-
    valid_create_category('', "x").
test(invalida_descripcion_vacia, [setup(fx), fail]) :-
    valid_create_category(salud, "").
test(no_modifica_nada, [setup(fx)]) :-
    valid_create_category(salud, "Gastos de salud"),
    aggregate_all(count, categories(_, _, _), 3).

:- end_tests(regla_valid_create).

:- begin_tests(regla_valid_update, [setup(backup), cleanup(restore)]).

test(cambiar_solo_descripcion, [setup(fx)]) :-
    valid_update_category(deseo, deseo, "Ocio y entretenimiento").
test(renombrar_a_nombre_libre, [setup(fx)]) :-
    valid_update_category(deseo, ocio, "Gastos de ocio").
test(sin_cambios_es_invalido, [setup(fx), fail]) :-
    valid_update_category(deseo, deseo, "Gastos de ocio").
test(no_renombrar_a_una_existente, [setup(fx), fail]) :-
    valid_update_category(deseo, necesidad, "Gastos de ocio").
test(no_renombrar_una_categoria_en_uso, [setup(fx), fail]) :-
    add_expense(deseo),
    valid_update_category(deseo, ocio, "Gastos de ocio").
test(en_uso_si_se_puede_cambiar_la_descripcion, [setup(fx)]) :-
    add_expense(deseo),
    valid_update_category(deseo, deseo, "Ocio").
test(categoria_inexistente, [setup(fx), fail]) :-
    valid_update_category(inventada, nueva, "algo").
test(argumentos_invalidos, [setup(fx), fail]) :-
    valid_update_category(deseo, deseo, "").
test(nombre_nuevo_invalido, [setup(fx), fail]) :-
    valid_update_category(deseo, '', "algo").
test(no_modifica_nada, [setup(fx)]) :-
    valid_update_category(deseo, ocio, "Gastos de ocio"),
    categories(deseo, "Gastos de ocio", 30),
    \+ categories(ocio, _, _).

:- end_tests(regla_valid_update).

:- begin_tests(regla_valid_new_name, [setup(backup), cleanup(restore)]).
% mismo nombre | nombre libre y categoria vieja sin uso

test(mismo_nombre, [setup(fx)])             :- valid_new_name(deseo, deseo).
test(libre_y_sin_uso, [setup(fx)])          :- valid_new_name(deseo, ocio).
test(ocupado, [setup(fx), fail])            :- valid_new_name(deseo, necesidad).
test(en_uso, [setup(fx), fail])             :-
    add_expense(deseo),
    valid_new_name(deseo, ocio).
test(mismo_nombre_en_uso_si_vale, [setup(fx)]) :-      % no cambia el nombre: no importa que este en uso
    add_expense(deseo),
    valid_new_name(deseo, deseo).

:- end_tests(regla_valid_new_name).

:- begin_tests(regla_valid_delete, [setup(backup), cleanup(restore)]).

test(valida_con_cero_por_ciento_y_sin_uso, [setup(fx)]) :-
    add_category(salud, "Gastos de salud", 0),
    valid_delete_category(salud).
test(valida_con_cero_decimal, [setup(fx)]) :-
    add_category(salud, "Gastos de salud", 0.0),
    valid_delete_category(salud).
test(no_si_tiene_porcentaje, [setup(fx), fail]) :-
    valid_delete_category(deseo).
test(no_si_esta_en_uso, [setup(fx), fail]) :-
    add_category(salud, "Gastos de salud", 0),
    add_expense(salud),
    valid_delete_category(salud).
test(no_si_no_existe, [setup(fx), fail]) :-
    valid_delete_category(inventada).
test(no_modifica_nada, [setup(fx)]) :-
    add_category(salud, "Gastos de salud", 0),
    valid_delete_category(salud),
    categories(salud, _, _).

:- end_tests(regla_valid_delete).

:- begin_tests(regla_valid_change_percent, [setup(backup), cleanup(restore)]).

test(suma_100_es_valido, [setup(fx)]) :-
    valid_change_percent([necesidad-60, deseo-25, ahorro-15]).
test(cambio_parcial_valido, [setup(fx)]) :-          % 40 + 40 + 20 (ahorro no cambia)
    valid_change_percent([necesidad-40, deseo-40]).
test(decimales_validos, [setup(fx)]) :-
    valid_change_percent([necesidad-33.3, deseo-33.3, ahorro-33.4]).
test(no_suma_100, [setup(fx), fail]) :-
    valid_change_percent([necesidad-60, deseo-30, ahorro-20]).
test(ejemplo_de_la_clase_suma_120, [setup(fx), fail]) :-
    valid_change_percent([necesidad-70, deseo-30]).
test(menos_de_dos_categorias, [setup(fx), fail]) :-
    valid_change_percent([necesidad-50]).
test(lista_vacia, [setup(fx), fail]) :-
    valid_change_percent([]).
test(categoria_inexistente, [setup(fx), fail]) :-
    valid_change_percent([necesidad-50, inventada-50]).
test(porcentaje_negativo, [setup(fx), fail]) :-
    valid_change_percent([necesidad-120, deseo-(-20)]).
test(porcentaje_no_numerico, [setup(fx), fail]) :-
    valid_change_percent([necesidad-"60", deseo-40]).
test(categoria_repetida, [setup(fx), fail]) :-
    valid_change_percent([necesidad-50, necesidad-50]).
test(no_modifica_nada, [setup(fx)]) :-
    valid_change_percent([necesidad-60, deseo-25, ahorro-15]),
    categories(necesidad, _, 50),
    categories(deseo, _, 30),
    categories(ahorro, _, 20).

:- end_tests(regla_valid_change_percent).

:- begin_tests(regla_valid_list_changes, [setup(backup), cleanup(restore)]).
% calcula nuevo - viejo para cada categoria

test(diferencias_ejemplo, [setup(fx), true(Ds == [10, -5, -5])]) :-
    valid_list_changes([necesidad-60, deseo-25, ahorro-15], Ds).
test(lista_vacia, [true(Ds == [])]) :-
    valid_list_changes([], Ds).
test(sin_cambio, [setup(fx), true(Ds == [0])]) :-
    valid_list_changes([deseo-30], Ds).
test(categoria_inexistente, [setup(fx), fail]) :-
    valid_list_changes([inventada-10], _).
test(categoria_libre, [setup(fx), fail]) :-
    valid_list_changes([_-10], _).
test(negativo, [setup(fx), fail]) :-
    valid_list_changes([deseo-(-1)], _).
test(no_es_numero, [setup(fx), fail]) :-
    valid_list_changes([deseo-abc], _).

:- end_tests(regla_valid_list_changes).
