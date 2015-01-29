library Board requires ARGB
//==============================================================================
// Board v0.2.01
//==============================================================================
// Credits:
//------------------------------------------------------------------------------
// Written By:
//     Earth-Fury
//------------------------------------------------------------------------------
// I don't care if you credit me or not if you use this. However, you must not
// misrepresent the source of this library in any way. This includes, but is not
// limited to claiming yourself to be the sole contributor to a map which uses
// this library.
// 
//==============================================================================
// Introduction:
//------------------------------------------------------------------------------
// Board is a library which provides decorators for multiboards. Basically, the
// Board library gives you multiboards with a more manageable API. You can not
// mix usage of the Board class and usage of the multiboard natives. You can
// have multiboards which in no way use the Board library, as well as ones that
// do.
// 
// Board does not impose limits on the number of boards, columns, rows, or
// items within boards. You can create an arbitrary number of boards with an
// arbitrary number of rows and columns, without running in to problems with
// the array size limit.
// 
//==============================================================================
// API Guide
//------------------------------------------------------------------------------
// The API for this library is very big. However, most of the methods do the
// exact same thing as their native counterparts. As well, methods which share
// the same name do the same thing, with some minor differences.
// 
//------------------------------------------------------------------------------
// An Important Note:
// 
// All of the array access methods (That is, the [] methods) which return a
// BoardRow, BoardColumn, or BoardItem, will accept values greater than the size
// of the Board. They will resize the board so that it contains the requested
// item.
// 
// Note that if you have a BoardItem, BoardRow, or BoardColumn object, and
// destroy the board they point to, weird things can happen if you use them. So
// please try to make sure you don't use BoardItem/Row/Column objects if the
// Board they belong to has been destroyed.
//
// The values of BoardRow, BoardColumn, and BoardItem instances can and will go
// above 8190. They are not suitable for use as array indexes. Instances of the
// Board struct itself are suitable for that use.
// 
//------------------------------------------------------------------------------
// The Board struct:
// 
// local Board board = Board.create()
//     When created, a Board object will have 0 columns and 0 rows. It will have
//     no title. The default settings for items are set such that new items will
//     display only text, not icons, and will have a width of 0.
// 
// set board.title = "string"
//     Sets the title of the multiboard. Identical to the native.
// 
// set board.titleColor = 0xFFFF00
//     Sets the color of the title of the multiboard to the given ARGB color.
// 
// 
// set board.visible = true
//     Makes the board visible for all players if set to true, and hidden for all
//     players if set to false.
// 
// set board.visible[Player(0)] = false
//     Makes the board visible/hidden for the given player
// 
// local boolean b = board.visible[Player(0)]
//     Returns true if the board is visible for the given player; false otherwise.
// 
// 
// set board.minimized = true
//     Minimizes/restores the board for all players.
//
// set board.minimized[Player(0)] = false
//     Minimizes/restores the board for the given player only.
// 
// 
// call board.clear()
//     Removes all items from the board. The same as the native.
// 
// 
// local BoardItem it = board[x][y]
//     Returns the BoardItem located in column x, row y.
// 
// 
// local BoardColumn col = board.col[x]
//     Returns the BoardColumn object for the given column of the board.
// 
// set board.col.count = 10
//     Resizes the board such that it has the given number of columns.
// 
// local integer i = board.col.count
//     Returns the number of columns a board currently has.
// 
// 
// local BoardRow row = board.row[y]
//     Returns the BoardRow object for the given row of the board.
// 
// set board.row.count = 10
//     Resizes the board such that it has the given number of rows.
// 
// local integer i = board.row.count
//     Returns the number of rows a board currently has.
// 
// board.all
//     Using board.all, you can modify the item properties of all items at once,
//     as well as change the default properties for items in new rows and
//     columns. Example:
//     
//     set board.all.width = 0.03
//     
//     See the "Item Manipulation" section for information on the methods that
//     board.all has.
//------------------------------------------------------------------------------
// Item Manipulation:
// 
// This section details the methods which all structs this library provides has.
// Namely, the methods that modify the properties of board items.
// 
// When these methods are called from a row, they modify all of the items in
// that row of the board.
// 
// The same for columns.
// 
// When called on BoardItems, they only modify the given item.
// 
// When called from board.all, they modify all the items on the board, and
// change the default properties for newly added items. (Items are added by the
// board gaining rows and columns.)
// 
// Explanation of the methods follows:
// 
// local BoardItem it = board[0][0]
// 
// set it.text = "string"
//      Changes the displayed text for the given item/row/etc.
// 
// set it.color = 0xFFFFFF
//      Changes the colour of the displayed text.
// 
// set it.icon = "ReplaceableTextures\\..."
//      Changes the icon of the item/row/etc.
// 
// set it.width = 0.04
//      Changes the width of the item/row/etc. These width values are the same
//      as those used by native multiboards.
// 
// call it.setDisplay(shouldDisplayText, shouldDisplayIcon)
//      The same as the MultiboardSetItemStyle() native. The first parameter
//      determines if the text for the item/row/etc. will be displayed.
//      The second parameter determines if the icon will be displayed.
//
//------------------------------------------------------------------------------
// The BoardRow and BoardColumn structs:
// 
// Note that these both have the exact same methods. The difference is, of
// course, one represents a row of items in a Board, while the other represents
// a column of items. BoardRow is used below, but it is fully interchangeable.
// 
// local BoardRow row = board.row[10]
// 
// local BoardItem it = row[y]
//      Returns the BoardItem that is in the row, at column y. For a BoardColumn
//      object, it takes the row as it's parameter instead of the column.
// 
// local integer whatRow = row.position
//      Returns the row or columns position in the board. That is to say:
//      board.row[10].position is equal to 10.
// 
// The BoardRow and BoardColumn structs have all of the methods listed in the
// "Item Manipulation" section.
// 
//------------------------------------------------------------------------------
// The BoardItem struct:
// 
// local BoardItem it = board[0][1]
// 
// local integer itemsColumn = it.x
//      Returns the item's x position in the board. (The ID of the column the
//      item is in.)
// 
// local integer itemsRow = it.y
//      The same as it.x, but it returns the row.
// 
// The BoardItem struct has all of the methods listed in the "Item Manipulation"
// section of this API guide.
//
//==============================================================================
// There is nothing to configure.
//==============================================================================

