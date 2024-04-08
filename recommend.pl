% First time starting: recommend.
% Note: each answer needs to end in '.' eg. 2.

:- [gendb2]. 

recommend :- 
    write('\nHello! Welcome to the book recommender. Please answer the following questions below!'),
    write('\nBe sure to end each answer with a "."\n'),
    write('\nInvalid inputs will be interpreted as the "no preference" option.\n'),
    guidingQuestions.

guidingQuestions :-
    ask1,
    read(Ans1), nl,
    cont(Ans1),
    % ask2,
    % read(Ans2), nl
    ask3, nl, 
    read(Ans3), nl,
    cont(Ans3),
    ask4, nl,
    read(Ans4), nl,
    cont(Ans4),
    ask5, nl,
    read(Ans5), nl,
    cont(Ans5),
    % print the first N matched films
    writeln('We recommend following books:\n'),
    forall(limit(10, distinct(recommend(Ans1, Ans3, Ans4, Ans5, B, A))), wFunc(B, A)),
    write('\n\nFor more recommendations, type "recommend."'),
    writeln('To return back to searching, type "search(Ans).').

cont(Ans) :-
    term_string(Ans, St),
    string_lower(St, St2),                          % convert string to lowercase
    not(member(St2, ["quit", "quit.", "q", "q."])).

% format output
wFunc(Title, Author) :- 
    nl,
    write(Title),
    write(' by '),
    write(Author).
%_______________________________________________________________________________
% Guiding questions
ask1 :- 
    writeln('\nWhat genre are you interested in?'),
    writeln('1. Arts, Film & Photography'),
    writeln('2. Business & Economics'),
    writeln('3. Computing, Internet & Digital Media'),
    writeln('4. Crafts, Home & Lifestyle'),
    writeln('5. Fantasy, Horror & Science Fiction'),
    writeln('6. Literature & Fiction'),
    writeln('7. Medicine & Health Sciences'),
    writeln('8. Romance'),
    writeln('9. Sports'),
    writeln('10. Teen & Young Adult'),
    writeln('0. No preference'). 
/*
ask2(Ans) :-
    write('Based on the previous main genre select a sub genre: '), nl,
    (Ans == 1 -> writeln('1. Cinema & Broadcast'), writeln('2. Music'), writeln('3. Theater & Ballet'), writeln('0. No preference'));
    (Ans == 2 -> writeln('1. Analysis & Strategy'), writeln('2. Economics'), writeln('3. Industries'), writeln('0. No preference'));
    (Ans == 3 -> writeln('1. Computer Science'), writeln('2. Databases & Big Data'), writeln('3. Internet & Social Media'), writeln('0. No preference'));
    (Ans == 4 -> writeln('1. Food, Drink & Entertaining'), writeln('2. Gardening & Landscape Design'), writeln('3. Lifestyle & Personal Style Guides'), writeln('0. No preference'));
    (Ans == 5 -> writeln('1. Fantasy'), writeln('2. Horror'), writeln('0. No preference'));
    (Ans == 6 -> writeln('1. Classic Fiction'), writeln('2. Crime, Thriller & Mystery'), writeln('3. Myths, Legends & Sagas'), writeln('0. No preference'));
    (Ans == 7 -> writeln('1. Administration & Policy'), writeln('2. Nursing'), writeln('3. Research'), writeln('0. No preference'));
    (Ans == 8 -> writeln('1. Clean & Wholesome'), writeln('2. Enemies to Lovers'), writeln('3. Romantic Comedy'), writeln('0. No preference'));
    (Ans == 9 -> writeln('1. Athletics & Gymnastics'), writeln('2. Combat Sports & Self-Defence'), writeln('3. Field Sports'), writeln('0. No preference'));
    (Ans == 10 -> writeln('1. Romance'), writeln('2. Science Fiction & Fantasy'), writeln('3. Theater & Ballet'), writeln('0. No preference')).
*/
ask3 :-
    writeln('What type of book do you prefer? '),
    writeln('1. Paperback'), 
    writeln('2. Kindle Edition'), 
    writeln('3. Hardcover'), 
    write('0. No preference').

ask4 :-
    writeln('What type of rating do you prefer?'),
    writeln('1. Poorly rated (< 3.0 out of 5.0)'), 
    writeln('2. Well rated (>= 3.0 out of 5.0)'),
    write('0. No preference').

% cutoff is 5000+ is popular
ask5 :-
    writeln('Do you prefer popular books? '),
    writeln('1. Yes'), 
    writeln('2. No'), 
    write('0. No preference').

%_______________________________________________________________________________
% Processing inputs
% q1(0, _) is always true since no preference
q1(0, _).
% q1(1, N) is true if book N has corresponding main genre
q1(1, ID) :-
    db(ID, maingenre, 'Arts, Film & Photography').
q1(2, ID) :-  
    db(ID, maingenre, 'Business & Economics'). 
q1(3, ID) :-  
    db(ID, maingenre, 'Computing, Internet & Digital Media'). 
q1(4, ID) :-  
    db(ID, maingenre, 'Crafts, Home & Lifestyle'). 
q1(5, ID) :-  
    db(ID, maingenre, 'Fantasy, Horror & Science Fiction').
q1(6, ID) :-  
    db(ID, maingenre, 'Literature & Fiction'). 
q1(7, ID) :-  
    db(ID, maingenre, 'Medicine & Health Sciences'). 
q1(8, ID) :-  
    db(ID, maingenre, 'Romance'). 
q1(9, ID) :-  
    db(ID, maingenre, 'Sports').
q1(10, ID) :-  
    db(ID, maingenre, 'Teen & Young Adult'). 
% handle invalid input
q1(Op, _) :- 
    not(member(Op, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])). 

% book type
q3(0, _).
q3(1, ID) :-
    db(ID, type, 'Paperback').
q3(2, ID) :-
    db(ID, type, 'Kindle Edition').
q3(3, ID) :-
    db(ID, type, 'Hardcover').
% handle invalid input
q3(Op, _) :- 
    not( member(Op, [0, 1, 2, 3]) ). 

% ratings 
q4(0, _).
q4(1, ID) :-
    db(ID, rating, X),
    X < 3.0.
q4(2, ID) :-
    db(ID, rating, X),
    X >= 3.0.
% handle invalid input
q4(Op, _) :- 
    not(member(Op, [0, 1, 2])). 

% q4(1, ID) is true if votes >= 5000
q5(1, ID) :-
    db(ID, votes, S),
    S >= 5000.
q5(2, ID) :-
    db(ID, votes, S),
    S < 5000.
q5(0, _).
% handle invalid input
q5(Op, _) :-
    not(member(Op, [0, 1, 2])). 

%_______________________________________________________________________________
%   to add more questions, add another parameter and define all possible qn()'s for that question
recommend(Ans1, Ans3, Ans4, Ans5, BookName, Author) :-
    db(ID, title, BookName),
    db(ID, author, Author),
    q1(Ans1, ID),
    %q2(Ans2, ID),
    q3(Ans3, ID),
    q4(Ans4, ID),
    q5(Ans5, ID). 
