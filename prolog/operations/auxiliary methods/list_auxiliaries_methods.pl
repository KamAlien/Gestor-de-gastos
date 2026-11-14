%===================================================================================================
% METODOS AUXILIARES PARA LAS LISTAS
%===================================================================================================

% Devuelve el primer elemento de una lista y la lista sin este
pop(L, R, X):-
    L = [First_element | Rest],
    R = Rest,
    X = First_element.

% Se le agrega un elemento al incio de la lista
push(X, L, R):-
    R = [X | L].

% Se le añade un elemento al final de la lista
add(X, L, R):-
    concatenar(L, [X], R).

% Une 2 listas
concatenar([], L, L).
concatenar([X | L1], L2, [X | R]):- concatenar(L1, L2, R).
