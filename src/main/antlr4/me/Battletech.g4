grammar Battletech;

/*
 * Parser Rules
 * Parser Rules are what we get in the code out of this.

 [descriptors] unit ignore quantity mechEquipments [logical expression] quantity mechEquipments
 Mechs with mutliple Large Lasers
 Units with at least 3 PPC's
 */

query: line+ EOF ;
equipmentChunk: COMPARATOR? QUANTITY EQUIPMENT* | QUANTITY COMPARATOR? EQUIPMENT*;
line: SIZEDUNIT STOPWORD equipmentChunk* NEWLINE ;


//weightclass: ULTRA LIGHT | LIGHT | MEDIUM | HEAVY | ASSAULT | ULTRA HEAVY ;



/*
 * Lexer Rules
 * Lexer Rules are how we are chunking the data in the first place
 */

fragment M          : ('M'|'m') ;
fragment E          : ('E'|'e') ;
fragment C          : ('C'|'c') ;
fragment H          : ('H'|'h') ;
fragment V          : ('V'|'v') ;
fragment I          : ('I'|'i') ;
fragment L          : ('L'|'l') ;
fragment O          : ('O'|'o') ;
fragment T          : ('T'|'t') ;
fragment N          : ('N'|'n') ;
fragment P          : ('P'|'p') ;
fragment R          : ('R'|'r') ;
fragment U          : ('U'|'u') ;
fragment W          : ('W'|'w') ;
fragment A          : ('A'|'a') ;
fragment D          : ('D'|'d') ;
fragment K          : ('K'|'k') ;
fragment F          : ('F'|'f') ;
fragment G          : ('G'|'g') ;
fragment Y          : ('Y'|'y') ;
fragment S          : ('S'|'s') ;
fragment X          : ('X'|'x') ;
fragment Q          : ('Q'|'q') ;
fragment B          : ('B'|'b') ;

fragment LOWERCASE  : [a-z] ;
fragment UPPERCASE  : [A-Z] ;



SIZEDUNIT: WEIGHTCLASS UNIT;
//unit types
UNIT: MECH [s]* | VEHICLE [s]* | VTOL [s]* | TANK [s]* | WHEELED [s]* | TRACKED [s]* | HOVERCRAFT [s]* ;
fragment MECH: M E C H ;
fragment VEHICLE: V E H I C L E | V E E ;
fragment VTOL: V T O L | H E L I C O P T E R | H E L O ;
fragment HOVERCRAFT: H O V E R C R A F T | H O V E R T A N K;
fragment WHEELED: W H E E L E D ;
fragment TRACKED: T R A C K E D ;
fragment TANK: HOVERCRAFT | WHEELED | TRACKED ;


// quantity values
QUANTITY: DIGIT | NUMBER | MULTIPLE ;
MULTIPLE: M U L T I P L E ;
ONE: O N E | S I N G L E ; // SINGLE?
TWO: T W O | D O U B L E ; // DOUBLE?
THREE: T H R E E | T R I P L E T | T R I P L E;
FOUR: F O U R ;
FIVE: F I V E ;
SIX: S I X ;
SEVEN:  S E V E N ;
EIGHT: E I G H T ;
NINE: N I N E ;
TEN: T E N ;
NUMBER: ONE | TWO | THREE | FOUR | FIVE | SIX | SEVEN | EIGHT | NINE | TEN ;
DIGIT: [0-9] ;

//LOWERCASE | UPPERCASE | DIGIT ;

WEIGHTCLASS: ULTRA [ ] LIGHT | LIGHT | MEDIUM | HEAVY | ASSAULT | ULTRA [ ] HEAVY ;
fragment LIGHT: L I G H T ;
fragment MEDIUM: M E D I U M ;
fragment HEAVY: H E A V Y ;
fragment ASSAULT: A S S A U L T ;
fragment ULTRA: U L T R A ;
fragment ULTRALIGHT: ULTRA LIGHT ;
fragment ULTRAHEAVY: ULTRA HEAVY ;


COMPARATOR: ATLEAST | EQUAL | LESSTHAN ;
ATLEAST: A T [ ] L E A S T ;
EQUAL: E Q U A L | [=] | E X A C T L Y ;
LESSTHAN: L E S S [ ] T H A N | [<] ;


STOPWORD: WITH ;
WITH : W I T H | A ;


LOGICALOPERATOR: AND | OR ;
AND: A N D ;
OR: O R ;



/*
Age of War
Star league
Early Succession War
Late Succession War - LosTech
Late Succession War - Renaissance
Clan Invasion
Civil War
Jihad
Early Republic
Late Republic
Dark Age
IlClan
*/
WEAPONSIZE: S M A L L | MEDIUM | L A R G E ;

NEWLINE             : ('r'? 'n' | 'r')+ ;
EQUIPMENT: [a-zA-Z0-9\-/]+ | WEAPONSIZE [ ]* [a-zA-Z0-9\-/]+;
WHITESPACE : ' ' -> skip ;
