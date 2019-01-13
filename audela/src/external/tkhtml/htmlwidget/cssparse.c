/* Driver template for the LEMON parser generator.
** The author disclaims copyright to this source code.
*/
/* First off, code is include which follows the "include" declaration
** in the input file. */
#include <stdio.h>
#line 41 "cssparse.y"

#include "cssInt.h"
#include <string.h>
#include <ctype.h>
#line 14 "cssparse.c"
/* Next is all token values, in a form suitable for use by makeheaders.
** This section will be null unless lemon is run with the -m switch.
*/
/* 
** These constants (all generated automatically by the parser generator)
** specify the various kinds of tokens (terminals) that the parser
** understands. 
**
** Each symbol here is a terminal symbol in the grammar.
*/
/* Make sure the INTERFACE macro is defined.
*/
#ifndef INTERFACE
# define INTERFACE 1
#endif
/* The next thing included is series of defines which control
** various aspects of the generated parser.
**    YYCODETYPE         is the data type used for storing terminal
**                       and nonterminal numbers.  "unsigned char" is
**                       used if there are fewer than 250 terminals
**                       and nonterminals.  "int" is used otherwise.
**    YYNOCODE           is a number of type YYCODETYPE which corresponds
**                       to no legal terminal or nonterminal number.  This
**                       number is used to fill in empty slots of the hash 
**                       table.
**    YYFALLBACK         If defined, this indicates that one or more tokens
**                       have fall-back values which should be used if the
**                       original value of the token will not parse.
**    YYACTIONTYPE       is the data type used for storing terminal
**                       and nonterminal numbers.  "unsigned char" is
**                       used if there are fewer than 250 rules and
**                       states combined.  "int" is used otherwise.
**    tkhtmlCssParserTOKENTYPE     is the data type used for minor tokens given 
**                       directly to the parser from the tokenizer.
**    YYMINORTYPE        is the data type used for all minor tokens.
**                       This is typically a union of many types, one of
**                       which is tkhtmlCssParserTOKENTYPE.  The entry in the union
**                       for base tokens is called "yy0".
**    YYSTACKDEPTH       is the maximum depth of the parser's stack.
**    tkhtmlCssParserARG_SDECL     A static variable declaration for the %extra_argument
**    tkhtmlCssParserARG_PDECL     A parameter declaration for the %extra_argument
**    tkhtmlCssParserARG_STORE     Code to store %extra_argument into yypParser
**    tkhtmlCssParserARG_FETCH     Code to extract %extra_argument from yypParser
**    YYNSTATE           the combined number of states.
**    YYNRULE            the number of rules in the grammar
**    YYERRORSYMBOL      is the code number of the error symbol.  If not
**                       defined, then do no error processing.
*/
#define YYCODETYPE unsigned char
#define YYNOCODE 67
#define YYACTIONTYPE unsigned short int
#define tkhtmlCssParserTOKENTYPE CssToken
typedef union {
  tkhtmlCssParserTOKENTYPE yy0;
  int yy64;
  int yy133;
} YYMINORTYPE;
#define YYSTACKDEPTH 100
#define tkhtmlCssParserARG_SDECL CssParse *pParse;
#define tkhtmlCssParserARG_PDECL ,CssParse *pParse
#define tkhtmlCssParserARG_FETCH CssParse *pParse = yypParser->pParse
#define tkhtmlCssParserARG_STORE yypParser->pParse = pParse
#define YYNSTATE 166
#define YYNRULE 86
#define YYERRORSYMBOL 29
#define YYERRSYMDT yy133
#define YY_NO_ACTION      (YYNSTATE+YYNRULE+2)
#define YY_ACCEPT_ACTION  (YYNSTATE+YYNRULE+1)
#define YY_ERROR_ACTION   (YYNSTATE+YYNRULE)

