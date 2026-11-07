%=================================================================================================================================================
% TESTS DE LAS REGLAS DEL USUARIO (prolog/rules/valid_user.pl)
% Correr desde la carpeta del proyecto:
%   swipl -g run_tests -t halt tests/rules/test_valid_user.pl
%=================================================================================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../prolog/rules/valid_user').

%--------------------------------------------------------------------------
% valid_user/3 : los DATOS son aceptables?
%--------------------------------------------------------------------------
:- begin_tests(valid_user).

test(valid_data)              :- valid_user("Kam", 20, "k@x.com").
test(empty_name, [fail])      :- valid_user("", 20, "k@x.com").
test(name_not_string, [fail]) :- valid_user(kam, 20, "k@x.com").
test(age_zero, [fail])        :- valid_user("Kam", 0, "k@x.com").
test(age_negative, [fail])    :- valid_user("Kam", -5, "k@x.com").
test(age_as_string, [fail])   :- valid_user("Kam", "20", "k@x.com").
test(age_decimal, [fail])     :- valid_user("Kam", 2.5, "k@x.com").
test(email_not_string, [fail]) :- valid_user("Kam", 20, 123).

:- end_tests(valid_user).