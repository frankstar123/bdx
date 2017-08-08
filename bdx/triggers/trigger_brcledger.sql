SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[trig_brcledger] on [dbo].[ic_brcledger]
instead of insert as
BEGIN
	DECLARE @Branch int;
	DECLARE @PK varchar(28);
	DECLARE @ClientRef varchar(10);
	DECLARE @PolicyId varchar(10);
	DECLARE @PolicyType varchar(2);
	DECLARE @Suffix int;
	DECLARE @TransType varchar(14);
	DECLARE @DateRaised datetime;
	DECLARE @Insurer varchar(40);
	DECLARE @OriginalDebt float;
	DECLARE @CommissionAmount float;
	DECLARE @IptRate float;
	DECLARE @IptAmount float;
	DECLARE @YearOfAccount int;
	DECLARE @AgentCommission float;

	DECLARE c_inserted cursor for
		                     --SELECT Branch@,[Key@],[ClientRef@], [PolicyRef@],[Suffix@],[Poltype#],[Trantype#], [Dt_raised] from INSERTED
					SELECT B@,[Key@],[Ref@], [PolRef@],[Suffix@],[Poltype],[Trantype],[Dt_raised], [Insurer] , [Orig_debt], [Comm_amt],
					[Ipt_rate],[ipt_amount],[yoa],[Agent_comm] from INSERTED
					
	open c_inserted
	fetch next from c_inserted into @Branch, @PK, @ClientRef, @PolicyId, @Suffix, @PolicyType, @TransType, @DateRaised,@Insurer,@OriginalDebt,
									@CommissionAmount,@IptRate,@IptAmount,@YearOfAccount,@AgentCommission
	while @@FETCH_STATUS <> -1
	begin
		exec dbo.bdxManagement @Branch, @PK, @ClientRef, @PolicyId,@Suffix, @PolicyType, @TransType, @DateRaised, 'Create',@YearOfAccount;
		fetch next from c_inserted into @Branch, @PK, @ClientRef, @PolicyId, @Suffix, @PolicyType, @TransType, @DateRaised,@Insurer,@OriginalDebt,@CommissionAmount,@IptRate,@IptAmount,@YearOfAccount,@AgentCommission
		
	end
	close c_inserted;
	deallocate c_inserted;
END;