/* Next are that tables used to determine what action to take based on the
** current state and lookahead token.  These tables are used to implement
** functions that take a state number and lookahead value and return an
** action integer.  
**
** Suppose the action integer is N.  Then the action is determined as
** follows
**
**   0 <= N < YYNSTATE                  Shift N.  That is, push the lookahead
**                                      token onto the stack and goto state N.
**
**   YYNSTATE <= N < YYNSTATE+YYNRULE   Reduce by rule N-YYNSTATE.
**
**   N == YYNSTATE+YYNRULE              A syntax error has occurred.
**
**   N == YYNSTATE+YYNRULE+1            The parser accepts its input.
**
**   N == YYNSTATE+YYNRULE+2            No such action.  Denotes unused
**                                      slots in the yy_action[] table.
**
** The action table is constructed as a single large table named yy_action[].
** Given state S and lookahead X, the action is computed as
**
**      yy_action[ yy_shift_ofst[S] + X ]
**
** If the index value yy_shift_ofst[S]+X is out of range or if the value
** yy_lookahead[yy_shift_ofst[S]+X] is not equal to X or if yy_shift_ofst[S]
** is equal to YY_SHIFT_USE_DFLT, it means that the action is not in the table
** and that yy_default[S] should be used instead.  
**
** The formula above is for computing the action when the lookahead is
** a terminal symbol.  If the lookahead is a non-terminal (as occurs after
** a reduce action) then the yy_reduce_ofst[] array is used in place of
** the yy_shift_ofst[] array and YY_REDUCE_USE_DFLT is used in place of
** YY_SHIFT_USE_DFLT.
**
** The following are the tables generated in this section:
**
**  yy_action[]        A single table containing all actions.
**  yy_lookahead[]     A table containing the lookahead for each entry in
**                     yy_action.  Used to detect hash collisions.
**  yy_shift_ofst[]    For each state, the offset into yy_action for
**                     shifting terminals.
**  yy_reduce_ofst[]   For each state, the offset into yy_action for
**                     shifting non-terminals after a reduce.
**  yy_default[]       Default action for each state.
*/
static const YYACTIONTYPE yy_action[] = {
 /*     0 */   136,   70,   97,   27,  115,  160,   19,   33,   86,   87,
 /*    10 */    88,   77,  157,  103,  104,  105,  136,   67,  152,   36,
 /*    20 */    79,   80,   28,  153,  136,   40,  253,    1,  116,   53,
 /*    30 */    21,  168,   11,  147,   12,  168,  102,  103,  104,  105,
 /*    40 */   168,  168,  152,   36,  122,  136,   28,  153,   84,  134,
 /*    50 */    12,   13,  124,  136,   21,   19,   11,  147,   12,   46,
 /*    60 */   136,   73,  122,  152,   36,   65,  136,   28,  153,  125,
 /*    70 */    33,   13,   20,  123,  113,   21,   13,   11,  147,   12,
 /*    80 */    46,   66,  128,  130,  152,   36,  135,   12,   28,  153,
 /*    90 */    21,  121,   11,  147,   12,  154,   21,   69,   11,  147,
 /*   100 */    12,   42,  150,  139,   29,   90,   92,   34,  148,   48,
 /*   110 */    70,  127,   96,   16,  150,  136,  149,   86,   87,   88,
 /*   120 */   148,    8,   70,  127,    6,  151,  150,   81,  149,   86,
 /*   130 */    87,   88,  148,   24,   70,  122,   56,   83,  133,   25,
 /*   140 */   149,   86,   87,   88,   72,   21,  122,   11,  147,   12,
 /*   150 */    84,   51,  122,  155,  164,   14,   84,   98,  122,  159,
 /*   160 */    51,  164,   75,   17,  123,   32,   51,   68,  166,  141,
 /*   170 */    33,  125,   57,   71,   20,  123,  142,  125,   10,   43,
 /*   180 */    20,  123,  107,  108,   10,    2,   20,  123,  129,  168,
 /*   190 */    47,   49,   50,  168,   44,  163,  168,   89,   10,  145,
 /*   200 */   168,   94,  156,   91,   93,  101,   74,   85,   18,    3,
 /*   210 */    37,  168,   41,   76,   15,  109,  110,   59,   62,  111,
 /*   220 */   112,   58,  126,    4,    5,   63,   35,    7,  131,  106,
 /*   230 */   132,   95,   22,   38,   23,   26,  158,  161,  162,   99,
 /*   240 */   100,  165,   39,  114,   78,  117,  118,   82,  119,  120,
 /*   250 */    45,  137,  138,   64,  140,  146,    9,   30,   52,  143,
 /*   260 */    54,   55,   60,  154,   61,  154,  154,   31,  144,
};
static const YYCODETYPE yy_lookahead[] = {
 /*     0 */    29,   13,   35,   32,    4,   38,   36,    2,   20,   21,
 /*    10 */    22,   11,   41,   42,   43,   44,   29,   17,   47,   48,
 /*    20 */    20,   21,   51,   52,   29,   55,   30,   31,   28,   33,
 /*    30 */    59,    8,   61,   62,   63,   12,   41,   42,   43,   44,
 /*    40 */    17,   18,   47,   48,   29,   29,   51,   52,   33,   62,
 /*    50 */    63,    8,    9,   29,   59,   36,   61,   62,   63,   43,
 /*    60 */    29,   45,   29,   47,   48,   50,   29,   51,   52,   54,
 /*    70 */     2,    8,   57,   58,   55,   59,    8,   61,   62,   63,
 /*    80 */    43,   33,   45,   52,   47,   48,   62,   63,   51,   52,
 /*    90 */    59,   58,   61,   62,   63,   11,   59,   33,   61,   62,
 /*   100 */    63,    2,    5,   23,   24,   25,   26,   10,   11,    2,
 /*   110 */    13,   14,   15,   65,    5,   29,   19,   20,   21,   22,
 /*   120 */    11,    8,   13,   14,   60,   12,    5,   11,   19,   20,
 /*   130 */    21,   22,   11,    7,   13,   29,    5,   21,   52,    8,
 /*   140 */    19,   20,   21,   22,   39,   59,   29,   61,   62,   63,
 /*   150 */    33,   46,   29,   39,   29,   36,   33,   37,   29,   39,
 /*   160 */    46,   29,   33,   57,   58,   40,   46,   50,    0,    4,
 /*   170 */     2,   54,   40,   50,   57,   58,   11,   54,    5,   12,
 /*   180 */    57,   58,    9,   54,    5,   33,   57,   58,    9,    5,
 /*   190 */    53,   17,   18,    9,   27,   29,   12,   64,    5,   11,
 /*   200 */    16,   13,    9,   64,   64,   33,   49,   13,   33,   33,
 /*   210 */    33,   27,   16,   33,   33,   56,   33,    3,   33,   33,
 /*   220 */    33,    9,   33,   33,   33,   33,    8,    8,   33,    9,
 /*   230 */    33,   33,   33,   11,   34,   33,   33,   33,   33,   33,
 /*   240 */    33,   33,   13,   11,   21,   11,   11,   21,   11,   11,
 /*   250 */    11,   11,   11,   11,   23,   11,    8,   24,   12,   23,
 /*   260 */     6,    5,    4,   66,    5,   66,   66,   24,   23,
};
#define YY_SHIFT_USE_DFLT (-13)
#define YY_SHIFT_MAX 100
static const short yy_shift_ofst[] = {
 /*     0 */     5,   97,   97,  109,  109,  121,  121,   68,   68,   68,
 /*    10 */    68,  -12,  -12,   63,   84,    0,    0,   43,   84,   99,
 /*    20 */    63,  107,   84,  126,  -13,  -13,    0,  168,  113,  165,
 /*    30 */   165,  165,  131,    5,    5,    5,    5,  194,    5,    5,
 /*    40 */   196,    5,    5,    5,    5,    5,    5,    5,    5,    5,
 /*    50 */     5,    5,    5,  214,    5,    5,    5,  212,    5,    5,
 /*    60 */     5,    5,  184,   23,   80,  173,  167,  116,  179,  174,
 /*    70 */   188,  193,  218,  220,  219,  222,  229,  223,  232,  234,
 /*    80 */   235,  226,  237,  238,  222,  239,  240,  241,  242,  231,
 /*    90 */   233,  236,  243,  245,  244,  246,  248,  254,  256,  258,
 /*   100 */   259,
};
#define YY_REDUCE_USE_DFLT (-34)
#define YY_REDUCE_MAX 61
static const short yy_reduce_ofst[] = {
 /*     0 */    -4,  -29,   -5,   16,   37,   31,   86,   15,  117,  123,
 /*    10 */   129,  -13,   24,  106,  120,  -30,   19,   33,  105,   48,
 /*    20 */    33,   64,  114,  -33,  125,  132,  119,  152,  137,  133,
 /*    30 */   139,  140,  166,  172,  175,  176,  177,  157,  180,  181,
 /*    40 */   159,  183,  185,  186,  187,  189,  190,  191,  192,  195,
 /*    50 */   197,  198,  199,  200,  202,  203,  204,  166,  205,  206,
 /*    60 */   207,  208,
};
static const YYACTIONTYPE yy_default[] = {
 /*     0 */   167,  252,  252,  252,  196,  252,  252,  167,  167,  167,
 /*    10 */   167,  221,  225,  252,  176,  252,  252,  252,  252,  167,
 /*    20 */   207,  167,  252,  173,  179,  179,  252,  167,  252,  252,
 /*    30 */   252,  252,  252,  167,  167,  167,  167,  193,  167,  167,
 /*    40 */   213,  167,  167,  167,  167,  167,  167,  167,  167,  167,
 /*    50 */   167,  167,  167,  171,  167,  167,  167,  252,  167,  167,
 /*    60 */   167,  167,  242,  218,  252,  252,  238,  252,  252,  214,
 /*    70 */   252,  252,  252,  252,  252,  205,  252,  243,  252,  252,
 /*    80 */   252,  249,  252,  252,  252,  252,  252,  252,  252,  252,
 /*    90 */   252,  252,  252,  252,  252,  189,  252,  169,  252,  252,
 /*   100 */   252,  168,  183,  184,  185,  186,  187,  191,  204,  206,
 /*   110 */   212,  240,  241,  239,  248,  244,  245,  246,  247,  251,
 /*   120 */   250,  209,  210,  208,  211,  203,  192,  194,  197,  198,
 /*   130 */   201,  216,  217,  215,  219,  226,  227,  228,  229,  230,
 /*   140 */   231,  236,  237,  232,  233,  234,  235,  220,  222,  223,
 /*   150 */   224,  202,  199,  200,  188,  190,  195,  182,  172,  175,
 /*   160 */   174,  177,  178,  181,  180,  170,
};
#define YY_SZ_ACTTAB (sizeof(yy_action)/sizeof(yy_action[0]))

