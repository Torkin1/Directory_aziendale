-- op 5

CREATE PROCEDURE `elencaTrasferimentiDipendente` (in cfDipendente char(16))
BEGIN
	select *
    from TRASFERITO_A
    where TRASFERITO_A.CFDipendente = cfDipendente or cfDipendente is null
    order by CFDipendente, `Data`;
END