require "win32ole"
sheet = WIN32OLE.new('excel.application')
sheet.Visible = true
page1 = sheet.WorkBooks.add

for i in (1..10)
 page1.Sheets[1].Cells(i,1).value = [i]
 end
