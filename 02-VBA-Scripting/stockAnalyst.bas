Attribute VB_Name = "Module11"
Sub stockAnalyst()
For Each ws In Worksheets
    'Insert headers
    ws.Cells(1, 9).Value = "Ticker"
    ws.Cells(1, 10).Value = "Yearly Change"
    ws.Cells(1, 11).Value = "Percent Change"
    ws.Cells(1, 12).Value = "Total Stock Volume"
    
    'Declare variables
    Dim tick As String
    Dim op, cl, totVol, yearChange, perChange As Double
    
    'Find last row
    Dim lastRow As Long
    lastRow = ws.Cells(Rows.Count, 1).End(xlUp).Row
    
    'Hold total volume
    totVol = 0
    
    'Keep track of the location for each stock in summary table
    Dim Summary_Table_Row As Integer
    Summary_Table_Row = 2
    
    'Sort by date and ticker symbol to be able to later find open and closing prices for the year for each stock
    With ActiveSheet.Sort
        .SortFields.Add Key:=Range("A1"), Order:=xlAscending
        .SortFields.Add Key:=Range("B1"), Order:=xlAscending
        .SetRange Range("A:G")
        .Header = xlYes
        .Apply
    End With
    
   
    'Lopp through rows to find what we need
    For i = 2 To lastRow
        'Find our opening price
        If ws.Cells(i, 1).Value <> ws.Cells(i - 1, 1).Value Then
            op = ws.Cells(i, 3).Value
        End If
        'Find unique ticker IDs
        If ws.Cells(i, 1).Value <> ws.Cells(i + 1, 1).Value Then
            'Add to total stock volume
            totVol = totVol + ws.Cells(i, 7).Value
            'Find closing price
            cl = ws.Cells(i, 6).Value
            'Find yearly change in price
            yearChange = cl - op
            'Find percent change, but first need to account for div/0
            If op = 0 Then
                Dim newStock As String
                newStock = "New Stock, Null value"
                ws.Cells(Summary_Table_Row, 11).Value = newStock
                Else
                perChange = (cl - op) / op
                ws.Cells(Summary_Table_Row, 11).Value = perChange
                'Format to %
                ws.Cells(Summary_Table_Row, 11).NumberFormat = "0.00%"
            End If
            
            'Store unique ticker IDs, yearly change, percent change, and stock volume into a table
            ws.Cells(Summary_Table_Row, 9).Value = ws.Cells(i, 1).Value
            ws.Cells(Summary_Table_Row, 10).Value = yearChange
            ws.Cells(Summary_Table_Row, 12).Value = totVol
            'Add 1 to summary table
            Summary_Table_Row = Summary_Table_Row + 1
            'Reset total stock volume
            totVol = 0
            Else
            'If ticker ID is the same, continue adding to total
            totVol = totVol + ws.Cells(i, 7)
        End If
        'Format yearly change
        If ws.Cells(i, 10) >= 0 Then
            ws.Cells(i, 10).Interior.ColorIndex = 4
            Else
            ws.Cells(i, 10).Interior.ColorIndex = 3
        End If
    Next i
Next ws
End Sub
