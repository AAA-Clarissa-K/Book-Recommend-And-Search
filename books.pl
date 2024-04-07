% First time starting: start(Ans).

% Initializing imports
:- 
    [gendb1],
    [recommend],
    initdb.

% Queries to retrieve book information:
% isbn_book(ISBN, Title, Author, Publish_Year, Publisher, ImageLinkS, ImageLinkM, ImageLinkL).
% db(ID, field, value).

% Note: limitation of since different datasets do not necessarily have values for all fields
% We chose to save these as separate datasets and query the appropriate one
% _________________________________________________________
% ask(Q, A) gives answer A to question Q
ask(Q, A) :-
    question(Q, [], A).

% To get the input from a line:
start(Ans) :-
    write('\nFor a book recommendation, type "recommend."\nFor help or example search queries, type "help"\nAsk me: '),
    flush_output(current_output), 
    read_line_to_string(user_input, St),
    string_lower(St, St2),                          % convert string to lowercase
    not(member(St2, ["quit", "quit.", "q", "q."])), % quit or q ends interaction
    (not(member(St2, ["recommend."])),
        (not(member(St2, ["help", "help."])),
        split_string(St2, " -", " ,?.!-", Ln),      % ignore punctuation
            (limit(10, ask(Ln, Ans)) ;              % Limits to 10 answers max
            write('No more answers\n'),
            start(Ans)) ;
        member(St2, ["help", "help."]),
        help,
        start(Ans)) ;
    recommend).

% type in 'help' to get a list of possible queries
help :-
    write('\nPossible Questions:\n'),
    write('Who is the author of xxxxxx? / Who wrote xxxxxx?\n'),
    write('What are all the books by xxxxx?\n'),
    write('What is the title of the book with ISBN xxxxx?\n'),
    write('What books were published in xxxxx?\n'),
    write('What does the cover of xxxxxx look like?\n\n').

%_______________________________________________________________________________
% question(Question, QR, Ind) is true if Ind is an answer to Question
question(["who", "wrote" | L0], _, Ind) :-  % Who wrote the kite runner?
    isbn_author_of(L0, Ind).
question(["who", "wrote" | L0], _, Ind) :-  % Who wrote the kite runner?
    genre_author_of(L0, Ind).
question(["who", "is" | L0], L1, Ind) :-           % Who is the author of To Kill a Mockingbird?
    noun_phrase(L0, L1, Ind).
question(["what", "is" | L0], L1, Ind) :-    % What is the title of the book with ISBN 1550135570
    noun_phrase(L0, L1, Ind).
question(["what", "is", "a", "book", "with" | L0], L1, Ind) :-    % What is a book with a rating of exactly 4.6?
    noun_phrase(L0, L1, Ind).
question(["what", "are" | L0], L1, Ind) :-   % what are all the books by harper lee?
     noun_phrase(L0, L1, Ind).
question(["what", "does" | L0], L1, Ind) :-  % what does the cover of to kill a mockingbird look like?
    noun_phrase(L0, L1, Ind).

%_______________________________________________________________________________
% noun_phrase(L0,L4,Ind) is true if
%  L0 and L4 are list of words, such that
%        L4 is an ending of L0
%        the words in L0 before L4 (written L0-L4) form a noun phrase
%  Ind is an individual that the noun phrase is referring to

% A noun phrase is a determiner followed by adjectives followed
% by a noun followed by an optional modifying phrase:
noun_phrase(L0, L2, Ind) :-
    det(L0, L1, Ind),
    noun(L1, L2, Ind).

% Determiners (articles)
det(["the" | L], L, _).
det(["a" | L], L, _).
det(L, L, _).

% Conjunctions (articles)
conj(["and" | L], L, _).
conj(["that" | L], L, _).
conj(L, L, _).

% A modifying phrase / relative clause is either
% a relation (verb or preposition) followed by a noun_phrase or
mp(L0, L2, Ind) :-
    noun_phrase(L0, L1, Ind), 
    aphrase(L1, L2, Ind).
mp(["that" | L0], L2, Ind) :-
    noun_phrase(L0, L1, Ind),
    aphrase(L1, L2, Ind).

% a phrase is a noun_phrase or a modifying phrase
% note that this uses 'aphrase' because 'phrase' is a static procedure in SWI Prolog
aphrase(L0, L1, E) :- noun_phrase(L0, L1, E). 
% aphrase(L0, L1, E) :- mp(L0, L1, E).