// Hopefully this will be inlined one day...
private constant function Mod takes integer dividend, integer divisor returns integer
    return dividend - (dividend / divisor) * divisor
endfunction

private constant function B2S takes boolean b returns string
    if b then
        return "true"
    endif
    return "false"
endfunction

private function ErrorMsg takes string what, string error returns nothing
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "Board Error: " + what + ": " + error)
endfunction

// ============================================================
// Private keywords
// ============================================================

private keyword bBoard
private keyword bColCount
private keyword bRowCount
private keyword bTemp
private keyword bVisibleFor

// ============================================================
// Item Struct
// ============================================================

struct BoardItem extends array
    // =====
    // Notes:
    // -----
    // this  = board * 10000 + row * 100 + col
    // 
    // k     = Mod(integer(this), 10000)
    //
    // row   = (k - Mod(k, 100)) / 100
    // col   = Mod(k, 100)
    // board = (integer(this) - k) / 10000
    //
    // row   = (Mod(integer(this), 10000) - Mod(Mod(integer(this), 10000), 100)) / 100
    // col   = Mod(Mod(integer(this), 10000), 100)
    // board = (integer(this) - Mod(integer(this), 10000)) / 10000
    // =====
    
    public method operator x takes nothing returns integer
        return Mod(Mod(integer(this), 10000), 100)
    endmethod
    
    public method operator y takes nothing returns integer
        return (Mod(integer(this), 10000) - Mod(Mod(integer(this), 10000), 100)) / 100
    endmethod
    
    // ==============
    
    public method operator text= takes string val returns nothing
        local integer k = Mod(integer(this), 10000)
        local Board board = Board((integer(this) - k) / 10000)
        local integer row = (k - Mod(k, 100)) / 100
        local integer col = Mod(k, 100)
        local multiboarditem mbi
        
        if board.bBoard == null then
            debug call ErrorMsg("BoardItem[" + I2S(col) + "][" + I2S(row) + "].text=", "The board this item belongs to does not exist anymore")
            return
        endif
        
        if row >= board.bRowCount then
            debug call ErrorMsg("BoardItem.text=", "The board has been shrunk to no longer include this item. Will resize the board.")
            call MultiboardSetRowCount(board.bBoard, row + 1)
            set board.bRowCount = row + 1
        endif
        if col >= board.bColCount then
            debug call ErrorMsg("BoardItem.text=", "The board has been shrunk to no longer include this item. Will resize the board.")
            call MultiboardSetColumnCount(board.bBoard, col + 1)
            set board.bColCount = col + 1
        endif
        
        set mbi =  MultiboardGetItem(board.bBoard, row, col)
        
        call MultiboardSetItemValue(mbi, val)
        
        call MultiboardReleaseItem(mbi)
        
        set mbi = null
    endmethod
    
    public method operator icon= takes string val returns nothing
        local integer k = Mod(integer(this), 10000)
        local Board board = Board((integer(this) - k) / 10000)
        local integer row = (k - Mod(k, 100)) / 100
        local integer col = Mod(k, 100)
        local multiboarditem mbi
        
        if board.bBoard == null then
            debug call ErrorMsg("BoardItem[" + I2S(col) + "][" + I2S(row) + "].icon=", "The board this item belongs to does not exist anymore")
            return
        endif
        
        if row >= board.bRowCount then
            debug call ErrorMsg("BoardItem.icon=", "The board has been shrunk to no longer include this item. Will resize the board.")
            call MultiboardSetRowCount(board.bBoard, row + 1)
            set board.bRowCount = row + 1
        endif
        if col >= board.bColCount then
            debug call ErrorMsg("BoardItem.icon=", "The board has been shrunk to no longer include this item. Will resize the board.")
            call MultiboardSetColumnCount(board.bBoard, col + 1)
            set board.bColCount = col + 1
        endif
        
        set mbi =  MultiboardGetItem(board.bBoard, row, col)
        
        call MultiboardSetItemIcon(mbi, val)
        
        call MultiboardReleaseItem(mbi)
        
        set mbi = null
    endmethod
    
    public method operator color= takes ARGB c returns nothing
        local integer k = Mod(integer(this), 10000)
        local Board board = Board((integer(this) - k) / 10000)
        local integer row = (k - Mod(k, 100)) / 100
        local integer col = Mod(k, 100)
        local multiboarditem mbi
        
        if board.bBoard == null then
            debug call ErrorMsg("BoardItem[" + I2S(col) + "][" + I2S(row) + "].color=", "The board this item belongs to does not exist anymore")
            return
        endif
        
        if row >= board.bRowCount then
            debug call ErrorMsg("BoardItem.color=", "The board has been shrunk to no longer include this item. Will resize the board.")
            call MultiboardSetRowCount(board.bBoard, row + 1)
            set board.bRowCount = row + 1
        endif
        if col >= board.bColCount then
            debug call ErrorMsg("BoardItem.color=", "The board has been shrunk to no longer include this item. Will resize the board.")
            call MultiboardSetColumnCount(board.bBoard, col + 1)
            set board.bColCount = col + 1
        endif
        
        set mbi =  MultiboardGetItem(board.bBoard, row, col)
        
        call MultiboardSetItemValueColor(mbi, c.red, c.green, c.blue, c.alpha)
        
        call MultiboardReleaseItem(mbi)
        
        set mbi = null
    endmethod
    
    public method operator width= takes real r returns nothing
        local integer k = Mod(integer(this), 10000)
        local Board board = Board((integer(this) - k) / 10000)
        local integer row = (k - Mod(k, 100)) / 100
        local integer col = Mod(k, 100)
        local multiboarditem mbi
        
        if board.bBoard == null then
            debug call ErrorMsg("BoardItem[" + I2S(col) + "][" + I2S(row) + "].width=", "The board this item belongs to does not exist anymore")
            return
        endif
        
        if row >= board.bRowCount then
            debug call ErrorMsg("BoardItem.width=", "The board has been shrunk to no longer include this item. Will resize the board.")
            call MultiboardSetRowCount(board.bBoard, row + 1)
            set board.bRowCount = row + 1
        endif
        if col >= board.bColCount then
            debug call ErrorMsg("BoardItem.width=", "The board has been shrunk to no longer include this item. Will resize the board.")
            call MultiboardSetColumnCount(board.bBoard, col + 1)
            set board.bColCount = col + 1
        endif
        
        set mbi =  MultiboardGetItem(board.bBoard, row, col)
        
        call MultiboardSetItemWidth(mbi, r)
        
        call MultiboardReleaseItem(mbi)
        
        set mbi = null
    endmethod
    
    public method setDisplay takes boolean text, boolean icon returns nothing
        local integer k = Mod(integer(this), 10000)
        local Board board = Board((integer(this) - k) / 10000)
        local integer row = (k - Mod(k, 100)) / 100
        local integer col = Mod(k, 100)
        local multiboarditem mbi
        
        if board.bBoard == null then
            debug call ErrorMsg("BoardItem[" + I2S(col) + "][" + I2S(row) + "].setDisplay()", "The board this item belongs to does not exist anymore")
            return
        endif
        
        if row >= board.bRowCount then
            debug call ErrorMsg("BoardItem.setDisplay()", "The board has been shrunk to no longer include this item. Will resize the board.")
            call MultiboardSetRowCount(board.bBoard, row + 1)
            set board.bRowCount = row + 1
        endif
        if col >= board.bColCount then
            debug call ErrorMsg("BoardItem.setDisplay()", "The board has been shrunk to no longer include this item. Will resize the board.")
            call MultiboardSetColumnCount(board.bBoard, col + 1)
            set board.bColCount = col + 1
        endif
        
        set mbi =  MultiboardGetItem(board.bBoard, row, col)
        
        call MultiboardSetItemStyle(mbi, text, icon)
        
        call MultiboardReleaseItem(mbi)
        
        set mbi = null
    endmethod
