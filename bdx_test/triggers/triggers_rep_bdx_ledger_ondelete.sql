CREATE TRIGGER [dbo].[trigger_brcledger_delete_test] on [dbo].[rep_bdx_ledger_test]
    for delete 
As
BEGIN
    DECLARE @OGIKEY varchar(30);
    DECLARE @LedgerId int;

    DECLARE c_deleted cursor for
    SELECT [Key@] from DELETED;

    open c_deleted
    fetch next from c_deleted into @OGIKEY
    while @@FETCH_STATUS <> -1
    begin
        select @LedgerId = Id from rep_bdx_ledger where [key] = @OGIKEY; 
        delete from rep_bdx_riskdata where LedgerId = @LedgerId;
        delete from rep_bdx_ledger where id = @LedgerId;    
        fetch next from c_deleted into @OGIKEY;
    End;
    close c_deleted;
    deallocate c_deleted;    
END;