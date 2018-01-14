/**
 * Ustawia datę wykonania płatności dla wybranego BookingID 
 */
create procedure setPaid (
	@bookingID    int,
	@paymentDate  date,
	@todaysDate   date = null
) as 
	set xact_abort on;
	begin transaction;
		if @todaysDate is not null
		begin 
			update Bookings
			set PaymentDate = @paymentDate
			where BookingID = @bookingID;
		end
		if @todaysDate is null
		begin
			update Bookings
			set PaymentDate = GETDATE() 
			where BookingID = @bookingID;
		end
	commit transaction
go

