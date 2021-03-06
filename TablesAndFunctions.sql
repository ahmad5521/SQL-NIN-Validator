USE [TestDB]
GO
/****** Object:  UserDefinedFunction [dbo].[IsArabicText]    Script Date: 5/14/2020 11:33:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsArabicText] (@input VARCHAR(MAX)) RETURNS BIT


AS
BEGIN


SET @input = REPLACE(@input,' ','')




  DECLARE @allowables char(34) = 'غظضذخثتشرقصفعسنملكيطحزوهدجبأاىؤءئة';
  DECLARE @allowed int = 0; 
  DECLARE @index int = 1;
  WHILE @index <= LEN(@input)
    BEGIN
    IF CHARINDEX(SUBSTRING(@input,@index,1),@allowables)=0
      BEGIN
      SET @allowed = 0;
      BREAK;
      END
    ELSE
      BEGIN
      SET @allowed = 1;
      SET @index = @index+1;
      END
    END
  RETURN @allowed
END






GO
/****** Object:  UserDefinedFunction [dbo].[IsEnglishText]    Script Date: 5/14/2020 11:33:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsEnglishText] (@input VARCHAR(MAX)) RETURNS BIT


AS
BEGIN


SET @input = REPLACE(@input,' ','')




  DECLARE @allowables char(26) = 'abcdefghijklmnopqrstuvwxyz';
  DECLARE @allowed int = 0; 
  DECLARE @index int = 1;
  WHILE @index <= LEN(@input)
    BEGIN
    IF CHARINDEX(SUBSTRING(@input,@index,1),@allowables)=0
      BEGIN
      SET @allowed = 0;
      BREAK;
      END
    ELSE
      BEGIN
      SET @allowed = 1;
      SET @index = @index+1;
      END
    END
  RETURN @allowed
END






GO
/****** Object:  UserDefinedFunction [dbo].[IsValidNIN]    Script Date: 5/14/2020 11:33:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Syed Kashif Ahmed
-- Create date: 12-Mar-2013
-- Updated by: Ahmed Asiri in 13-May-2020
-- Description:	SQL Function to validate National ID (NIN/Iqama). 
--				It doesn't use cursor & doesnt use string funtions => Ideal for bulk ID validation
--				@paramNationalID	=> Input parameter. Must be 10 digit integer
--				Returns 1 for Valid ID
--				Returns 0 for Invalid ID
-- =============================================
CREATE FUNCTION [dbo].[IsValidNIN] 
(
	@InputParameter nvarchar(100)
)
RETURNS bit
--WITH ENCRYPTION
AS
BEGIN
	DECLARE @paramNationalIDISNUMERIC int


	SELECT @paramNationalIDISNUMERIC = ISNUMERIC(@InputParameter)

	IF (@paramNationalIDISNUMERIC = 0)
		RETURN 0

	DECLARE @paramNationalID numeric
	Set @paramNationalID = cast(@InputParameter as numeric)
	DECLARE @MAX_ID_LENGTH as int = 10	
	DECLARE @decIsValidNationalID as bit = 0								-- Result Variable
	DECLARE @decIDNumber as numeric = @paramNationalID						-- Copy of input parameter
	DECLARE @decTblOfNum as TABLE(idDigit int, digitPosition int)			-- Table variable for splitting ID digits
	DECLARE @decNumOfDigits as int = 0										-- For digit count
	DECLARE @decSumOfID as int = 0	
	DECLARE @decCurrentDigitIndex as int = @MAX_ID_LENGTH - 1				-- Initialize with Max Length - 1 (digit counter from 9 to 0)
	DECLARE @decCurrentDigit as int = 0										
	DECLARE @decEvenIndexDigit as int = 0
	DECLARE @decLastDigitOfSum as int = 0
	DECLARE @decLastDigitOfID as int = 0
	
	
	--
	--	MAX LENGTH CHECK
	--
	IF LEN (Convert(VARCHAR,@paramNationalID) ) < @MAX_ID_LENGTH
		RETURN @decIsValidNationalID
	-- 
	-- Split the ID into digits.
	-- Mod returns last digit. Storing decreasing position
	-- 
	WHILE @decIDNumber > 0 
	BEGIN
		INSERT INTO @decTblOfNum VALUES (@decIDNumber % 10, @decCurrentDigitIndex)
		SET @decIDNumber = FLOOR(@decIDNumber / 10.0)
		SET @decCurrentDigitIndex -= 1
	END
	
	--
	-- Reset counters. Digit counting from 0 to 9
	--
	SELECT @decNumOfDigits = COUNT(*) from @decTblOfNum
	SET @decCurrentDigitIndex = 0	
	
	--
	-- Last digit is check digit. Not counted in ID Sum
	--
	WHILE @decNumOfDigits - 1 > @decCurrentDigitIndex	
	BEGIN
		SELECT @decCurrentDigit = idDigit from @decTblOfNum
		WHERE  digitPosition = @decCurrentDigitIndex
		
		IF (@decCurrentDigitIndex % 2) <> 0
			SET @decSumOfID += @decCurrentDigit			
		ELSE
		BEGIN
			SET @decEvenIndexDigit = @decCurrentDigit * 2
			WHILE @decEvenIndexDigit > 0
			BEGIN
				SET @decSumOfID += @decEvenIndexDigit % 10
				SET @decEvenIndexDigit = FLOOR(@decEvenIndexDigit / 10)
			END
		END	
		
		SET @decCurrentDigitIndex += 1
	END
	
	SET @decLastDigitOfSum = @decSumOfID % 10
	SET @decLastDigitOfID = @paramNationalID % 10
	
	--
	-- Result condition check. 
	--
	IF (@decLastDigitOfSum = 0 AND @decLastDigitOfID = 0) OR (10 - @decLastDigitOfSum = @decLastDigitOfID )
		SET @decIsValidNationalID = 1
	
	RETURN @decIsValidNationalID

END
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 5/14/2020 11:33:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerNIN] [nvarchar](50) NULL,
	[ArabicName] [nvarchar](50) NULL,
	[EnglishName] [nvarchar](50) NULL,
	[Email] [nvarchar](50) NULL,
	[Mobile] [nvarchar](15) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvalidCustomers]    Script Date: 5/14/2020 11:33:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvalidCustomers](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerNIN] [nvarchar](50) NULL,
	[ArabicName] [nvarchar](50) NULL,
	[EnglishName] [nvarchar](50) NULL,
	[Email] [nvarchar](50) NULL,
	[Mobile] [nvarchar](15) NULL,
	[ErrorType] [int] NULL,
	[ErrorDescription] [nvarchar](50) NULL
) ON [PRIMARY]
GO
