SELECT * INTO retails
FROM OPENROWSET('Microsoft.ACE.OLEDB.16.0',
'Excel 12.0 Xml;Database=C:\Users\Admin\Documents\online_retail\Online Retail.xlsx;HDR=YES;',
'SELECT * FROM [Retail$]')
