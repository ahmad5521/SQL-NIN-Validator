--NIN
INSERT INTO InvalidCustomers
SELECT CustomerNIN
	,ArabicName
	,EnglishName
	,Email
	,Mobile
	,1
	,N'NIN ERROE'
FROM Customer
WHERE dbo.IsValidNIN(CustomerNIN) = 0

--ArabicName
INSERT INTO InvalidCustomers
SELECT CustomerNIN
	,ArabicName
	,EnglishName
	,Email
	,Mobile
	,2
	,N'ArabicName ERROE'
FROM Customer
WHERE dbo.IsArabicText(ArabicName) = 0

--EnglishName
INSERT INTO InvalidCustomers
SELECT CustomerNIN
	,ArabicName
	,EnglishName
	,Email
	,Mobile
	,3
	,N'EnglishName ERROE'
FROM Customer
WHERE dbo.IsEnglishText(EnglishName) = 0

--Email
INSERT INTO InvalidCustomers
SELECT CustomerNIN
	,ArabicName
	,EnglishName
	,Email
	,Mobile
	,4
	,N'Email ERROE'
FROM Customer
WHERE patindex('%[ &'',":;!+=\/()<>]%', Email) > 0 -- Invalid characters
	OR patindex('[@.-_]%', Email) > 0 -- Valid but cannot be starting character
	OR patindex('%[@.-_]', Email) > 0 -- Valid but cannot be ending character
	OR Email NOT LIKE '%@%.%' -- Must contain at least one @ and one .
	OR Email LIKE '%..%' -- Cannot have two periods in a row
	OR Email LIKE '%@%@%' -- Cannot have two @ anywhere
	OR Email LIKE '%.@%'
	OR Email LIKE '%@.%' -- Cannot have @ and . next to each other
	OR Email LIKE '%.cm'
	OR Email LIKE '%.co' -- Camaroon or Colombia? Typos.
	OR Email LIKE '%.or'
	OR Email LIKE '%.ne' -- Missing last letter

--Mobile
INSERT INTO InvalidCustomers
SELECT CustomerNIN
	,ArabicName
	,EnglishName
	,Email
	,Mobile
	,5
	,N'Mobile ERROE'
FROM Customer
WHERE NOT (
		(
			Mobile LIKE '05%'
			AND LEN(Mobile) = 10
			)
		OR (
			Mobile LIKE '5%'
			AND LEN(Mobile) = 9
			)
		OR (
			Mobile LIKE '966%'
			AND LEN(Mobile) = 12
			)
		OR (
			Mobile LIKE '+966%'
			AND LEN(Mobile) = 13
			)
		OR (
			Mobile LIKE '00966%'
			AND LEN(Mobile) = 14
			)
		)