/* The next table maps tokens into fallback tokens.  If a construct
** like the following:
** 
**      %fallback ID X Y Z.
**
** appears in the grammer, then ID becomes a fallback token for X, Y,
** and Z.  Whenever one of the tokens X, Y, or Z is input to the parser
** but it does not parse, the type of the token is changed to ID and
** the parse is retried before an error is thrown.
*/
#ifdef YYFALLBACK
static const YYCODETYPE yyFallback[] = {
};
#endif /* YYFALLBACK */

/* The following structure represents a single element of the
** parser's stack.  Information stored includes:
**
**   +  The state number for the parser at this level of the stack.
**
**   +  The value of the token stored at this level of the stack.
**      (In other words, the "major" token.)
**
**   +  The semantic value stored at this level of the stack.  This is
**      the information used by the action routines in the grammar.
**      It is sometimes called the "minor" token.
*/
struct yyStackEntry {
  int stateno;       /* The state-number */
  int major;         /* The major token value.  This is the code
                     ** number for the token at this stack level */
  YYMINORTYPE minor; /* The user-supplied minor token value.  This
                     ** is the value of the token  */
};
typedef struct yyStackEntry yyStackEntry;

/* The state of the parser is completely contained in an instance of
** the following structure */
struct yyParser {
  int yyidx;                    /* Index of top element in stack */
  int yyerrcnt;                 /* Shifts left before out of the error */
  tkhtmlCssParserARG_SDECL                /* A place to hold %extra_argument */
  yyStackEntry yystack[YYSTACKDEPTH];  /* The parser's stack */
};
typedef struct yyParser yyParser;

#ifndef NDEBUG
#include <stdio.h>
static FILE *yyTraceFILE = 0;
static char *yyTracePrompt = 0;
#endif /* NDEBUG */

#ifndef NDEBUG
/* 
** Turn parser tracing on by giving a stream to which to write the trace
** and a prompt to preface each trace message.  Tracing is turned off
** by making either argument NULL 
**
** Inputs:
** <ul>
** <li> A FILE* to which trace output should be written.
**      If NULL, then tracing is turned off.
** <li> A prefix string written at the beginning of every
**      line of trace output.  If NULL, then tracing is
**      turned off.
** </ul>
**
** Outputs:
** None.
*/
void tkhtmlCssParserTrace(FILE *TraceFILE, char *zTracePrompt){
  yyTraceFILE = TraceFILE;
  yyTracePrompt = zTracePrompt;
  if( yyTraceFILE==0 ) yyTracePrompt = 0;
  else if( yyTracePrompt==0 ) yyTraceFILE = 0;
}
#endif /* NDEBUG */

#ifndef NDEBUG
/* For tracing shifts, the names of all terminals and nonterminals
** are required.  The following table supplies these names */
static const char *const yyTokenName[] = { 
  "$",             "RRP",           "SPACE",         "CHARSET_SYM", 
  "STRING",        "SEMICOLON",     "IMPORT_SYM",    "UNKNOWN_SYM", 
  "LP",            "RP",            "MEDIA_SYM",     "IDENT",       
  "COMMA",         "COLON",         "PAGE_SYM",      "FONT_SYM",    
  "IMPORTANT_SYM",  "PLUS",          "GT",            "STAR",        
  "HASH",          "DOT",           "LSP",           "RSP",         
  "EQUALS",        "TILDE",         "PIPE",          "SLASH",       
  "FUNCTION",      "error",         "stylesheet",    "ss_header",   
  "ss_body",       "ws",            "charset_opt",   "imports_opt", 
  "term",          "medium_list_opt",  "unknown_at_rule",  "medium_list", 
  "trash",         "ss_body_item",  "media",         "ruleset",     
  "font_face",     "ruleset_list",  "medium_list_item",  "page",        
  "page_sym",      "pseudo_opt",    "declaration_list",  "selector_list",
  "selector",      "comma",         "declaration",   "expr",        
  "prio",          "garbage",       "garbage_token",  "simple_selector",
  "combinator",    "tag",           "simple_selector_tail",  "simple_selector_tail_component",
  "string",        "operator",    
};
#endif /* NDEBUG */

