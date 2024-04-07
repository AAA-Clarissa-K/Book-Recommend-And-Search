% First time starting: start.
:- use_module(library(csv)).

load_isbn_book(Filename) :-
    csv_read_file(Filename, Rows, [functor(isbn_book), arity(8)]), % Read the CSV file into Rows
    maplist(assert_isbn_book, Rows). % Assert each row as a book fact

% Define the predicate to assert book facts into the knowledge base.
% Asserting books for dataset 1
% Books in dataset 1 are represented by isbn_book(ISBN, Title, Author, Publish_Year, Publisher, Author_Rating, Book_Rating, Genre)
assert_isbn_book(isbn_book(ISBN, Title, Author, Publish_Year, Publisher, ImageLinkS, ImageLinkM, ImageLinkL)) :-
    assertz(isbn_book(ISBN, Title, Author, Publish_Year, Publisher, ImageLinkS, ImageLinkM, ImageLinkL)).

% Load the CSV file into the knowledge base
:-  
    writeln('Loading book databases...'),
    load_isbn_book('dataset1.csv'),
    writeln('Completed loading!\n\nTo begin, type "start(Ans)"').