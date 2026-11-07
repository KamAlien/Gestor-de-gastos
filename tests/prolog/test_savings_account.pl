%=================================================================================================================================================
% TESTS DE LA CUENTA DE AHORRO
% Correr desde la carpeta del proyecto:
%   swipl -g run_tests -t halt prolog/tests/savings_account_test.pl
% OJO: los valores esperados dependen de los datos de prueba de datos.pl.
%=================================================================================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../prolog/operations/savings_account').

%--------------------------------------------------------------------------
% up_to/4 : (Y1, M1) es igual o anterior a (Y2, M2)?
%--------------------------------------------------------------------------
:- begin_tests(up_to).

test(earlier_month, [nondet])        :- up_to(2026, 2, 2026, 3).
test(same_month, [nondet])           :- up_to(2026, 3, 2026, 3).
test(later_month, [fail])            :- up_to(2026, 4, 2026, 3).
test(earlier_year, [nondet])         :- up_to(2025, 12, 2026, 1).
test(later_year, [fail])             :- up_to(2027, 1, 2026, 3).

:- end_tests(up_to).

%--------------------------------------------------------------------------
% total_up_to/4 : suma de una tabla hasta un mes
%--------------------------------------------------------------------------
:- begin_tests(total_up_to).

test(expenses_feb)    :- total_up_to(expenses, 2026, 2, T), T =:= 1000.
test(expenses_march)  :- total_up_to(expenses, 2026, 3, T), T =:= 2800.
test(incomes_feb)     :- total_up_to(incomes,  2026, 2, T), T =:= 0.
test(incomes_march)   :- total_up_to(incomes,  2026, 3, T), T =:= 1700.
test(before_data)     :- total_up_to(expenses, 2025, 12, T), T =:= 0.

:- end_tests(total_up_to).

%--------------------------------------------------------------------------
% adjustments_up_to/3 : suma de ajustes hasta un mes
%--------------------------------------------------------------------------
:- begin_tests(adjustments_up_to).

test(feb)          :- adjustments_up_to(2026, 2, T), T =:= 0.
test(march)        :- adjustments_up_to(2026, 3, T), T =:= 150.
test(before_data)  :- adjustments_up_to(2025, 12, T), T =:= 0.

:- end_tests(adjustments_up_to).

%--------------------------------------------------------------------------
% savings_account/3 : saldo = ingresos - gastos + ajustes
%--------------------------------------------------------------------------
:- begin_tests(savings_account).

test(before_data)     :- savings_account(2025, 12, S), S =:= 0.
test(feb_negative)    :- savings_account(2026, 2, S), S =:= -1000.
test(march)           :- savings_account(2026, 3, S), S =:= -950.
test(april_carries)   :- savings_account(2026, 4, S), S =:= -950.

:- end_tests(savings_account).