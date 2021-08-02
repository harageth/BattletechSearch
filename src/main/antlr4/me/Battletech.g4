grammar Battletech;

/*
 * Parser Rules
 * Parser Rules are what we get in the code out of this.

 [descriptors] unit ignore quantity mechEquipments [logical expression] quantity mechEquipments
 Mechs with mutliple Large Lasers
 Units with at least 3 PPC's
 */
//mechs with 4 medium lasers
query: line+ EOF ;
equipmentChunk: comparator? QUANTITY WORD* logicaloperator? | QUANTITY comparator? WORD* logicaloperator? ;
line: equipmentChunkWrapper | (WORD? unit STOPWORD equipmentChunk* NEWLINE);
equipmentChunkWrapper: equipmentChunk+ ;
unit: GENERICUNIT | MECH | VEHICLE | VTOL | TANK | WHEELED | TRACKED | HOVERCRAFT ;
comparator: ATLEAST | EQUAL | LESSTHANCOMPARATOR | GREATERTHANCOMPARATOR | NOMORE ;
logicaloperator: AND | OR ;
//weightclass: ULTRA LIGHT | LIGHT | MEDIUM | HEAVY | ASSAULT | ULTRA HEAVY ;


/*
 * Lexer Rules
 * Lexer Rules are how we are chunking the data in the first place
 */

fragment M          : ('M'|'m') ;
fragment E          : ('E'|'e') ;
fragment C          : ('C'|'c') ;
fragment V          : ('V'|'v') ;
fragment I          : ('I'|'i') ;
fragment L          : ('L'|'l') ;
fragment O          : ('O'|'o') ;
fragment P          : ('P'|'p') ;
fragment R          : ('R'|'r') ;
fragment U          : ('U'|'u') ;
fragment W          : ('W'|'w') ;
fragment D          : ('D'|'d') ;
fragment K          : ('K'|'k') ;
fragment F          : ('F'|'f') ;
fragment G          : ('G'|'g') ;
fragment Y          : ('Y'|'y') ;
fragment S          : ('S'|'s') ;
fragment X          : ('X'|'x') ;
fragment Q          : ('Q'|'q') ;
fragment B          : ('B'|'b') ;
fragment T          : ('T'|'t') ;
fragment H          : ('H'|'h') ;
fragment A          : ('A'|'a') ;
fragment N          : ('N'|'n') ;

fragment LOWERCASE  : [a-z] ;
fragment UPPERCASE  : [A-Z] ;



//SIZEDUNIT: WEIGHTCLASS UNIT;
//unit types
//UNIT: GENERICUNIT [s]* | MECH [s]* | VEHICLE [s]* | VTOL [s]* | TANK [s]* | WHEELED [s]* | TRACKED [s]* | HOVERCRAFT [s]* ;
MECH: M E C H [s]* ;
VEHICLE: V E H I C L E S* | V E E [s]* ;
VTOL: V T O L [s]* | H E L I C O P T E R [s]* | H E L O [s]* ;
HOVERCRAFT: H O V E R C R A F T [s]* | H O V E R T A N K [s]* ;
WHEELED: W H E E L E D [s]* ;
TRACKED: T R A C K E D [s]* ;
TANK: HOVERCRAFT [s]* | WHEELED [s]* | TRACKED [s]* ;
GENERICUNIT: U N I T S* ;


// quantity values
QUANTITY: DIGIT | NUMBER | MULTIPLE ;
MULTIPLE: M U L T I P L E ;
ONE: O N E | S I N G L E | A; // SINGLE?
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

/*WEIGHTCLASS: ULTRA [ ] LIGHT | LIGHT | MEDIUM | HEAVY | ASSAULT | ULTRA [ ] HEAVY ;
fragment LIGHT: L I G H T ;
fragment MEDIUM: M E D I U M ;
fragment HEAVY: H E A V Y ;
fragment ASSAULT: A S S A U L T ;
fragment ULTRA: U L T R A ;
fragment ULTRALIGHT: ULTRA LIGHT ;
fragment ULTRAHEAVY: ULTRA HEAVY ;*/


// Mechs with less than 4 medium lasers
// mechs with fewer than 4 medium lasers
// mechs with 4 or less medium lasers
// mechs with 4 or fewer medium lasers


ATLEAST: A T [ ] L E A S T | ORMORE;
NOMORE: N O  [ ] M O R E | N O [ ] M O R E [ ] THAN | A T [ ] M O S T ;
EQUAL: E Q U A L | [=] | E X A C T L Y ;
LESSTHANCOMPARATOR: LESSTHAN |  FEWERTHAN ;
GREATERTHANCOMPARATOR: GREATERTHAN ;
fragment FEWERTHAN: FEWER [ ] THAN | OR [ ] FEWER ;
fragment LESSTHAN: LESS [ ] THAN | OR [ ] LESS ;
fragment GREATERTHAN: GREATER [ ] THAN ;
fragment ORMORE: OR [ ] M O R E;
fragment LESS: L E S S ;
fragment FEWER: F E W E R ;
fragment GREATER: G R E A T E R ;
fragment THAN: T H A N ;


STOPWORD: WITH ;
WITH : W I T H ;


AND: A N D ;
OR: O R ;

/*
fragment AOW: A G E [ ] O F [ ] W A R ;
fragment

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

NEWLINE             : ('r'? 'n' | 'r')+ ;
WORD: [a-zA-Z0-9\-/]+ ;
WHITESPACE : ' ' -> skip ;