endstruct

// ============================================================
// BoardRow and BoardColumn structs
// ============================================================

//! textmacro Board_DeclareRowCol takes I, K, NAME, COUNT_FUNC, OTHER, THIS
struct Board$NAME$ extends array
    // =====
    // Notes:
    // -----
    // this  = board * 100 + pos
    // pos   = Mod(integer(this), 100)
    // board = (integer(this) - Mod(integer(this), 100)) / 100
    // =====
    
    public method operator [] takes integer $K$ returns BoardItem
        local Board board = ((integer(this) - Mod(integer(this), 100)) / 100)
        local integer $I$ = Mod(integer(this), 100)
        
        if $K$ >= board.b$OTHER$Count then
            call MultiboardSet$COUNT_FUNC$Count(board.bBoard, $K$ + 1)
            set board.b$OTHER$Count = $K$ + 1
        endif
        
        return BoardItem(integer(board) * 10000 + $I$ * 100 + $K$)
    endmethod
    
    public method operator position takes nothing returns integer
        return Mod(integer(this), 100)
    endmethod
    
    // ==============
    
    public method operator text= takes string val returns nothing
        local Board board = Board((integer(this) - Mod(integer(this), 100)) / 100)
        local integer $I$ = thistype(Mod(integer(this), 100))
        
        local multiboarditem mbi
        local integer $K$ = 0
        
        if board.bBoard == null then
            debug call ErrorMsg("Board$NAME$[" + I2S(col) + "][" + I2S(row) + "].text=", "The board this $I$ belongs to does not exist anymore")
            return
        endif
        
        if $I$ >= board.b$THIS$Count then
            debug call ErrorMsg("Board$NAME$.text=", "The board has been shrunk to no longer include this $I$. Will resize the board.")
            call MultiboardSetRowCount(board.bBoard, $I$ + 1)
            set board.b$THIS$Count = $I$ + 1
        endif
        
        loop
            exitwhen $K$ == board.b$OTHER$Count
            set mbi = MultiboardGetItem(board.bBoard, row, col)
            
            call MultiboardSetItemValue(mbi, val)
            
            call MultiboardReleaseItem(mbi)
            set $K$ = $K$ + 1
        endloop
        
        set mbi = null
    endmethod
    
    public method operator icon= takes string val returns nothing
        local Board board = Board((integer(this) - Mod(integer(this), 100)) / 100)
        local integer $I$ = thistype(Mod(integer(this), 100))
        
        local multiboarditem mbi
        local integer $K$ = 0
        
        if board.bBoard == null then
            debug call ErrorMsg("Board$NAME$[" + I2S(col) + "][" + I2S(row) + "].icon=", "The board this $I$ belongs to does not exist anymore")
            return
        endif
        
        if $I$ >= board.b$THIS$Count then
            debug call ErrorMsg("Board$NAME$.icon=", "The board has been shrunk to no longer include this $I$. Will resize the board.")
            call MultiboardSetRowCount(board.bBoard, $I$ + 1)
            set board.b$THIS$Count = $I$ + 1
        endif
        
        loop
            exitwhen $K$ == board.b$OTHER$Count
            set mbi = MultiboardGetItem(board.bBoard, row, col)
            
            call MultiboardSetItemIcon(mbi, val)
            
            call MultiboardReleaseItem(mbi)
            set $K$ = $K$ + 1
        endloop
        
        set mbi = null
    endmethod
    
    public method operator color= takes ARGB c returns nothing
        local Board board = Board((integer(this) - Mod(integer(this), 100)) / 100)
        local integer $I$ = thistype(Mod(integer(this), 100))
        
        local multiboarditem mbi
        local integer $K$ = 0
        
        if board.bBoard == null then
            debug call ErrorMsg("Board$NAME$[" + I2S(col) + "][" + I2S(row) + "].color=", "The board this $I$ belongs to does not exist anymore")
            return
        endif
        
        if $I$ >= board.b$THIS$Count then
            debug call ErrorMsg("Board$NAME$.color=", "The board has been shrunk to no longer include this $I$. Will resize the board.")
            call MultiboardSetRowCount(board.bBoard, $I$ + 1)
            set board.b$THIS$Count = $I$ + 1
        endif
        
        loop
            exitwhen $K$ >= board.b$OTHER$Count
            set mbi = MultiboardGetItem(board.bBoard, row, col)
            
            call MultiboardSetItemValueColor(mbi, c.red, c.green, c.blue, c.alpha)
            
            call MultiboardReleaseItem(mbi)
            set $K$ = $K$ + 1
        endloop
        
        set mbi = null
    endmethod
    
    public method operator width= takes real r returns nothing
        local Board board = Board((integer(this) - Mod(integer(this), 100)) / 100)
        local integer $I$ = thistype(Mod(integer(this), 100))
        
        local multiboarditem mbi
        local integer $K$ = 0
        
        if board.bBoard == null then
            debug call ErrorMsg("Board$NAME$[" + I2S(col) + "][" + I2S(row) + "].width=", "The board this $I$ belongs to does not exist anymore")
            return
        endif
        
        if $I$ >= board.b$THIS$Count then
            debug call ErrorMsg("Board$NAME$.width=", "The board has been shrunk to no longer include this $I$. Will resize the board.")
            call MultiboardSetRowCount(board.bBoard, $I$ + 1)
            set board.b$THIS$Count = $I$ + 1
        endif
        
        loop
            exitwhen $K$ == board.b$OTHER$Count
            set mbi = MultiboardGetItem(board.bBoard, row, col)
            
            call MultiboardSetItemWidth(mbi, r)

            call MultiboardReleaseItem(mbi)
            set $K$ = $K$ + 1
        endloop
        
        set mbi = null
    endmethod
    
    public method setDisplay takes boolean text, boolean icon returns nothing
        local Board board = Board((integer(this) - Mod(integer(this), 100)) / 100)
        local integer $I$ = thistype(Mod(integer(this), 100))
        
        local multiboarditem mbi
        local integer $K$ = 0
        
        if board.bBoard == null then
            debug call ErrorMsg("Board$NAME$[" + I2S(col) + "][" + I2S(row) + "].setDisplay()", "The board this $I$ belongs to does not exist anymore")
            return
        endif
        
        if $I$ >= board.b$THIS$Count then
            debug call ErrorMsg("Board$NAME$.setDisplay()", "The board has been shrunk to no longer include this $I$. Will resize the board.")
            call MultiboardSetRowCount(board.bBoard, $I$ + 1)
            set board.b$THIS$Count = $I$ + 1
        endif
        
        loop
            exitwhen $K$ == board.b$OTHER$Count
            set mbi = MultiboardGetItem(board.bBoard, row, col)
            
            call MultiboardSetItemStyle(mbi, text, icon)
            
            call MultiboardReleaseItem(mbi)
            set $K$ = $K$ + 1
        endloop
        
        set mbi = null
    endmethod
