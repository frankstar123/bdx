SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetFullName]
(
	@ClientRef as varchar(10)
)
RETURNS varchar(max)
as
BEGIN
	DECLARE @returnString varchar(max) = '' ;
	DECLARE @RowCount int = 0;
	
	select @RowCount = count(*) from BF_LNAM where ref@ = @ClientRef;
	if(@RowCount = 0)
		select @returnString = [Name#] from yyclient where ref@ = @ClientRef;
	ELSE
		select @returnString = concat(text1#,text2#,text3#,text4#,text5#,text6#,text7#,text8#,text9#,text10#,text11#,text12#) from BF_LNAM where ref@ = @ClientRef;
	return @returnString;
END