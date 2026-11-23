:- encoding(utf8).
%=========================================================================================
% PRUEBAS DE LOS DATOS DE EJEMPLO (prolog/datos.pl)
% Deben ejecutarse ANTES que las demas (tests.pl los carga primero).
% Esta prueba habria detectado el error "cateogries" que hacia desaparecer "deseo".
%=========================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../helpers').

:- begin_tests(datos_ejemplo).

test(existen_las_tres_categorias, [all(C == [necesidad, deseo, ahorro])]) :-
    categories(C, _, _).

test(porcentajes_suman_100) :-
    percents(Ps), sum_list(Ps, 100).

:- end_tests(datos_ejemplo).