endstruct
//! endtextmacro

//! runtextmacro Board_DeclareRowCol("row", "col", "Row",    "Column", "Col", "Row")
//! runtextmacro Board_DeclareRowCol("col", "row", "Column", "Row",    "Row", "Col")

// ============================================================
// Helper Structs (For [][], .col[], .row[], etc)
// ============================================================

private struct ItemHelper extends array
    public method operator[] takes integer row returns BoardItem
        local integer col = Board.bTemp
        
        if row < 0 then
            debug call ErrorMsg("Board[" + I2S(col) + "][" + I2S(row) + "]", "Given row id is less than 0")
            return 0
        elseif col < 0 then
            debug call ErrorMsg("Board[" + I2S(col) + "][" + I2S(row) + "]", "Given col id is less than 0")
            return 0
        endif
        //i = brd * 10000 + row * 100 + col
        
        if col >= Board(this).bColCount then
            call MultiboardSetColumnCount(Board(this).bBoard, col + 1)
            set Board(this).bColCount = col + 1
        endif
        
        if row >= Board(this).bRowCount then
            call MultiboardSetRowCount(Board(this).bBoard, row + 1)
            set Board(this).bRowCount = row + 1
        endif
        
        return integer(this) * 10000 + row * 100 + Board(this).bTemp
    endmethod
