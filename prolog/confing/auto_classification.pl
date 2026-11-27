%===========================================================================================================================================================================================================
% DATOS PREDETERMINADOS PARA LA CLASIFICACION AUTOMATICA DE GASTOS
% Esta es configuracion: el usuario puede agregar o eliminar reglas. Todo se escribe SIN TILDES y en minusculas.
% Las pistas son PALABRAS COMPLETAS ("pan" NO coincide con "pantalon"); el plural (s / es) se acepta automaticamente.


% DEFAULT DATA FOR THE AUTOMATIC CLASSIFICATION OF EXPENSES
% This is configuration: the user can add or remove rules. Everything is written WITHOUT accents and in lowercase.
% Hints are WHOLE WORDS ("pan" does NOT match "pantalon"); the plural (s / es) is accepted automatically.
%===========================================================================================================================================================================================================

:- encoding(utf8).
:- dynamic context_exception/3.
:- dynamic text_rule/2.
:- dynamic general_description_category/2.
:- dynamic default_category/1.

default_category(pendiente).

%===========================================================================================================================================================================================================
% CONTEXT EXCEPTIONS: inside a general description, a hint changes the category
%===========================================================================================================================================================================================================
context_exception("hospital", "estetica",   deseo).
context_exception("hospital", "estetico",   deseo).
context_exception("hospital", "plastica",   deseo).
context_exception("hospital", "plastico",   deseo).
context_exception("hospital", "plastico",   deseo).
context_exception("hospital", "botox",      deseo).
context_exception("hospital", "urgencia",    necesidad).
context_exception("hospital", "respiratorio", necesidad).
context_exception("hospital", "dolor",       necesidad).

%===========================================================================================================================================================================================================
% FREQUENT GENERAL DESCRIPTIONS
%===========================================================================================================================================================================================================

general_description_category("alquiler", necesidad).
general_description_category("renta", necesidad).
general_description_category("super mercado", necesidad).
general_description_category("supermercado", necesidad).
general_description_category("mercado", necesidad).
general_description_category("hospital", necesidad).
general_description_category("farmacia", necesidad).
general_description_category("salud", necesidad).
general_description_category("transporte", necesidad).
general_description_category("servicios", necesidad).
general_description_category("salidas", deseo).
general_description_category("restaurante", deseo).
general_description_category("entretenimiento", deseo).
general_description_category("ocio", deseo).
general_description_category("compras", deseo).

%===========================================================================================================================================================================================================
% HINT IN THE TEXT
%===========================================================================================================================================================================================================
% Necesidad
text_rule("alquiler", necesidad).
text_rule("renta", necesidad).
text_rule("hipoteca", necesidad).
text_rule("super", necesidad).
text_rule("supermercado", necesidad).
text_rule("mercado", necesidad).
text_rule("comida", necesidad).
text_rule("pan", necesidad).
text_rule("leche", necesidad).
text_rule("arroz", necesidad).
text_rule("carne", necesidad).
text_rule("pollo", necesidad).
text_rule("verdura", necesidad).
text_rule("fruta", necesidad).
text_rule("agua", necesidad).
text_rule("luz", necesidad).
text_rule("electricidad", necesidad).
text_rule("gas", necesidad).
text_rule("internet", necesidad).
text_rule("telefono", necesidad).
text_rule("celular", necesidad).
text_rule("medicina", necesidad).
text_rule("medicamento", necesidad).
text_rule("doctor", necesidad).
text_rule("medico", necesidad).
text_rule("farmacia", necesidad).
text_rule("pastilla", necesidad).
text_rule("consulta", necesidad).
text_rule("bus", necesidad).
text_rule("guagua", necesidad).
text_rule("metro", necesidad).
text_rule("taxi", necesidad).
text_rule("gasolina", necesidad).
text_rule("combustible", necesidad).
text_rule("limpieza", necesidad).
text_rule("jabon", necesidad).
text_rule("detergente", necesidad).

% Deseo
text_rule("cine", deseo).
text_rule("restaurante", deseo).
text_rule("concierto", deseo).
text_rule("juego", deseo).
text_rule("videojuego", deseo).
text_rule("streaming", deseo).
text_rule("netflix", deseo).
text_rule("spotify", deseo).
text_rule("bar", deseo).
text_rule("cerveza", deseo).
text_rule("trago", deseo).
text_rule("helado", deseo).
text_rule("postre", deseo).
text_rule("dulce", deseo).
text_rule("chocolate", deseo).
text_rule("cafe", deseo).
text_rule("pizza", deseo).
text_rule("hamburguesa", deseo).
text_rule("viaje", deseo).
text_rule("vacaciones", deseo).
text_rule("hotel", deseo).
text_rule("regalo", deseo).
text_rule("adorno", deseo).
text_rule("ropa", deseo).
text_rule("zapato", deseo).
text_rule("perfume", deseo).
text_rule("maquillaje", deseo).