#ifndef NDEBUG
/* For tracing reduce actions, the names of all rules are required.
*/
static const char *const yyRuleName[] = {
 /*   0 */ "stylesheet ::= ss_header ss_body",
 /*   1 */ "ws ::=",
 /*   2 */ "ws ::= SPACE ws",
 /*   3 */ "ss_header ::= ws charset_opt imports_opt",
 /*   4 */ "charset_opt ::= CHARSET_SYM ws STRING ws SEMICOLON ws",
 /*   5 */ "charset_opt ::=",
 /*   6 */ "imports_opt ::= imports_opt IMPORT_SYM ws term medium_list_opt SEMICOLON ws",
 /*   7 */ "imports_opt ::=",
 /*   8 */ "imports_opt ::= unknown_at_rule",
 /*   9 */ "medium_list_opt ::= medium_list",
 /*  10 */ "medium_list_opt ::=",
 /*  11 */ "unknown_at_rule ::= UNKNOWN_SYM trash SEMICOLON ws",
 /*  12 */ "unknown_at_rule ::= UNKNOWN_SYM trash LP trash RP ws",
 /*  13 */ "trash ::=",
 /*  14 */ "trash ::= error",
 /*  15 */ "trash ::= trash error",
 /*  16 */ "ss_body ::= ss_body_item",
 /*  17 */ "ss_body ::= ss_body ws ss_body_item",
 /*  18 */ "ss_body_item ::= media",
 /*  19 */ "ss_body_item ::= ruleset",
 /*  20 */ "ss_body_item ::= font_face",
 /*  21 */ "media ::= MEDIA_SYM ws medium_list LP ws ruleset_list RP",
 /*  22 */ "medium_list_item ::= IDENT",
 /*  23 */ "medium_list ::= medium_list_item ws",
 /*  24 */ "medium_list ::= medium_list_item ws COMMA ws medium_list",
 /*  25 */ "page ::= page_sym ws pseudo_opt LP declaration_list RP",
 /*  26 */ "pseudo_opt ::= COLON IDENT ws",
 /*  27 */ "pseudo_opt ::=",
 /*  28 */ "page_sym ::= PAGE_SYM",
 /*  29 */ "font_face ::= FONT_SYM LP declaration_list RP",
 /*  30 */ "ruleset_list ::= ruleset ws",
 /*  31 */ "ruleset_list ::= ruleset ws ruleset_list",
 /*  32 */ "ruleset ::= selector_list LP declaration_list RP",
 /*  33 */ "ruleset ::= page",
 /*  34 */ "selector_list ::= selector",
 /*  35 */ "selector_list ::= selector_list comma ws selector",
 /*  36 */ "comma ::= COMMA",
 /*  37 */ "declaration_list ::= declaration",
 /*  38 */ "declaration_list ::= declaration_list SEMICOLON declaration",
 /*  39 */ "declaration_list ::= declaration_list SEMICOLON ws",
 /*  40 */ "declaration ::= ws IDENT ws COLON ws expr prio",
 /*  41 */ "declaration ::= garbage",
 /*  42 */ "garbage ::= garbage_token",
 /*  43 */ "garbage ::= garbage garbage_token",
 /*  44 */ "garbage_token ::= error",
 /*  45 */ "garbage_token ::= LP garbage RP",
 /*  46 */ "prio ::= IMPORTANT_SYM ws",
 /*  47 */ "prio ::=",
 /*  48 */ "selector ::= simple_selector ws",
 /*  49 */ "selector ::= simple_selector combinator selector",
 /*  50 */ "combinator ::= ws PLUS ws",
 /*  51 */ "combinator ::= ws GT ws",
 /*  52 */ "combinator ::= SPACE ws",
 /*  53 */ "simple_selector ::= tag simple_selector_tail",
 /*  54 */ "simple_selector ::= simple_selector_tail",
 /*  55 */ "simple_selector ::= tag",
 /*  56 */ "tag ::= IDENT",
 /*  57 */ "tag ::= STAR",
 /*  58 */ "tag ::= SEMICOLON",
 /*  59 */ "simple_selector_tail ::= simple_selector_tail_component",
 /*  60 */ "simple_selector_tail ::= simple_selector_tail_component simple_selector_tail",
 /*  61 */ "simple_selector_tail ::= error",
 /*  62 */ "simple_selector_tail_component ::= HASH IDENT",
 /*  63 */ "simple_selector_tail_component ::= DOT IDENT",
 /*  64 */ "simple_selector_tail_component ::= LSP IDENT RSP",
 /*  65 */ "simple_selector_tail_component ::= LSP IDENT EQUALS string RSP",
 /*  66 */ "simple_selector_tail_component ::= LSP IDENT TILDE EQUALS string RSP",
 /*  67 */ "simple_selector_tail_component ::= LSP IDENT PIPE EQUALS string RSP",
 /*  68 */ "simple_selector_tail_component ::= COLON IDENT",
 /*  69 */ "simple_selector_tail_component ::= COLON COLON IDENT",
 /*  70 */ "string ::= STRING",
 /*  71 */ "string ::= IDENT",
 /*  72 */ "expr ::= term ws",
 /*  73 */ "expr ::= term operator expr",
 /*  74 */ "operator ::= ws COMMA ws",
 /*  75 */ "operator ::= ws SLASH ws",
 /*  76 */ "operator ::= SPACE ws",
 /*  77 */ "term ::= IDENT",
 /*  78 */ "term ::= STRING",
 /*  79 */ "term ::= FUNCTION",
 /*  80 */ "term ::= HASH IDENT",
 /*  81 */ "term ::= DOT IDENT",
 /*  82 */ "term ::= IDENT DOT IDENT",
 /*  83 */ "term ::= PLUS IDENT",
 /*  84 */ "term ::= PLUS DOT IDENT",
 /*  85 */ "term ::= PLUS IDENT DOT IDENT",
};
#endif /* NDEBUG */

/*
** This function returns the symbolic name associated with a token
** value.
*/
const char *tkhtmlCssParserTokenName(int tokenType){
#ifndef NDEBUG
  if( tokenType>0 && tokenType<(sizeof(yyTokenName)/sizeof(yyTokenName[0])) ){
    return yyTokenName[tokenType];
  }else{
    return "Unknown";
  }
#else
  return "";
#endif
}

/* 
** This function allocates a new parser.
** The only argument is a pointer to a function which works like
** malloc.
**
** Inputs:
** A pointer to the function used to allocate memory.
**
** Outputs:
** A pointer to a parser.  This pointer is used in subsequent calls
** to tkhtmlCssParser and tkhtmlCssParserFree.
*/
void *tkhtmlCssParserAlloc(void *(*mallocProc)(size_t)){
  yyParser *pParser;
  pParser = (yyParser*)(*mallocProc)( (size_t)sizeof(yyParser) );
  if( pParser ){
    pParser->yyidx = -1;
  }
  return pParser;
}

/* The following function deletes the value associated with a
** symbol.  The symbol can be either a terminal or nonterminal.
** "yymajor" is the symbol code, and "yypminor" is a pointer to
** the value.
*/
static void yy_destructor(YYCODETYPE yymajor, YYMINORTYPE *yypminor){
  switch( yymajor ){
    /* Here is inserted the actions which take place when a
    ** terminal or non-terminal is destroyed.  This can happen
    ** when the symbol is popped from the stack during a
    ** reduce or during error processing or when a parser is 
    ** being destroyed before it is finished parsing.
    **
    ** Note: during a reduce, the only symbols destroyed are those
    ** which appear on the RHS of the rule, but which are not used
    ** inside the C code.
    */
    default:  break;   /* If no destructor action specified: do nothing */
  }
}

