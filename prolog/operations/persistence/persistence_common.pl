:- encoding(utf8).
% Lee un archivo termino por termino hasta el final y devuelve la lista.
read_terms(Stream, Terms):-
    read(Stream, Term),
    (   Term == end_of_file
        -> Terms = []
        ; Terms = [Term | Rest],
        read_terms(Stream, Rest)).

ensure_parent_directory(File):-
    file_directory_name(File, Directory),
    make_directory_path(Directory).
    
    
    