%_______________________________________________________________________________
% nouns
noun(["author", "of" | L0], _, Ind) :- % who is the author of to kill a mockingbird? in isbn dataset
    isbn_author_of(L0, Ind).
noun(["author", "of" | L0], _, Ind) :- % who is the author of the complete novel of sherlock holmes? in genre dataset
    genre_author_of(L0, Ind).

noun(["books", "by" | L0], _, Ind) :- % What are all the books by harper lee?
    isbn_books_by_author(L0, Ind).
noun(["books", "by" | L0], _, Ind) :- % who is the author of to kill a mockingbird?
    genre_books_by_author(L0, Ind).

noun(["genre", "of" | L0], _, Ind) :-
    genre_of(L0, Ind).
noun(["title", "of", "the", "book", "with", "isbn" | L0], _, Ind) :- % What is the title of the book with ISBN 1550135570?
    title_by_ISBN(L0, Ind).
noun(["publishing", "year", "of" | B0], _, Ind) :-
    publish_year(B0, Ind).
noun(["published", "in" | Y0], _, Ind) :-
    books_published_in(Y0, Ind).
noun(["cover", "of" | L0], _, Ind) :-   % what does the cover of to kill a mockingbird look like?
    append(Title, ["look", "like"], L0),
    book_cover(Title, Ind).

noun(["rating", "of", "exactly" | L0], _, Ind) :-
    book_rating_exact(L0, Ind).
noun(["rating", "higher", "than" | L0], _, Ind) :-
    book_rating_higher(L0, Ind).
noun(["rating", "lower", "than" | L0], _, Ind) :-
    book_rating_lower(L0, Ind).

% Answers search queries relevant to isbn_book
isbn_author_of(L0, Ans) :- 
    atomic_list_concat(L0, ' ', Title),
    isbn_book(_, Title, Ans, _, _, _, _, _).

isbn_books_by_author(L0, Ans) :- 
    atomic_list_concat(L0, ' ', Author),
    isbn_book(_, Ans, Author, _, _, _, _, _).

title_by_ISBN(L0, Ans) :-
    atomic_list_concat(L0, ' ', ISBN_string),
    atom_number(ISBN_string, ISBN),         % convert string to number, 
    isbn_book(ISBN, Ans, _, _, _, _, _, _).

books_published_in(L0, Ans) :-              % find books published in specified year
    atomic_list_concat(L0, ' ', Year_String),
    atom_number(Year_String, Year),
    isbn_book(_, Ans, _, Year, _, _, _, _).

publish_year(L0, Ans) :-                    % find publish year of specified book
    atomic_list_concat(L0, ' ', Title),
    isbn_book(_, Title, _, Ans, _, _, _, _).

book_cover(L0, Ans) :-                      % find the link to cover of specified book
    atomic_list_concat(L0, ' ', Title),
    isbn_book(_, Title, _, _, _, _, _, Ans).
%_______________________________________________________________________________ data set 2
% Answers search queries relevant to genre_book
genre_author_of(L0, Ans) :- 
    atomic_list_concat(L0, ' ', Title),
    db(ID, title, T),
    string_lower(T, Title),
    db(ID, author, Ans).

genre_books_by_author(L0, Ans) :- 
    atomic_list_concat(L0, ' ', Author),
    db(ID, title, Ans),
    db(ID, author, A),
    string_lower(A, Author).

genre_of(L0, Ans) :- 
    atomic_list_concat(L0, ' ', Title),
    db(ID, title, T),
    string_lower(T, Title),
    db(ID, genre, Ans).

book_rating_exact(L0, Ans) :-            % find book with specific rating
    atomic_list_concat(L0, ' ', Rating_String),
    atom_number(Rating_String, Rating),
    db(ID, rating, Rating),
    db(ID, title, Ans).
book_rating_higher(L0, Ans) :-              % find genre_book with rating of at least 
    atomic_list_concat(L0, ' ', Rating_String),
    atom_number(Rating_String, Min),
    atom_number(Rating, Rating_Number),
    Min < Rating_Number,
    db(ID, rating, Rating),
    db(ID, title, Ans).
book_rating_lower(L0, Ans) :-              % find book with rating of at least 
    atomic_list_concat(L0, ' ', Rating_String),
    atom_number(Rating_String, Max),
    atom_number(Rating, Rating_Number),
    Max > Rating_Number,
    Rating_Number > 0,
    db(ID, rating, Rating),
    db(ID, title, Ans).
