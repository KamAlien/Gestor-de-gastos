%=================================================================================================================================================
% TESTS DE LAS VALIDACIONES DE REGISTRO (prolog/rules/valid_register_operations.pl)
% Correr desde la carpeta del proyecto:
%   swipl -g run_tests -t halt tests/prolog/rules/test_valid_register_operations.pl
%=================================================================================================================================================
:- use_module(library(plunit)).
:- ensure_loaded('../../../prolog/rules/valid_register_operations').

%--------------------------------------------------------------------------
% leap_year/1 : anio bisiesto
%--------------------------------------------------------------------------
:- begin_tests(leap_year).

test(divisible_by_4, [nondet])           :- leap_year(2028).
test(century_divisible_by_400, [nondet]) :- leap_year(2000).
test(century_not_by_400, [fail])         :- leap_year(1900).
test(normal_year, [fail])                :- leap_year(2026).

:- end_tests(leap_year).

%--------------------------------------------------------------------------
% days_in_month/3 : dias de cada mes (all = exactamente una respuesta)
%--------------------------------------------------------------------------
:- begin_tests(days_in_month).

test(january, all(D == [31]))              :- days_in_month(2026, 1, D).
test(february_normal, all(D == [28]))      :- days_in_month(2026, 2, D).
test(february_leap, all(D == [29]))        :- days_in_month(2028, 2, D).
test(february_1900, all(D == [28]))        :- days_in_month(1900, 2, D).
test(february_2000, all(D == [29]))        :- days_in_month(2000, 2, D).
test(april, all(D == [30]))                :- days_in_month(2026, 4, D).
test(august, all(D == [31]))               :- days_in_month(2026, 8, D).
test(december, all(D == [31]))             :- days_in_month(2026, 12, D).
test(month_13, [fail])                     :- days_in_month(2026, 13, _).
test(month_0, [fail])                      :- days_in_month(2026, 0, _).

:- end_tests(days_in_month).

%--------------------------------------------------------------------------
% valid_day/3 : el dia existe en ese mes y anio?
%--------------------------------------------------------------------------
:- begin_tests(valid_day).

test(day_31_march)                    :- valid_day(2026, 3, 31).
test(day_31_april, [fail])            :- valid_day(2026, 4, 31).
test(feb_29_leap, [nondet])           :- valid_day(2028, 2, 29).
test(feb_29_not_leap, [fail])         :- valid_day(2026, 2, 29).
test(day_zero, [fail])                :- valid_day(2026, 3, 0).
test(month_13, [fail])                :- valid_day(2026, 13, 1).

:- end_tests(valid_day).

%--------------------------------------------------------------------------
% general_validation/5 : lo comun a ingresos y gastos
%--------------------------------------------------------------------------
:- begin_tests(general_validation).

test(valid_data)                       :- general_validation(2026, 3, 9, "Cine", 50).
test(empty_description, [fail])        :- general_validation(2026, 3, 9, "", 50).
test(description_not_string, [fail])   :- general_validation(2026, 3, 9, cine, 50).
test(amount_as_string, [fail])         :- general_validation(2026, 3, 9, "Cine", "50").
test(amount_decimal, [fail])           :- general_validation(2026, 3, 9, "Cine", 2.5).
test(amount_negative, [fail])          :- general_validation(2026, 3, 9, "Cine", -1).
% Documenta la decision actual (Amount >= 0). Si cambias a > 0, cambia este test a [fail].
test(amount_zero)                      :- general_validation(2026, 3, 9, "Cine", 0).
test(year_as_string, [fail])           :- general_validation("2026", 3, 9, "Cine", 50).
test(month_as_text, [fail])            :- general_validation(2026, "marzo", 9, "Cine", 50).
test(day_as_text, [fail])              :- general_validation(2026, 3, "9", "Cine", 50).
test(impossible_date, [fail])          :- general_validation(2026, 2, 30, "Cine", 50).

:- end_tests(general_validation).

%--------------------------------------------------------------------------
% valid_incomes/6
%--------------------------------------------------------------------------
:- begin_tests(valid_incomes).

test(salario)                          :- valid_incomes(2026, 3, 2, "Salario", 1000, salario).
test(ingreso_extra)                    :- valid_incomes(2026, 3, 9, "Beca", 300, ingreso_extra).
test(unknown_type, [fail])             :- valid_incomes(2026, 3, 9, "Beca", 300, foo).
test(expense_type_not_allowed, [fail]) :- valid_incomes(2026, 3, 9, "Beca", 300, deseo).
test(bad_date, [fail])                 :- valid_incomes(2026, 4, 31, "Beca", 300, salario).
test(income_types, all(T == [salario, ingreso_extra])) :- income_type(T).

:- end_tests(valid_incomes).

%--------------------------------------------------------------------------
% valid_expenses/6
%--------------------------------------------------------------------------
:- begin_tests(valid_expenses).

test(necesidad)                        :- valid_expenses(2026, 3, 2, "Super mercado", 200, necesidad).
test(deseo)                            :- valid_expenses(2026, 3, 3, "Restaurante", 500, deseo).
test(unknown_type, [fail])             :- valid_expenses(2026, 3, 9, "Cine", 50, foo).
test(income_type_not_allowed, [fail])  :- valid_expenses(2026, 3, 9, "Cine", 50, salario).
test(bad_date, [fail])                 :- valid_expenses(2026, 2, 29, "Cine", 50, deseo).
test(leap_date, [nondet])              :- valid_expenses(2028, 2, 29, "Cine", 50, deseo).
test(expense_types, all(T == [necesidad, deseo])) :- expenses_type(T).

:- end_tests(valid_expenses).