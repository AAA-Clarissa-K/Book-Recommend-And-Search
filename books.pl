% First time starting: start(Ans).

% Initializing imports
:- 
    write('Loading book databases...\n'),
    [gendb1],
    [recommend],
    initdb,
    write('Completed loading databases!\n\n'),
    write('To begin, type "search(Ans)."\n').

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
search(Ans) :-
    write('\nTo get a book recommendation, type "recommend"\nFor help or example search queries, type "help"\nAsk me: '),
    flush_output(current_output), 
    read_line_to_string(user_input, St),
    string_lower(St, St2),                          % convert string to lowercase
    not(member(St2, ["quit", "quit.", "q", "q."])), % quit or q ends interaction
    (member(St2, ["recommend", "recommend."]) -> recommend ;
     member(St2, ["help", "help."]) -> help, search(Ans) ;
     split_string(St2, " -", " ,?.!-", Ln),      % ignore punctuation
        (limit(10, distinct(ask(Ln, Ans))) ;              % Limits to 10 answers max
        write('No more answers\n'),
        search(Ans))).

% type in 'help' to get a list of possible queries
help :-
    write('\nPossible Questions:\n'),
    write('Who is the author of x? / Who wrote x?\n'),
    write('What are all the books by x?\n'),
    write('What is the title of the book with ISBN x?\n'),
    write('Who is the publisher for x?\n'),
    write('What books were published in yyyy?\n'),
    write('What year was x published in?\n'),
    write('What does the cover of x look like?\n\n').

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
    % subj(L1, L2, Ind),
    noun(L1, L2, Ind).
    % mp(L2, L3, Ind).

% Determiners
det(["the" | L], L, _).
det(["a" | L], L, _).
det(L, L, _).

% Referring to book
subj(["book" | L], L, _).
subj(L, L, _).

% A modifying phrase / relative clause is either
% a relation (verb or preposition) followed by a noun_phrase or
mp(L0, L2, Ind) :-
    noun_phrase(L0, L1, Ind), 
    aphrase(L1, L2, Ind).
mp(["and", "is" | L0], L2, Ind) :-
    noun_phrase(L0, L1, Ind),
    aphrase(L1, L2, Ind).
mp(["that", "is" | L0], L2, Ind) :-
    noun_phrase(L0, L1, Ind),
    aphrase(L1, L2, Ind).
mp(L, L, _).

% a phrase is a noun_phrase or a modifying phrase
% note that this uses 'aphrase' because 'phrase' is a static procedure in SWI Prolog
aphrase(L0, L1, E) :- noun_phrase(L0, L1, E). 
aphrase(L0, L1, E) :- mp(L0, L1, E).

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
question(["what", "are", "all" | L0], L1, Ind) :-   % what are all the books by harper lee?
     noun_phrase(L0, L1, Ind).
question(["what", "does" | L0], L1, Ind) :-  % what does the cover of to kill a mockingbird look like?
    noun_phrase(L0, L1, Ind).
question(["what" | L0], L1, Ind) :-  % what books were published in 1999?
    noun_phrase(L0, L1, Ind).
%_______________________________________________________________________________
% facts regarding the author of the book or book by the author
noun(["author", "of" | L0], _, Ind) :- % who is the author of to kill a mockingbird? in isbn dataset
    isbn_author_of(L0, Ind).
noun(["author", "of" | L0], _, Ind) :- % who is the author of the complete novel of sherlock holmes? in genre dataset
    genre_author_of(L0, Ind).

noun(["books", "by" | L0], _, Ind) :- % What are all the books by harper lee? in isbn dataset
    isbn_books_by_author(L0, Ind).
noun(["books", "by" | L0], _, Ind) :- % What are all the books by harper lee? in genre dataset
    genre_books_by_author(L0, Ind).
noun(["books", "written", "by" | L0], _, Ind) :- % What are all the books by harper lee? in isbn dataset
    isbn_books_by_author(L0,Ind).
noun(["books", "written", "by" | L0], _, Ind) :-  % What are all the books by harper lee? in genre dataset
    genre_books_by_author(L0,Ind).

% facts about the genre of a book, or book of that genre
noun(["genre", "of" | L0], _, Ind) :-
    genre_of(L0, Ind).

% facts based on isbn
noun(["title", "of", "the", "book", "with", "isbn" | L0], _, Ind) :- % What is the title of the book with ISBN 1550135570?
    title_by_ISBN(L0, Ind).