/*
** Pop the parser's stack once.
**
** If there is a destructor routine associated with the token which
** is popped from the stack, then call it.
**
** Return the major token number for the symbol popped.
*/
static int yy_pop_parser_stack(yyParser *pParser){
  YYCODETYPE yymajor;
  yyStackEntry *yytos = &pParser->yystack[pParser->yyidx];

  if( pParser->yyidx<0 ) return 0;
#ifndef NDEBUG
  if( yyTraceFILE && pParser->yyidx>=0 ){
    fprintf(yyTraceFILE,"%sPopping %s\n",
      yyTracePrompt,
      yyTokenName[yytos->major]);
  }
#endif
  yymajor = yytos->major;
  yy_destructor( yymajor, &yytos->minor);
  pParser->yyidx--;
  return yymajor;
}

/* 
** Deallocate and destroy a parser.  Destructors are all called for
** all stack elements before shutting the parser down.
**
** Inputs:
** <ul>
** <li>  A pointer to the parser.  This should be a pointer
**       obtained from tkhtmlCssParserAlloc.
** <li>  A pointer to a function used to reclaim memory obtained
**       from malloc.
** </ul>
*/
void tkhtmlCssParserFree(
  void *p,                    /* The parser to be deleted */
  void (*freeProc)(void*)     /* Function used to reclaim memory */
){
  yyParser *pParser = (yyParser*)p;
  if( pParser==0 ) return;
  while( pParser->yyidx>=0 ) yy_pop_parser_stack(pParser);
  (*freeProc)((void*)pParser);
}

/*
** Find the appropriate action for a parser given the terminal
** look-ahead token iLookAhead.
**
** If the look-ahead token is YYNOCODE, then check to see if the action is
** independent of the look-ahead.  If it is, return the action, otherwise
** return YY_NO_ACTION.
*/
static int yy_find_shift_action(
  yyParser *pParser,        /* The parser */
  int iLookAhead            /* The look-ahead token */
){
  int i;
  int stateno = pParser->yystack[pParser->yyidx].stateno;
 
  if( stateno>YY_SHIFT_MAX || (i = yy_shift_ofst[stateno])==YY_SHIFT_USE_DFLT ){
    return yy_default[stateno];
  }
  if( iLookAhead==YYNOCODE ){
    return YY_NO_ACTION;
  }
  i += iLookAhead;
  if( i<0 || i>=YY_SZ_ACTTAB || yy_lookahead[i]!=iLookAhead ){
#ifdef YYFALLBACK
    int iFallback;            /* Fallback token */
    if( iLookAhead<sizeof(yyFallback)/sizeof(yyFallback[0])
           && (iFallback = yyFallback[iLookAhead])!=0 ){
#ifndef NDEBUG
      if( yyTraceFILE ){
        fprintf(yyTraceFILE, "%sFALLBACK %s => %s\n",
           yyTracePrompt, yyTokenName[iLookAhead], yyTokenName[iFallback]);
      }
#endif
      return yy_find_shift_action(pParser, iFallback);
    }
#endif
    return yy_default[stateno];
  }else{
    return yy_action[i];
  }
}

/*
** Find the appropriate action for a parser given the non-terminal
** look-ahead token iLookAhead.
**
** If the look-ahead token is YYNOCODE, then check to see if the action is
** independent of the look-ahead.  If it is, return the action, otherwise
** return YY_NO_ACTION.
*/
static int yy_find_reduce_action(
  int stateno,              /* Current state number */
  int iLookAhead            /* The look-ahead token */
){
  int i;
  /* int stateno = pParser->yystack[pParser->yyidx].stateno; */
 
  if( stateno>YY_REDUCE_MAX ||
      (i = yy_reduce_ofst[stateno])==YY_REDUCE_USE_DFLT ){
    return yy_default[stateno];
  }
  if( iLookAhead==YYNOCODE ){
    return YY_NO_ACTION;
  }
  i += iLookAhead;
  if( i<0 || i>=YY_SZ_ACTTAB || yy_lookahead[i]!=iLookAhead ){
    return yy_default[stateno];
  }else{
    return yy_action[i];
  }
}

/*
** Perform a shift action.
*/
static void yy_shift(
  yyParser *yypParser,          /* The parser to be shifted */
  int yyNewState,               /* The new state to shift in */
  int yyMajor,                  /* The major token to shift in */
  YYMINORTYPE *yypMinor         /* Pointer ot the minor token to shift in */
){
  yyStackEntry *yytos;
  yypParser->yyidx++;
  if( yypParser->yyidx>=YYSTACKDEPTH ){
     tkhtmlCssParserARG_FETCH;
     yypParser->yyidx--;
#ifndef NDEBUG
     if( yyTraceFILE ){
       fprintf(yyTraceFILE,"%sStack Overflow!\n",yyTracePrompt);
     }
#endif
     while( yypParser->yyidx>=0 ) yy_pop_parser_stack(yypParser);
     /* Here code is inserted which will execute if the parser
     ** stack every overflows */
     tkhtmlCssParserARG_STORE; /* Suppress warning about unused %extra_argument var */
     return;
  }
  yytos = &yypParser->yystack[yypParser->yyidx];
  yytos->stateno = yyNewState;
  yytos->major = yyMajor;
  yytos->minor = *yypMinor;
#ifndef NDEBUG
  if( yyTraceFILE && yypParser->yyidx>0 ){
    int i;
    fprintf(yyTraceFILE,"%sShift %d\n",yyTracePrompt,yyNewState);
    fprintf(yyTraceFILE,"%sStack:",yyTracePrompt);
    for(i=1; i<=yypParser->yyidx; i++)
      fprintf(yyTraceFILE," %s",yyTokenName[yypParser->yystack[i].major]);
    fprintf(yyTraceFILE,"\n");
  }
#endif
}

