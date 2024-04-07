:- use_module(library(persistency)).
:- persistent(db(id:atom, property:atom, value:atom)).

% generate book knowledge base from provided csv file
% CSV files of book datasets obtained here: 
% recommender system dataset2 based on: https://www.kaggle.com/datasets/chhavidhankhar11/amazon-books-dataset/data
% new dataset processed.

initdb :-
    open('dataset2.csv', read, Stream), 
    parseGenreBooks(Stream), 
    close(Stream). 

% do nothing if at the end of stream
parseGenreBooks(Stream) :- 
    at_end_of_stream(Stream). 

parseGenreBooks(Stream) :-
    \+ at_end_of_stream(Stream),
    csv_options(Options, [arity(8)]),
    csv_read_row(Stream, Row, Options), 
    addInfo(Row), 
    parseGenreBooks(Stream). 

% add info contained in Row into knowledge base
addInfo(Row) :-
    % convert terms into lists
    Row =.. [_, ID, Title, Author, MainGenre, SubGenre, Type, Rating, Votes], 
    addBook(ID, Title, Author, MainGenre, SubGenre, Type, Rating, Votes).  

% skip books with < 100 votes
addBook(_,_,_,_,_,_,_,Votes) :- 
    Votes < 100.  

addBook(ID, Title, Author, MainGenre, SubGenre, Type, Rating, Votes) :-
    assert( db(ID, title, Title) ), 
    assert( db(ID, author, Author) ),
    assert( db(ID, maingenre, MainGenre) ),
    assert( db(ID, subgenre, SubGenre) ),
    assert( db(ID, type, Type) ), 
    assert( db(ID, rating, Rating) ), 
    assert( db(ID, votes, Votes) ).
