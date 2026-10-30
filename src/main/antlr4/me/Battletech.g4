grammar Battletech;

/*
 * Parser Rules
 * Parser Rules are what we get in the code out of this.

 [descriptors] unit ignore quantity mechEquipments [logical expression] quantity mechEquipments
 Mechs with mutliple Large Lasers
 Units with at least 3 PPC's
 */
//mechs with 4 medium lasers
query: line NEWLINE? EOF ;
equipmentChunk: comparator? QUANTITY equipmentName logicaloperator? | QUANTITY comparator equipmentName logicaloperator? ;
// "lrm 20", "streak srm 6": a name can end in one number. A number followed by another word starts
// the next chunk instead, so "2 ppc 3 srm6" is still two chunks
equipmentName: WORD+ QUANTITY? ;
line: equipmentChunk+ | (weightClasses? unit? STOPWORD equipmentChunk+) ;
// "ultra light", "medium or heavy", "light, medium, or heavy": a unit in any of them; "and" reads the
// same ("light and medium mechs")
weightClasses: weightClass ((COMMA | COMMA? logicaloperator) weightClass)* ;
weightClass: WORD+ ;
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

// between the words of a multi-word token ("at least", "that have"): any number of spaces or tabs
fragment GAP        : [ \t]+ ;
fragment LOWERCASE  : [a-z] ;
fragment UPPERCASE  : [A-Z] ;



//SIZEDUNIT: WEIGHTCLASS UNIT;
//unit types
//UNIT: GENERICUNIT [s]* | MECH [s]* | VEHICLE [s]* | VTOL [s]* | TANK [s]* | WHEELED [s]* | TRACKED [s]* | HOVERCRAFT [s]* ;
MECH: M E C H S* ;
VEHICLE: V E H I C L E S* | V E E S* ;
VTOL: V T O L S* | H E L I C O P T E R S* | H E L O S* ;
HOVERCRAFT: H O V E R C R A F T S* | H O V E R T A N K S* ;
WHEELED: W H E E L E D S* ;
TRACKED: T R A C K E D S* ;
// every ground vehicle (dtype Tank), whatever its motive type
TANK: T A N K S* ;
GENERICUNIT: U N I T S* ;


// quantity values
QUANTITY: DIGIT | NUMBER | MULTIPLE | ANY ;
fragment MULTIPLE: M U L T I P L E ;
// "any lasers": at least one
fragment ANY: A N Y ;
fragment ONE: O N E | S I N G L E | A; // SINGLE?
fragment TWO: T W O | D O U B L E ; // DOUBLE?
fragment THREE: T H R E E | T R I P L E T | T R I P L E;
fragment FOUR: F O U R ;
fragment FIVE: F I V E ;
fragment SIX: S I X ;
fragment SEVEN:  S E V E N ;
fragment EIGHT: E I G H T ;
fragment NINE: N I N E ;
fragment TEN: T E N ;
fragment NUMBER: ONE | TWO | THREE | FOUR | FIVE | SIX | SEVEN | EIGHT | NINE | TEN ;
fragment DIGIT: [0-9]+ ;

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


ATLEAST: A T GAP L E A S T | O R GAP M O R E ;
NOMORE: N O GAP M O R E | N O GAP M O R E GAP THAN | A T GAP M O S T | O R GAP FEWER | O R GAP LESS ;
EQUAL: E Q U A L | [=] | E X A C T L Y ;
LESSTHANCOMPARATOR: LESSTHAN |  FEWERTHAN ;
GREATERTHANCOMPARATOR: GREATERTHAN ;
fragment FEWERTHAN: FEWER GAP THAN ;
fragment LESSTHAN: LESS GAP THAN ;
fragment GREATERTHAN: GREATER GAP THAN ;
fragment LESS: L E S S ;
fragment FEWER: F E W E R ;
fragment GREATER: G R E A T E R ;
fragment THAN: T H A N ;


// between the unit and the weapons: "mechs with", "mechs having", "mechs that have", "mechs armed with"
STOPWORD: WITH | H A V I N G | T H A T GAP H A V E | W H I C H GAP H A V E | C A R R Y I N G | A R M E D GAP WITH ;
WITH : W I T H ;


AND: A N D ;
OR: O R ;
COMMA: ',' ;

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

NEWLINE             : ('\r'? '\n' | '\r')+ ;
WORD: [a-zA-Z0-9\-/]+ ;
WHITESPACE : [ \t]+ -> skip ;