/* The following table contains information about every rule that
** is used during the reduce.
*/
static const struct {
  YYCODETYPE lhs;         /* Symbol on the left-hand side of the rule */
  unsigned char nrhs;     /* Number of right-hand side symbols in the rule */
} yyRuleInfo[] = {
  { 30, 2 },
  { 33, 0 },
  { 33, 2 },
  { 31, 3 },
  { 34, 6 },
  { 34, 0 },
  { 35, 7 },
  { 35, 0 },
  { 35, 1 },
  { 37, 1 },
  { 37, 0 },
  { 38, 4 },
  { 38, 6 },
  { 40, 0 },
  { 40, 1 },
  { 40, 2 },
  { 32, 1 },
  { 32, 3 },
  { 41, 1 },
  { 41, 1 },
  { 41, 1 },
  { 42, 7 },
  { 46, 1 },
  { 39, 2 },
  { 39, 5 },
  { 47, 6 },
  { 49, 3 },
  { 49, 0 },
  { 48, 1 },
  { 44, 4 },
  { 45, 2 },
  { 45, 3 },
  { 43, 4 },
  { 43, 1 },
  { 51, 1 },
  { 51, 4 },
  { 53, 1 },
  { 50, 1 },
  { 50, 3 },
  { 50, 3 },
  { 54, 7 },
  { 54, 1 },
  { 57, 1 },
  { 57, 2 },
  { 58, 1 },
  { 58, 3 },
  { 56, 2 },
  { 56, 0 },
  { 52, 2 },
  { 52, 3 },
  { 60, 3 },
  { 60, 3 },
  { 60, 2 },
  { 59, 2 },
  { 59, 1 },
  { 59, 1 },
  { 61, 1 },
  { 61, 1 },
  { 61, 1 },
  { 62, 1 },
  { 62, 2 },
  { 62, 1 },
  { 63, 2 },
  { 63, 2 },
  { 63, 3 },
  { 63, 5 },
  { 63, 6 },
  { 63, 6 },
  { 63, 2 },
  { 63, 3 },
  { 64, 1 },
  { 64, 1 },
  { 55, 2 },
  { 55, 3 },
  { 65, 3 },
  { 65, 3 },
  { 65, 2 },
  { 36, 1 },
  { 36, 1 },
  { 36, 1 },
  { 36, 2 },
  { 36, 2 },
  { 36, 3 },
  { 36, 2 },
  { 36, 3 },
  { 36, 4 },
};

static void yy_accept(yyParser*);  /* Forward Declaration */

