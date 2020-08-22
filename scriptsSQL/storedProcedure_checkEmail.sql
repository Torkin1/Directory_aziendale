CREATE DEFINER=`root`@`localhost` PROCEDURE `checkEmail`(in email varchar(45))
BEGIN
	if email not like '_%@_%.__%' 
		then signal sqlstate '45001'
        set message_text = "ERROR: invalid Email format, a compliant one is username@hostname.domain";
        end if;
END