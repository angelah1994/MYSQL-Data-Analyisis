SELECT * INTO Nashvilehousing
FROM OPENROWSET('Microsoft.ACE.OLEDB.16.0',
'Excel 12.0 Xml;Database=C:\Users\Admin\Downloads\Nashville Housing Data for Data Cleaning (reuploaded).xlsx;HDR=YES;',
'SELECT * FROM [sheet1$]')