/*
** Perform a reduce action and the shift that must immediately
** follow the reduce.
*/
static void yy_reduce(
  yyParser *yypParser,         /* The parser */
  int yyruleno                 /* Number of the rule by which to reduce */
){
  int yygoto;                     /* The next state */
  int yyact;                      /* The next action */
  YYMINORTYPE yygotominor;        /* The LHS of the rule reduced */
  yyStackEntry *yymsp;            /* The top of the parser's stack */
  int yysize;                     /* Amount to pop the stack */
  tkhtmlCssParserARG_FETCH;
  yymsp = &yypParser->yystack[yypParser->yyidx];
#ifndef NDEBUG
  if( yyTraceFILE && yyruleno>=0 
        && yyruleno<sizeof(yyRuleName)/sizeof(yyRuleName[0]) ){
    fprintf(yyTraceFILE, "%sReduce [%s].\n", yyTracePrompt,
      yyRuleName[yyruleno]);
  }
#endif /* NDEBUG */

#ifndef NDEBUG
  /* Silence complaints from purify about yygotominor being uninitialized
  ** in some cases when it is copied into the stack after the following
  ** switch.  yygotominor is uninitialized when a rule reduces that does
  ** not set the value of its left-hand side nonterminal.  Leaving the
  ** value of the nonterminal uninitialized is utterly harmless as long
  ** as the value is never used.  So really the only thing this code
  ** accomplishes is to quieten purify.  
  */
  memset(&yygotominor, 0, sizeof(yygotominor));
#endif

  switch( yyruleno ){
  /* Beginning here are the reduction cases.  A typical example
  ** follows:
  **   case 0:
  **  #line <lineno> <grammarfile>
  **     { ... }           // User supplied code
  **  #line <lineno> <thisfile>
  **     break;
  */
      case 6:
#line 77 "cssparse.y"
{
    HtmlCssImport(pParse, &yymsp[-3].minor.yy0);
}
#line 797 "cssparse.c"
        break;
      case 21:
#line 117 "cssparse.y"
{
    pParse->isIgnore = 0;
}
#line 804 "cssparse.c"
        break;
      case 22:
#line 124 "cssparse.y"
{
    if (
        (yymsp[0].minor.yy0.n == 3 && 0 == strnicmp(yymsp[0].minor.yy0.z, "all", 3)) ||
        (yymsp[0].minor.yy0.n == 6 && 0 == strnicmp(yymsp[0].minor.yy0.z, "screen", 6))
    ) {
        yygotominor.yy64 = 0;
    } else {
        yygotominor.yy64 = 1;
    }
}
#line 818 "cssparse.c"
        break;
      case 23:
#line 135 "cssparse.y"
{
    yygotominor.yy64 = yymsp[-1].minor.yy64;
    pParse->isIgnore = yygotominor.yy64;
}
#line 826 "cssparse.c"
        break;
      case 24:
#line 140 "cssparse.y"
{
    yygotominor.yy64 = (yymsp[-4].minor.yy64 && yymsp[0].minor.yy64) ? 1 : 0;
    pParse->isIgnore = yygotominor.yy64;
}
#line 834 "cssparse.c"
        break;
      case 25:
#line 148 "cssparse.y"
{
  pParse->isIgnore = 0;
}
#line 841 "cssparse.c"
        break;
      case 28:
#line 155 "cssparse.y"
{
  pParse->isIgnore = 1;
}
#line 848 "cssparse.c"
        break;
      case 32:
#line 170 "cssparse.y"
{
    HtmlCssRule(pParse, 1);
}
#line 855 "cssparse.c"
        break;
      case 36:
#line 177 "cssparse.y"
{
    HtmlCssSelectorComma(pParse);
}
#line 862 "cssparse.c"
        break;
      case 40:
#line 185 "cssparse.y"
{
    HtmlCssDeclaration(pParse, &yymsp[-5].minor.yy0, &yymsp[-1].minor.yy0, yymsp[0].minor.yy64);
}
#line 869 "cssparse.c"
        break;
      case 46:
#line 196 "cssparse.y"
{yygotominor.yy64 = (pParse->pStyleId) ? 1 : 0;}
#line 874 "cssparse.c"
        break;
      case 47:
#line 197 "cssparse.y"
{yygotominor.yy64 = 0;}
#line 879 "cssparse.c"
        break;
      case 50:
#line 217 "cssparse.y"
{
    HtmlCssSelector(pParse, CSS_SELECTORCHAIN_ADJACENT, 0, 0);
}
#line 886 "cssparse.c"
        break;
      case 51:
#line 220 "cssparse.y"
{
    HtmlCssSelector(pParse, CSS_SELECTORCHAIN_CHILD, 0, 0);
}
#line 893 "cssparse.c"
        break;
      case 52:
#line 223 "cssparse.y"
{
    HtmlCssSelector(pParse, CSS_SELECTORCHAIN_DESCENDANT, 0, 0);
}
#line 900 "cssparse.c"
        break;
      case 56:
      case 58:
#line 231 "cssparse.y"
{ HtmlCssSelector(pParse, CSS_SELECTOR_TYPE, 0, &yymsp[0].minor.yy0); }
#line 906 "cssparse.c"
        break;
      case 57:
#line 232 "cssparse.y"
{ HtmlCssSelector(pParse, CSS_SELECTOR_UNIVERSAL, 0, 0); }
#line 911 "cssparse.c"
        break;
      case 61:
#line 238 "cssparse.y"
{
    HtmlCssSelector(pParse, CSS_SELECTOR_NEVERMATCH, 0, 0);
}
#line 918 "cssparse.c"
        break;
      case 62:
#line 242 "cssparse.y"
{
    HtmlCssSelector(pParse, CSS_SELECTOR_ID, 0, &yymsp[0].minor.yy0);
}
#line 925 "cssparse.c"
        break;
      case 63:
#line 245 "cssparse.y"
{
    /* A CSS class selector may not begin with a digit. Presumably this is
     * because they expect to use this syntax for something else in a
     * future version. For now, just insert a "never-match" condition into
     * the rule to prevent it from having any affect. A bit lazy, this.
     */
    if (yymsp[0].minor.yy0.n > 0 && !isdigit((int)(*yymsp[0].minor.yy0.z))) {
        HtmlCssSelector(pParse, CSS_SELECTOR_CLASS, 0, &yymsp[0].minor.yy0);
    } else {
        HtmlCssSelector(pParse, CSS_SELECTOR_NEVERMATCH, 0, 0);
    }
}
#line 941 "cssparse.c"
        break;
      case 64:
#line 257 "cssparse.y"
{
    HtmlCssSelector(pParse, CSS_SELECTOR_ATTR, &yymsp[-1].minor.yy0, 0);
}
#line 948 "cssparse.c"
        break;
      case 65:
#line 260 "cssparse.y"
{
    HtmlCssSelector(pParse, CSS_SELECTOR_ATTRVALUE, &yymsp[-3].minor.yy0, &yymsp[-1].minor.yy0);
}
#line 955 "cssparse.c"
        break;
      case 66:
#line 263 "cssparse.y"
{
    HtmlCssSelector(pParse, CSS_SELECTOR_ATTRLISTVALUE, &yymsp[-4].minor.yy0, &yymsp[-1].minor.yy0);
}
#line 962 "cssparse.c"
        break;
      case 67:
#line 266 "cssparse.y"
{
    HtmlCssSelector(pParse, CSS_SELECTOR_ATTRHYPHEN, &yymsp[-4].minor.yy0, &yymsp[-1].minor.yy0);
}
#line 969 "cssparse.c"
        break;
      case 68:
#line 270 "cssparse.y"
{
    HtmlCssSelector(pParse, HtmlCssPseudo(&yymsp[0].minor.yy0, 1), 0, 0);
}
#line 976 "cssparse.c"
        break;
      case 69:
#line 273 "cssparse.y"
{
    HtmlCssSelector(pParse, HtmlCssPseudo(&yymsp[0].minor.yy0, 2), 0, 0);
}
#line 983 "cssparse.c"
        break;
      case 70:
      case 71:
#line 277 "cssparse.y"
{yygotominor.yy0 = yymsp[0].minor.yy0;}
#line 989 "cssparse.c"
        break;
      case 72:
#line 286 "cssparse.y"
{ yygotominor.yy0 = yymsp[-1].minor.yy0; }
#line 994 "cssparse.c"
        break;
      case 73:
      case 82:
      case 84:
#line 287 "cssparse.y"
{ yygotominor.yy0.z = yymsp[-2].minor.yy0.z; yygotominor.yy0.n = (yymsp[0].minor.yy0.z+yymsp[0].minor.yy0.n - yymsp[-2].minor.yy0.z); }
#line 1001 "cssparse.c"
        break;
      case 77:
      case 78:
      case 79:
#line 293 "cssparse.y"
{ yygotominor.yy0 = yymsp[0].minor.yy0; }
#line 1008 "cssparse.c"
        break;
      case 80:
      case 81:
      case 83:
#line 296 "cssparse.y"
{ yygotominor.yy0.z = yymsp[-1].minor.yy0.z; yygotominor.yy0.n = (yymsp[0].minor.yy0.z+yymsp[0].minor.yy0.n - yymsp[-1].minor.yy0.z); }
#line 1015 "cssparse.c"
        break;
      case 85:
#line 302 "cssparse.y"
{ yygotominor.yy0.z = yymsp[-3].minor.yy0.z; yygotominor.yy0.n = (yymsp[0].minor.yy0.z+yymsp[0].minor.yy0.n - yymsp[-3].minor.yy0.z); }
#line 1020 "cssparse.c"
        break;
  };
  yygoto = yyRuleInfo[yyruleno].lhs;
  yysize = yyRuleInfo[yyruleno].nrhs;
  yypParser->yyidx -= yysize;
  yyact = yy_find_reduce_action(yymsp[-yysize].stateno,yygoto);
  if( yyact < YYNSTATE ){
#ifdef NDEBUG
    /* If we are not debugging and the reduce action popped at least
    ** one element off the stack, then we can push the new element back
    ** onto the stack here, and skip the stack overflow test in yy_shift().
    ** That gives a significant speed improvement. */
    if( yysize ){
      yypParser->yyidx++;
      yymsp -= yysize-1;
      yymsp->stateno = yyact;
      yymsp->major = yygoto;
      yymsp->minor = yygotominor;
    }else
#endif
    {
      yy_shift(yypParser,yyact,yygoto,&yygotominor);
    }
  }else if( yyact == YYNSTATE + YYNRULE + 1 ){
    yy_accept(yypParser);
  }
}

/*
** The following code executes when the parse fails
*/
static void yy_parse_failed(
  yyParser *yypParser           /* The parser */
){
  tkhtmlCssParserARG_FETCH;
#ifndef NDEBUG
  if( yyTraceFILE ){
    fprintf(yyTraceFILE,"%sFail!\n",yyTracePrompt);
  }
#endif
  while( yypParser->yyidx>=0 ) yy_pop_parser_stack(yypParser);
  /* Here code is inserted which will be executed whenever the
  ** parser fails */
  tkhtmlCssParserARG_STORE; /* Suppress warning about unused %extra_argument variable */
}