endstruct

private struct RowHelper extends array
    public method operator count takes nothing returns integer
        return Board(this).bRowCount
    endmethod
    public method operator count= takes integer i returns nothing
        call MultiboardSetRowCount(Board(this).bBoard, i + 1)
        set Board(this).bRowCount = i + 1
    endmethod
    
    public method operator[] takes integer row returns BoardRow
        if row < 0 then
            debug call ErrorMsg("Board.row[" + I2S(row) + "]", "Given row id is less than 0")
            return 0
        endif
        
        if row >= Board(this).bRowCount then
            call MultiboardSetRowCount(Board(this).bBoard, row + 1)
            set Board(this).bRowCount = row + 1
        endif
        
        if Board(this).bColCount < 1 then
            call MultiboardSetColumnCount(Board(this).bBoard, 1)
            set Board(this).bColCount = 1
        endif
        
        return BoardRow(row + integer(this) * 100)
    endmethod
endstruct

private struct ColumnHelper extends array
    public method operator count takes nothing returns integer
        return Board(this).bColCount
    endmethod
    public method operator count= takes integer i returns nothing
        call MultiboardSetColumnCount(Board(this).bBoard, i + 1)
        set Board(this).bColCount = i + 1
    endmethod
    
    public method operator[] takes integer col returns BoardColumn
        if col < 0 then
            debug call ErrorMsg("Board.col[" + I2S(col) + "]", "Given column id is less than 0")
            return 0
        endif
        
        if col >= Board(this).bColCount then
            call MultiboardSetColumnCount(Board(this).bBoard, col + 1)
            set Board(this).bColCount = col + 1
        endif
        
        if Board(this).bRowCount < 1 then
            call MultiboardSetRowCount(Board(this).bBoard, 1)
            set Board(this).bRowCount = 1
        endif
        
        return BoardColumn(col + integer(this) * 100)
    endmethod