% facts based on publishing year
noun(["year", "was" | L0], _, Ind) :-       % What year was to kill a mockingbird published in?
    append(Title, ["published", "in"], L0),
    publish_year(Title, Ind).
noun(["books", "were", "published", "in" | L0], _, Ind) :- % What books were published in 1999?
    books_published_in(L0, Ind).

% facts based on publisher
noun(["publisher", "for" | L0], _, Ind) :- % Who is the publisher for to kill a mockingbird?
    books_publisher(L0, Ind).

% facts about the cover
noun(["cover", "of" | L0], _, Ind) :-   % what does the cover of to kill a mockingbird look like?
    append(Title, ["look", "like"], L0),
    book_cover(Title, Ind).

% facts about book ratings
noun(["rating", "of", "exactly" | L0], _, Ind) :-
    book_rating_exact(L0, Ind).
noun(["rating", "higher", "than" | L0], _, Ind) :-
    book_rating_higher(L0, Ind).
noun(["rating", "lower", "than" | L0], _, Ind) :-
    book_rating_lower(L0, Ind).
%_______________________________________________________________________________
% Answers search queries relevant to isbn_book
isbn_author_of(L0, Ans) :- 
    atomic_list_concat(L0, ' ', Title),
    isbn_book(ISBN, title, T),
    string_lower(T, Title),
    isbn_book(ISBN, author, Ans).

isbn_books_by_author(L0, Ans) :- 
    atomic_list_concat(L0, ' ', Author),
    isbn_book(ISBN, author, A),
    string_lower(A, Author),
    isbn_book(ISBN, title, Ans).

title_by_ISBN(L0, Ans) :-
    atomic_list_concat(L0, ' ', ISBN_string),
    atom_number(ISBN_string, ISBN),         % convert string to number, 
    isbn_book(ISBN, title, Ans).

books_published_in(L0, Ans) :-              % find books published in specified year
    atomic_list_concat(L0, ' ', Year_String),
    atom_number(Year_String, Year),
    isbn_book(ISBN, publishYear, Year),
    isbn_book(ISBN, title, Ans).

books_publisher(L0, Ans) :-                 % find the publisher of a book
    atomic_list_concat(L0, ' ', Title),
    isbn_book(ISBN, title, T),
    string_lower(T, Title),
    isbn_book(ISBN, publisher, Ans).

publish_year(L0, Ans) :-                    % find publish year of specified book
    atomic_list_concat(L0, ' ', Title),
    isbn_book(ISBN, title, T),
    string_lower(T, Title),
    isbn_book(ISBN, publishYear, Ans).

book_cover(L0, Ans) :-                      % find the link to cover of specified book
    atomic_list_concat(L0, ' ', Title),
    isbn_book(ISBN, title, T),
    string_lower(T, Title),
    isbn_book(ISBN, imageLink, Ans).

%_______________________________________________________________________________ data set 2
% Answers search queries relevant to genre_book
genre_author_of(L0, Ans) :- 
    atomic_list_concat(L0, ' ', Title),
    db(ID, title, T),
    string_lower(T, Title),
    db(ID, author, Ans).

genre_books_by_author(L0, Ans) :- 
    atomic_list_concat(L0, ' ', Author),
    db(ID, author, A),
    string_lower(A, Author),
    db(ID, title, Ans).

genre_of(L0, Ans) :- 
    atomic_list_concat(L0, ' ', Title),
    db(ID, title, T),
    string_lower(T, Title),
    db(ID, maingenre, Ans).

book_rating_exact(L0, Ans) :-               % find book with exact rating
    atomic_list_concat(L0, ' ', Rating_String),
    atom_number(Rating_String, Rating),
    db(ID, rating, Rating),
    db(ID, title, Ans).
book_rating_higher(L0, Ans) :-              % find genre_book with rating of at least 
    atomic_list_concat(L0, ' ', Lower),
    atom_number(Lower, Min),
    Min < Rating,
    db(ID, rating, Rating),
    db(ID, title, Ans).
book_rating_lower(L0, Ans) :-              % find book with rating of at least 
    atomic_list_concat(L0, ' ', Upper),
    atom_number(Upper, Max),
    Max > Rating,
    Rating > 0,
    db(ID, rating, Rating),
    db(ID, title, Ans).
