:- encoding(utf8).
%=========================================================================================
% PRUEBAS DE LAS OPERACIONES DE CATEGORIAS (prolog/operations/categories.pl)
% Estas SI modifican los hechos. Se comprueba el cambio cuando es valido
% y que NO se toca nada cuando no lo es.
%=========================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../helpers').
:- ensure_loaded('../../../prolog/operations/categories').

:- begin_tests(op_create, [setup(backup), cleanup(restore)]).

test(crea_con_cero_por_ciento, [setup(fx)]) :-
    create_category(salud, "Gastos de salud"),
    categories(salud, "Gastos de salud", 0).
test(no_rompe_la_suma_100, [setup(fx)]) :-
    create_category(salud, "Gastos de salud"),
    percents(Ps), sum_list(Ps, 100).
test(argumentos_malos_no_crean_nada, [setup(fx)]) :-
    \+ create_category('', "x"),
    \+ create_category(salud, ""),
    aggregate_all(count, categories(_, _, _), 3).
test(no_se_puede_crear_dos_veces, [setup(fx)]) :-
    create_category(salud, "Gastos de salud"),
    \+ create_category(salud, "Gastos de salud"),
    aggregate_all(count, categories(salud, _, _), 1).

:- end_tests(op_create).

:- begin_tests(op_update, [setup(backup), cleanup(restore)]).

test(cambiar_solo_descripcion, [setup(fx)]) :-
    update_category(deseo, deseo, "Ocio y entretenimiento"),
    categories(deseo, "Ocio y entretenimiento", 30),
    aggregate_all(count, categories(_, _, _), 3).
test(renombrar_conserva_el_porcentaje, [setup(fx)]) :-
    update_category(deseo, ocio, "Gastos de ocio"),
    categories(ocio, "Gastos de ocio", 30),
    \+ categories(deseo, _, _).
test(renombrar_no_toca_las_demas, [setup(fx)]) :-
    update_category(deseo, ocio, "Gastos de ocio"),
    categories(necesidad, "Gastos esenciales", 50),
    categories(ahorro, "Lo que se ahorra", 20).
test(actualizar_invalido_no_cambia_nada, [setup(fx)]) :-
    \+ update_category(deseo, necesidad, "x"),
    categories(deseo, "Gastos de ocio", 30),
    categories(necesidad, "Gastos esenciales", 50).
test(renombrar_en_uso_no_cambia_nada, [setup(fx)]) :-
    add_expense(deseo),
    \+ update_category(deseo, ocio, "Gastos de ocio"),
    categories(deseo, _, 30),
    \+ categories(ocio, _, _).
test(sin_cambios_no_hace_nada, [setup(fx)]) :-
    \+ update_category(deseo, deseo, "Gastos de ocio"),
    aggregate_all(count, categories(deseo, _, _), 1).

:- end_tests(op_update).

:- begin_tests(op_delete, [setup(backup), cleanup(restore)]).

test(elimina_con_cero_por_ciento, [setup(fx)]) :-
    create_category(salud, "Gastos de salud"),
    delete_category(salud),
    \+ categories(salud, _, _).
test(eliminar_no_rompe_la_suma_100, [setup(fx)]) :-
    create_category(salud, "Gastos de salud"),
    delete_category(salud),
    percents(Ps), sum_list(Ps, 100).
test(borrar_invalido_no_cambia_nada, [setup(fx)]) :-
    \+ delete_category(deseo),
    aggregate_all(count, categories(_, _, _), 3).
test(no_borra_si_esta_en_uso, [setup(fx)]) :-
    create_category(salud, "Gastos de salud"),
    add_expense(salud),
    \+ delete_category(salud),
    categories(salud, _, 0).
test(no_borra_inexistente, [setup(fx)]) :-
    \+ delete_category(inventada),
    aggregate_all(count, categories(_, _, _), 3).

:- end_tests(op_delete).

:- begin_tests(op_change_percents, [setup(backup), cleanup(restore)]).

test(aplica_los_cambios, [setup(fx)]) :-
    change_percents([necesidad-60, deseo-25, ahorro-15]),
    categories(necesidad, _, 60),
    categories(deseo, _, 25),
    categories(ahorro, _, 15),
    percents(Ps), sum_list(Ps, 100).
test(cambio_parcial, [setup(fx)]) :-
    change_percents([necesidad-40, deseo-40]),
    categories(necesidad, _, 40),
    categories(deseo, _, 40),
    categories(ahorro, _, 20).
test(conserva_las_descripciones, [setup(fx)]) :-
    change_percents([necesidad-60, deseo-25, ahorro-15]),
    categories(deseo, "Gastos de ocio", 25).
test(cambio_invalido_no_toca_nada_todo_o_nada, [setup(fx)]) :-
    \+ change_percents([necesidad-60, deseo-30, ahorro-20]),
    categories(necesidad, _, 50),
    categories(deseo, _, 30),
    categories(ahorro, _, 20).
test(una_categoria_inexistente_cancela_todo, [setup(fx)]) :-
    \+ change_percents([necesidad-60, inventada-40]),
    categories(necesidad, _, 50).

:- end_tests(op_change_percents).

:- begin_tests(op_set_percent, [setup(backup), cleanup(restore)]).

test(cambia_solo_el_porcentaje, [setup(fx)]) :-
    set_percent(deseo, 45),
    categories(deseo, "Gastos de ocio", 45),
    aggregate_all(count, categories(deseo, _, _), 1).
test(inexistente, [setup(fx), fail]) :-
    set_percent(inventada, 10).

:- end_tests(op_set_percent).

%-----------------------------------------------------------------------------------------
% Recorrido completo (integracion)
%-----------------------------------------------------------------------------------------
:- begin_tests(op_integracion, [setup(backup), cleanup(restore)]).

test(ciclo_de_vida_de_una_categoria, [setup(fx)]) :-
    create_category(salud, "Gastos de salud"),                   % empieza en 0%
    change_percents([necesidad-45, salud-5]),                    % 45 + 30 + 20 + 5 = 100
    percents(P1), sum_list(P1, 100),
    \+ delete_category(salud),                                   % tiene 5%: no se borra
    change_percents([necesidad-50, salud-0]),                    % se devuelve a 0%
    update_category(salud, salud_y_bienestar, "Salud y bienestar"),
    delete_category(salud_y_bienestar),
    \+ categories(salud_y_bienestar, _, _),
    percents(P2), sum_list(P2, 100),
    aggregate_all(count, categories(_, _, _), 3).

:- end_tests(op_integracion).
