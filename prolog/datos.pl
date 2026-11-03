%===============================================================
% DATOS BASICOS
%===============================================================

% GASTOS (Y, M, D, DESCRIPTION, MONTO, CATEGORIA)
:- dynamic expenses/6.

expenses(2026, 3, 2, "Super mercado", 200, necesidad).
expenses(2026, 3,3, "Restaurante", 500, deseo).
expenses(2026, 3, 4, "Doctor", 100, necesidad).

% INGRESOS (Y, M, D, DESCRIPTION, MONTO, TIPO DE INGRESO)

:- dynamic incomes/6.

incomes(2026, 3, 2, "Salario", 1000, salario).
incomes(2026, 3, 3, "Venta", 500, ingreso_extra).
incomes(2026, 3, 4, "Regalo", 200, ingreso_extra).