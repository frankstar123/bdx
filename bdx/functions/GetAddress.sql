SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetAddress]
(
	@Addr1 as varchar(30),
	@Addr2 as varchar(30),
	@Addr3 as varchar(30),
	@Addr4 as varchar(30),
	@PostCode as varchar (15)
)
RETURNS varchar(max)
as
BEGIN
		Declare @returnString varchar(max) ='';
		if(@Addr1 = 'All Location(s)')
			RETURN @Addr1;
		if(@Addr1 is not null)
			BEGIN
				SET @returnString += @Addr1;
			END
		if(@Addr2 is not null)
			BEGIN
				SET @returnString += ',' + @Addr2;
			END
		if(@Addr3 is not null)
			BEGIN
				Set @returnString += ',' + @Addr3;
			END
		if(@Addr4 is not null)
			BEGIN
				set @returnString += ',' + @Addr4;
			END
		SET @returnString += ',' + @PostCode;
		RETURN @returnString;
END