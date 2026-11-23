:- encoding(utf8).
%=========================================================================================
% PRUEBAS DE GUARDAR Y CARGAR (prolog/operations/persistence/persistence_categories.pl)
% Siempre con archivos temporales: nunca se toca data/categories.pl real.
%=========================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../helpers').

:- begin_tests(persistencia, [setup(backup), cleanup(restore)]).

test(guardar_y_cargar_devuelve_lo_mismo, [setup(fx)]) :-
    tmp_file(categorias, File),
    findall(C-D-P, categories(C, D, P), Antes),
    save_categories(File),
    clear_categories,
    load_categories(File),
    findall(C-D-P, categories(C, D, P), Despues),
    delete_file(File),
    Antes == Despues.

test(las_descripciones_siguen_siendo_cadenas, [setup(fx)]) :-
    tmp_file(categorias, File),
    save_categories(File),
    clear_categories,
    load_categories(File),
    delete_file(File),
    categories(deseo, Description, _),
    string(Description).

test(acentos_y_enie_sobreviven, [setup(fx)]) :-
    clear_categories,
    add_category(educacion, "Educación y años de estudio", 100),
    tmp_file(categorias, File),
    save_categories(File),
    clear_categories,
    load_categories(File),
    delete_file(File),
    categories(educacion, "Educación y años de estudio", 100).

test(cargar_no_duplica, [setup(fx)]) :-
    tmp_file(categorias, File),
    save_categories(File),
    load_categories(File),
    load_categories(File),
    delete_file(File),
    aggregate_all(count, categories(_, _, _), 3).

test(archivo_inexistente_no_borra_la_memoria, [setup(fx)]) :-
    tmp_file(no_existe, File),
    load_categories(File),
    aggregate_all(count, categories(_, _, _), 3).

test(archivo_con_basura_se_ignora, [setup(fx)]) :-
    tmp_file(categorias, File),
    setup_call_cleanup(
        open(File, write, S),
        ( portray_clause(S, categories(salud, "Salud", 100)),
          portray_clause(S, otra_cosa(1, 2)) ),
        close(S)),
    load_categories(File),
    delete_file(File),
    categories(salud, "Salud", 100),
    \+ current_predicate(user:otra_cosa/2),
    aggregate_all(count, categories(_, _, _), 1).

:- end_tests(persistencia).

:- begin_tests(persistencia_defecto, [setup(backup), cleanup(restore)]).

test(ruta_por_defecto_es_data_categories) :-
    nb_getval(backup_files, [File]),
    File == 'data/categories.pl'.

test(save_y_load_sin_argumentos, [setup(fx)]) :-
    tmp_file(categorias, File),
    set_categories_file(File),
    save_categories,
    clear_categories,
    load_categories,
    delete_file(File),
    aggregate_all(count, categories(_, _, _), 3),
    categories(deseo, "Gastos de ocio", 30).

test(load_sin_argumentos_y_sin_archivo_no_borra, [setup(fx)]) :-
    tmp_file(no_existe, File),
    set_categories_file(File),
    load_categories,
    aggregate_all(count, categories(_, _, _), 3).

test(guardar_sin_categorias_crea_archivo_vacio, [setup(fx)]) :-
    clear_categories,
    tmp_file(categorias, File),
    save_categories(File),
    size_file(File, Size),
    delete_file(File),
    Size =:= 0.

test(read_terms_lee_todo, [true(Ts == [a(1), "dos", tres])]) :-
    tmp_file(terminos, File),
    setup_call_cleanup(open(File, write, S),
                       ( portray_clause(S, a(1)), portray_clause(S, "dos"), portray_clause(S, tres) ),
                       close(S)),
    setup_call_cleanup(open(File, read, In), read_terms(In, Ts), close(In)),
    delete_file(File).

test(read_terms_archivo_vacio, [true(Ts == [])]) :-
    tmp_file(vacio, File),
    setup_call_cleanup(open(File, write, S), true, close(S)),
    setup_call_cleanup(open(File, read, In), read_terms(In, Ts), close(In)),
    delete_file(File).

:- end_tests(persistencia_defecto).

:- begin_tests(persistencia_integracion, [setup(backup), cleanup(restore)]).

test(guardar_y_recuperar_despues_de_cambios, [setup(fx)]) :-
    clear_categories,
    add_category(necesidad, "Gastos esenciales", 60),
    add_category(deseo, "Gastos de ocio", 25),
    add_category(ahorro, "Lo que se ahorra", 15),
    add_category(salud, "Gastos de salud", 0),
    tmp_file(categorias, File),
    save_categories(File),
    clear_categories,
    load_categories(File),
    delete_file(File),
    categories(necesidad, _, 60),
    categories(salud, "Gastos de salud", 0),
    percents(Ps), sum_list(Ps, 100).

:- end_tests(persistencia_integracion).