/*
** The following code executes when a syntax error first occurs.
*/
static void yy_syntax_error(
  yyParser *yypParser,           /* The parser */
  int yymajor,                   /* The major type of the error token */
  YYMINORTYPE yyminor            /* The minor type of the error token */
){
  tkhtmlCssParserARG_FETCH;
#define TOKEN (yyminor.yy0)
#line 54 "cssparse.y"

    pParse->pStyle->nSyntaxErr++;
    pParse->isIgnore = 0;
    /* HtmlCssRule(pParse, 0); */
#line 1083 "cssparse.c"
  tkhtmlCssParserARG_STORE; /* Suppress warning about unused %extra_argument variable */
}

/*
** The following is executed when the parser accepts
*/
static void yy_accept(
  yyParser *yypParser           /* The parser */
){
  tkhtmlCssParserARG_FETCH;
#ifndef NDEBUG
  if( yyTraceFILE ){
    fprintf(yyTraceFILE,"%sAccept!\n",yyTracePrompt);
  }
#endif
  while( yypParser->yyidx>=0 ) yy_pop_parser_stack(yypParser);
  /* Here code is inserted which will be executed whenever the
  ** parser accepts */
  tkhtmlCssParserARG_STORE; /* Suppress warning about unused %extra_argument variable */
}

/* The main parser program.
** The first argument is a pointer to a structure obtained from
** "tkhtmlCssParserAlloc" which describes the current state of the parser.
** The second argument is the major token number.  The third is
** the minor token.  The fourth optional argument is whatever the
** user wants (and specified in the grammar) and is available for
** use by the action routines.
**
** Inputs:
** <ul>
** <li> A pointer to the parser (an opaque structure.)
** <li> The major token number.
** <li> The minor token number.
** <li> An option argument of a grammar-specified type.
** </ul>
**
** Outputs:
** None.
*/
void tkhtmlCssParser(
  void *yyp,                   /* The parser */
  int yymajor,                 /* The major token code number */
  tkhtmlCssParserTOKENTYPE yyminor       /* The value for the token */
  tkhtmlCssParserARG_PDECL               /* Optional %extra_argument parameter */
){
  YYMINORTYPE yyminorunion;
  int yyact;            /* The parser action. */
  int yyendofinput;     /* True if we are at the end of input */
  int yyerrorhit = 0;   /* True if yymajor has invoked an error */
  yyParser *yypParser;  /* The parser */

  /* (re)initialize the parser, if necessary */
  yypParser = (yyParser*)yyp;
  if( yypParser->yyidx<0 ){
    /* if( yymajor==0 ) return; // not sure why this was here... */
    yypParser->yyidx = 0;
    yypParser->yyerrcnt = -1;
    yypParser->yystack[0].stateno = 0;
    yypParser->yystack[0].major = 0;
  }
  yyminorunion.yy0 = yyminor;
  yyendofinput = (yymajor==0);
  tkhtmlCssParserARG_STORE;

#ifndef NDEBUG
  if( yyTraceFILE ){
    fprintf(yyTraceFILE,"%sInput %s\n",yyTracePrompt,yyTokenName[yymajor]);
  }
#endif

  do{
    yyact = yy_find_shift_action(yypParser,yymajor);
    if( yyact<YYNSTATE ){
      yy_shift(yypParser,yyact,yymajor,&yyminorunion);
      yypParser->yyerrcnt--;
      if( yyendofinput && yypParser->yyidx>=0 ){
        yymajor = 0;
      }else{
        yymajor = YYNOCODE;
      }
    }else if( yyact < YYNSTATE + YYNRULE ){
      yy_reduce(yypParser,yyact-YYNSTATE);
    }else if( yyact == YY_ERROR_ACTION ){
      int yymx;
#ifndef NDEBUG
      if( yyTraceFILE ){
        fprintf(yyTraceFILE,"%sSyntax Error!\n",yyTracePrompt);
      }
#endif
#ifdef YYERRORSYMBOL
      /* A syntax error has occurred.
      ** The response to an error depends upon whether or not the
      ** grammar defines an error token "ERROR".  
      **
      ** This is what we do if the grammar does define ERROR:
      **
      **  * Call the %syntax_error function.
      **
      **  * Begin popping the stack until we enter a state where
      **    it is legal to shift the error symbol, then shift
      **    the error symbol.
      **
      **  * Set the error count to three.
      **
      **  * Begin accepting and shifting new tokens.  No new error
      **    processing will occur until three tokens have been
      **    shifted successfully.
      **
      */
      if( yypParser->yyerrcnt<0 ){
        yy_syntax_error(yypParser,yymajor,yyminorunion);
      }
      yymx = yypParser->yystack[yypParser->yyidx].major;
      if( yymx==YYERRORSYMBOL || yyerrorhit ){
#ifndef NDEBUG
        if( yyTraceFILE ){
          fprintf(yyTraceFILE,"%sDiscard input token %s\n",
             yyTracePrompt,yyTokenName[yymajor]);
        }
#endif
        yy_destructor(yymajor,&yyminorunion);
        yymajor = YYNOCODE;
      }else{
         while(
          yypParser->yyidx >= 0 &&
          yymx != YYERRORSYMBOL &&
          (yyact = yy_find_reduce_action(
                        yypParser->yystack[yypParser->yyidx].stateno,
                        YYERRORSYMBOL)) >= YYNSTATE
        ){
          yy_pop_parser_stack(yypParser);
        }
        if( yypParser->yyidx < 0 || yymajor==0 ){
          yy_destructor(yymajor,&yyminorunion);
          yy_parse_failed(yypParser);
          yymajor = YYNOCODE;
        }else if( yymx!=YYERRORSYMBOL ){
          YYMINORTYPE u2;
          u2.YYERRSYMDT = 0;
          yy_shift(yypParser,yyact,YYERRORSYMBOL,&u2);
        }
      }
      yypParser->yyerrcnt = 3;
      yyerrorhit = 1;
#else  /* YYERRORSYMBOL is not defined */
      /* This is what we do if the grammar does not define ERROR:
      **
      **  * Report an error message, and throw away the input token.
      **
      **  * If the input token is $, then fail the parse.
      **
      ** As before, subsequent error messages are suppressed until
      ** three input tokens have been successfully shifted.
      */
      if( yypParser->yyerrcnt<=0 ){
        yy_syntax_error(yypParser,yymajor,yyminorunion);
      }
      yypParser->yyerrcnt = 3;
      yy_destructor(yymajor,&yyminorunion);
      if( yyendofinput ){
        yy_parse_failed(yypParser);
      }
      yymajor = YYNOCODE;
#endif
    }else{
      yy_accept(yypParser);
      yymajor = YYNOCODE;
    }
  }while( yymajor!=YYNOCODE && yypParser->yyidx>=0 );
  return;
}
