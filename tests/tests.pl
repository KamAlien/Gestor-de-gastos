%=================================================================================================================================================
% CORRE TODOS LOS TESTS DEL PROYECTO
%   swipl -g run_tests -t halt tests/tests.pl
% Cuando agregues un archivo de tests nuevo, anade aqui su ensure_loaded.
%=================================================================================================================================================
:- use_module(library(plunit)).

% reglas
:- ensure_loaded('prolog/rules/test_valid_user').
:- ensure_loaded('prolog/rules/test_valid_register_operations').
:- ensure_loaded('prolog/rules/test_savings_accounts').
:- ensure_loaded('prolog/rules/operations/test_savings_accounts').

% operaciones
:- ensure_loaded('prolog/operations/test_user').
