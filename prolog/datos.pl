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
savings_adjustments(2026, 3, 8, -100).


% AHORRO POR MESES:
:- dynamic month_saving/3.

month_saving(2026, 3, 100).
month_saving(2026, 4, 200).
month_saving(2026, 5, 100).
month_saving(2026, 6, 5).



% CUENTAS DE AHORRO (LA SUBCATEGORIA PARA GASTOS ES OPCIONAL) 
% CATEGORIA, SUBCATEGORIA, DESCRIPCION, PORCENTAJE DE AHORRO DEL MES
:- dynamic savings_account/4.

savings_account(global, "Cuenta de Ahorro global","Es una cuenta de ahorro global, no responde a ningun tipo de categorias, sino mas bien, el porcentaje del ahorro del mes que se define para esta cuenta es el sobrante de la suma de las cuentas de ahorro. Esta cuenta no se podra eliminar o actualizar.", 70).
savings_account(necesidad, "hospital", "Cualquier tipo de necesidad medica", 20).
savings_account(deseo, "viajes", "Viajes en vacaciones", 10).


% CAMBIOS EN LOS PORCENTAJES : CATEGORIA, SUBCATEGORIA, PORCENTAJE
:- dynamic savings_account_percent/6.
savings_account_percent(2026, 3, 2, global, "Cuenta de Ahorro global", 70).
savings_account_percent(2026, 3, 2, necesidad, "hospital", 20).
savings_account_percent(2026, 3, 2, deseo, "viajes", 10).
