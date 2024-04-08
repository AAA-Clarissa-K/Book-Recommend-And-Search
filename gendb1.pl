% First time starting: start.
:- use_module(library(csv)).

load_isbn_book(Filename) :-
    csv_read_file(Filename, Rows, [functor(isbn_book), arity(8)]), % Read the CSV file into Rows
    maplist(assert_isbn_book, Rows). % Assert each row as a book fact

% Define the predicate to assert book facts into the knowledge base.
% Asserting books for dataset 1
assert_isbn_book(isbn_book(ISBN, Title, Author, Publish_Year, Publisher, _, _, ImageLink)) :-
    assert( isbn_book(ISBN, title, Title) ), 
    assert( isbn_book(ISBN, author, Author) ),
    assert( isbn_book(ISBN, publishYear, Publish_Year) ),
    assert( isbn_book(ISBN, publisher, Publisher) ),
    assert( isbn_book(ISBN, imageLink, ImageLink) ).

% Load the CSV file into the knowledge base
:-  
    write('Generating Database 1...\n'),
    load_isbn_book('dataset1.csv'),
    write('Database 1 completed loading\n').