%=================================================================================================================================================
% CORRE TODOS LOS TESTS DEL PROYECTO
%   swipl -g run_tests -t halt tests/tests.pl
% Cuando agregues un archivo de tests nuevo, anade aqui su ensure_loaded.
%=================================================================================================================================================
:- use_module(library(plunit)).

% datos
:- ensure_loaded('prolog/test_datos').

% reglas
%:- ensure_loaded('prolog/rules/test_valid_user').
%:- ensure_loaded('prolog/rules/test_valid_register_operations').
%:- ensure_loaded('prolog/rules/test_savings_accounts').
%:- ensure_loaded('prolog/rules/test_valid_category').

% operaciones de las reglas
%:- ensure_loaded('prolog/rules/operations/test_savings_accounts').
%:- ensure_loaded('prolog/rules/operations/test_category').
:- ensure_loaded('prolog/rules/operations/test_classification').


% operaciones
%:- ensure_loaded('prolog/operations/test_user').
%:- ensure_loaded('prolog/operations/auxiliary methods/test_account_balance').
%:- ensure_loaded('prolog/operations/test_savings_account').
%:- ensure_loaded('prolog/operations/test_savings').
%:- ensure_loaded('prolog/operations/test_savings_adjustments').
%:- ensure_loaded('prolog/operations/test_categories').
:- ensure_loaded('prolog/operations/test_classification').

% persistence
%:- ensure_loaded('prolog/persistence/test_persistence_category').

% settings
:- ensure_loaded('prolog/confing/test_classification').
