SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[rep_bdx_ledger](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[timestamp] [datetime] NOT NULL,
	[method] [varchar](28) NOT NULL,
	[version] [int] NULL,
	[branch] [int] NOT NULL,
	[key] [varchar](28) NOT NULL,
	[clientRef] [varchar](20) NOT NULL,
	[policyRef] [varchar](20) NOT NULL,
	[suffix] [int] NOT NULL,
	[policyType] [varchar](2) NOT NULL,
	[transType] [varchar](20) NOT NULL,
	[dateRaised] [datetime] NOT NULL,
	[processed] [int] NULL
) ON [PRIMARY]

GO