endstruct

private struct VisibleHelper extends array
    public method operator []= takes player p, boolean b returns nothing
        if GetPlayerId(p) > 11 then
            debug call ErrorMsg("Board.visible[\"" + GetPlayerName(p) + "\"]=" + B2S(b), "Given player is a neutral player")
            return
        endif
        
        set Board(this).bVisibleFor[GetPlayerId(p)] = b
        
        if GetLocalPlayer() == p then
            call MultiboardDisplay(Board(this).bBoard, b)
        endif
    endmethod
    public method operator [] takes player p returns boolean
        if GetPlayerId(p) > 11 then
            debug call ErrorMsg("Board.visible[\"" + GetPlayerName(p) + "\"]", "Given player is a neutral player")
            return false
        endif
        
        return Board(this).bVisibleFor[GetPlayerId(p)]
    endmethod
endstruct

private struct MinimizedHelper extends array
    public method operator[]= takes player p, boolean b returns nothing
        if GetPlayerId(p) > 11 then
            debug call ErrorMsg("Board.minimized[\"" + GetPlayerName(p) + "\"]=" + B2S(b), "Given player is a neutral player")
            return
        endif
        
        if GetLocalPlayer() == p then
            call MultiboardMinimize(Board(this).bBoard, b)
        endif
    endmethod
