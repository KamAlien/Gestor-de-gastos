%===============================================================
% DATOS BASICOS
%===============================================================

% GASTOS (Y, M, D, DESCRIPTION, MONTO, CATEGORIA)
:- dynamic expenses/7.
expenses(2026, 2, 28, "Renta", 1000, necesidad, "alquiler").
expenses(2026, 3, 1, "Renta", 1000, necesidad, "alquiler").
expenses(2026, 3, 2, "Super mercado", 200, necesidad, "super mercado").
expenses(2026, 3,3, "Restaurante", 500, deseo, "salidas").
expenses(2026, 3, 4, "Doctor", 100, necesidad, "hospital").

% INGRESOS (Y, M, D, DESCRIPTION, MONTO, TIPO DE INGRESO)

:- dynamic incomes/6.

incomes(2026, 3, 2, "Salario", 1000, salario).
incomes(2026, 3, 3, "Venta", 500, ingreso_extra).
incomes(2026, 3, 4, "Regalo", 200, ingreso_extra).

% AJUSTES DE AHORRO (Y, M , D, MONTO)

:- dynamic savings_adjustments/4.

savings_adjustments(2026, 3, 5, 100).
savings_adjustments(2026, 3, 6, -50).
savings_adjustments(2026, 3, 7, 200).