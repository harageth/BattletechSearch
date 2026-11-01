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
// A unit alone is a whole query ("lams", "heavy omni mechs"); "without ..." can stand in for "with".
// The unit alternatives come first: "lams" could also be a number-less chunk naming "lams", and ANTLR
// takes the first alternative that fits. Units can be left out by body plan or type: "non-lam mechs",
// "mechs except lams and quads", "units that aren't vtols".
line: unitWords exceptUnits? (STOPWORD chunks | withoutChunks)?
    | (omni | NONUNIT)* weightClasses? (omni | NONUNIT)* STOPWORD chunks
    | chunks ;
unitWords: (omni | NONUNIT)* weightClasses? (omni | NONUNIT)* unit ;
exceptUnits: EXCEPT unit ((COMMA | COMMA? logicaloperator) unit)* ;
// A chunk can leave out its number ("endo steel", "ppcs": at least one) only first or right after
// "and" / "or", so "2 ppc 3 srm6" still splits into two chunks. Chunks with nothing between them are
// ANDed. "with" can come again to end a list of things the unit is without ("without ppcs or lasers
// but with 2 lrm 20").
chunks: lead more* ;
withoutChunks: withoutChunk more* ;
lead: chunk | bareChunk | STOPWORD (chunk | bareChunk) ;
more: logicaloperator lead | chunk | STOPWORD (chunk | bareChunk) ;
chunk: equipmentChunk | withoutChunk | ratingChunk ;
// equipment or a component ("an xl engine")
equipmentChunk: comparator? QUANTITY equipmentName | QUANTITY comparator equipmentName ;
// no number: "endo steel", "lasers" (at least one)
bareChunk: bareName ;
// none of it: "without an xl engine", "no ppcs", "lacking lasers", "but not lasers"; the chunks after
// it are without too ("without ppcs or lasers": neither) until one has its own count or a "with"
withoutChunk: negation QUANTITY? equipmentName ;
negation: WITHOUT | NO | EXCEPT ;
// "an engine rating of at least 300", "engine rating 300 or more"; the word must be "engine"
ratingChunk: QUANTITY? WORD RATING (comparator? QUANTITY | QUANTITY comparator) ;
// "lrm 20", "streak srm 6": a name can end in one number. A number followed by another word starts
// the next chunk instead, so "2 ppc 3 srm6" is still two chunks. Unit words can be part of a name
// ("vehicle flamer", "superheavy tripod cockpit"): in a chunk they can't mean anything else.
equipmentName: (WORD | GENERICUNIT | MECH | VEHICLE | VTOL | TANK | WHEELED | TRACKED | HOVERCRAFT
    | BIPED | QUAD | TRIPOD | LAM | QUADVEE | OMNIMECH)+ QUANTITY? ;
// A name with no number in front starts with a plain word, so "mechs at least 2 ppc" still misses its
// "with" instead of reading "mechs" as a name
bareName: WORD (WORD | GENERICUNIT | MECH | VEHICLE | VTOL | TANK | WHEELED | TRACKED | HOVERCRAFT
    | BIPED | QUAD | TRIPOD | LAM | QUADVEE | OMNIMECH)* QUANTITY? ;
// "omni mechs", "non-omni vehicles"
omni: OMNI | NONOMNI ;
// "ultra light", "medium or heavy", "light, medium, or heavy": a unit in any of them; "and" reads the
// same ("light and medium mechs")
weightClasses: weightClass ((COMMA | COMMA? logicaloperator) weightClass)* ;
weightClass: WORD+ ;
// A motive type alone or before a vehicle word: "tracked", "tracked vehicles", "tracked vees", "hover
// tanks"; "vtol vehicles" too. The first word decides (QueryVisitor.visitUnit).
unit: GENERICUNIT | MECH | VEHICLE | VTOL VEHICLE? | TANK | (WHEELED | TRACKED | HOVERCRAFT) (VEHICLE | TANK)?
    | BIPED | QUAD | TRIPOD | LAM | QUADVEE | OMNIMECH ;
comparator: ATLEAST | EQUAL | LESSTHANCOMPARATOR | GREATERTHANCOMPARATOR | NOMORE ;
// "but" is "and": "with 2 ppc but no lasers"
logicaloperator: AND | OR | BUT ;
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
// Each unit word's spellings are a fragment, shared by its token and by NONUNIT, so every spelling
// works after "non-" too ("non-hover", "non-helicopter")
MECH: MECHWORD S* ;
VEHICLE: VEHICLEWORD S* ;
VTOL: VTOLWORD S* ;
HOVERCRAFT: HOVERCRAFTWORD S* ;
WHEELED: WHEELEDWORD S* ;
TRACKED: TRACKEDWORD S* ;
// every ground vehicle (dtype Tank), whatever its motive type
TANK: TANKWORD S* ;
GENERICUNIT: U N I T S* ;
// mechs by body plan (unit.locomotion); "quadvees" is the longer match over "quad"
BIPED: BIPEDWORD S* ;
QUADVEE: QUADVEEWORD S* ;
QUAD: QUADWORD S* ;
TRIPOD: TRIPODWORD S* ;
LAM: LAMWORD S* ;
fragment MECHWORD: M E C H ;
fragment VEHICLEWORD: V E H I C L E | V E E ;
fragment VTOLWORD: V T O L | H E L I C O P T E R | H E L O ;
fragment HOVERCRAFTWORD: H O V E R C R A F T | H O V E R T A N K | H O V E R ;
fragment WHEELEDWORD: W H E E L E D ;
fragment TRACKEDWORD: T R A C K E D ;
fragment TANKWORD: T A N K ;
fragment BIPEDWORD: B I P E D ;
fragment QUADVEEWORD: Q U A D V E E ;
fragment QUADWORD: Q U A D ;
fragment TRIPODWORD: T R I P O D ;
fragment LAMWORD: L A M ;
// OmniMechs; "omni" on its own goes in front of any unit word
OMNIMECH: O M N I M E C H S* | O M N I M E K S* | O M N I S ;
OMNI: O M N I ;
NONOMNI: N O N '-' O M N I | N O N GAP O M N I | N O N O M N I ;
// "non-lam", "non-quad", "non-vtol": any unit word but those (one token, or "non-lam" lexes as a WORD)
NONUNIT: N O N ('-' | GAP)? (BIPEDWORD | QUADVEEWORD | QUADWORD | TRIPODWORD | LAMWORD | MECHWORD | VEHICLEWORD
    | VTOLWORD | TANKWORD | WHEELEDWORD | TRACKEDWORD | HOVERCRAFTWORD) S* ;


// quantity values
QUANTITY: DIGIT | NUMBER | MULTIPLE | ANY ;
fragment MULTIPLE: M U L T I P L E ;
// "any lasers": at least one
fragment ANY: A N Y ;
fragment ONE: O N E | S I N G L E | A | A N; // SINGLE?
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
// none of it; also starts the chunks in place of "with" ("mechs without ppcs", "mechs lacking ppcs")
WITHOUT: W I T H O U T | L A C K I N G
    | (T H A T | W H I C H) GAP (D O N '\''? T | D O GAP N O T) GAP H A V E ;
// "with no ppcs", "but no lasers"; "no more than" is the longer match and stays a comparator
NO: N O ;
// "mechs except lams", "mechs that aren't quads"; before a weapon, "but not lasers" is "without lasers"
EXCEPT: E X C E P T | (T H A T | W H I C H) GAP (A R E N '\''? T | A R E GAP N O T) | B U T GAP N O T ;
BUT: B U T ;
// "engine rating 300", "engine rating of at least 300"
RATING: R A T I N G | R A T I N G GAP O F ;


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