endstruct

private struct AllHelper extends array
    public method operator text= takes string val returns nothing
        call MultiboardSetItemsValue(Board(this).bBoard, val)
    endmethod
    
    public method operator icon= takes string val returns nothing
        call MultiboardSetItemsIcon(Board(this).bBoard, val)
    endmethod
    
    public method operator color= takes ARGB c returns nothing
        call MultiboardSetItemsValueColor(Board(this).bBoard, c.red, c.green, c.blue, c.alpha)
    endmethod
    
    public method operator width= takes real r returns nothing
        call MultiboardSetItemsWidth(Board(this).bBoard, r)
    endmethod
    
    public method setDisplay takes boolean text, boolean icon returns nothing
        call MultiboardSetItemsStyle(Board(this).bBoard, text, icon)
    endmethod
endstruct

// ============================================================
// Board Struct
// ============================================================

struct Board
    multiboard bBoard
    
    integer bColCount = 0
    integer bRowCount = 0
    
    boolean array bVisibleFor[12]
    
    static integer bTemp
    
    public static method create takes nothing returns thistype
        local thistype this = allocate()
        
        set bBoard = CreateMultiboard()
        
        call MultiboardSetItemsWidth(bBoard, 0.01)
        call MultiboardSetItemsStyle(bBoard, true, false)
        
        return this
    endmethod
    
    private method onDestroy takes nothing returns nothing
        call DestroyMultiboard(bBoard)
        set bBoard = null
    endmethod
    
    //==================
    
    public method operator[] takes integer column returns ItemHelper
        set bTemp = column
        return ItemHelper(this)
    endmethod
    
    public method operator col takes nothing returns ColumnHelper
        return ColumnHelper(this)
    endmethod
    
    public method operator row takes nothing returns RowHelper
        return RowHelper(this)
    endmethod
    
    //==================
    
    public method operator all takes nothing returns AllHelper
        return AllHelper(this)
    endmethod
    
    public method operator title= takes string value returns nothing
        call MultiboardSetTitleText(bBoard, value)
    endmethod
    
    public method operator titleColor= takes ARGB color returns nothing
        call MultiboardSetTitleTextColor(bBoard, color.red, color.green, color.blue, color.alpha)
    endmethod
    
    public method operator visible takes nothing returns VisibleHelper
        return VisibleHelper(this)
    endmethod
    public method operator visible= takes boolean b returns nothing
        local integer i = 0
        loop
            exitwhen i == 12
            
            set bVisibleFor[i] = b
            
            set i = i + 1
        endloop
        
        call MultiboardDisplay(bBoard, b)
    endmethod
    
    public method operator minimized takes nothing returns MinimizedHelper
        return MinimizedHelper(this)
    endmethod
    public method operator minimized= takes boolean b returns nothing
        call MultiboardMinimize(bBoard, b)
    endmethod
    
    public method clear takes nothing returns nothing
        call MultiboardClear(bBoard)
    endmethod
endstruct

endlibrary
