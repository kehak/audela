
/* Possible values of HtmlParserState.eState */
#define HTML_BEFORE_HEAD      1
#define HTML_IN_HEAD          2
#define HTML_IN_BODY          3
#define HTML_AFTER_BODY       4
#define HTML_IN_FRAMESET      5
#define HTML_AFTER_FRAMESET   6
#define HTML_IN_TABLE         7
#define HTML_IN_CAPTION       8
#define HTML_IN_COLUMN_GROUP  9
#define HTML_IN_TABLE_BODY   10
#define HTML_IN_ROW          11
#define HTML_IN_CELL         12
#define HTML_IN_SELECT       13

#define HTML_DEFAULT          0

struct HtmlParserState {
    int eState;                 /* Current insertion mode */
    HtmlNode *pHead;            /* The <head> element, or NULL */
    HtmlNode *pCurrent;         /* Current insertion point pointer */
};

#define HTML_PS_INITIAL
#define HTML_PS_HEAD
#define HTML_PS_FRAMESET
#define HTML_PS_BODY

/* Elements that are always in the <head> section:
 *
 *     <base> <link> <meta> <style> <title>
 *
 * Sometimes <script> elements may also be added to the <head> section.
 *
 */

