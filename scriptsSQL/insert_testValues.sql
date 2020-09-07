insert into directory_aziendale.PIANO values (1, "via degli uffici, 12");
insert into directory_aziendale.PIANO values (2, "via degli uffici, 12");
insert into directory_aziendale.PIANO values (0, "via dei test, 55");

insert into directory_aziendale.MANSIONE values ("calcolo bilancio", "contabilità", "ufficioCalcoloBilancio@mail.com");
insert into directory_aziendale.MANSIONE values ("calcolo stipendi", "contabilità", "ufficioCalcoloStipendi@mail.com");
insert into directory_aziendale.MANSIONE values ("reclami", "servizio clienti", "ufficoReclami@mail.com");

insert into directory_aziendale.UFFICIO_FISICO values ("calcolo stipendi", "contabilità", "0001", 1, "via degli uffici, 12");
insert into directory_aziendale.UFFICIO_FISICO values ('a', 'b', "0002", 1, "via degli uffici, 12"); -- must fail for FK
insert into directory_aziendale.UFFICIO_FISICO values ("calcolo bilancio", "contabilità", "0003", 0, "via dei test, 55");

insert into POSTAZIONE values ("3313747567", "0003-01", "0003", "0", "via dei test, 55");
insert into POSTAZIONE values ("1230987654", "0003-02", "0003", "0", "via dei test, 55");
insert into POSTAZIONE values ("2536485834", "0003-03", "0003", "0", "via dei test, 55");
insert into POSTAZIONE values ("1234525234", "0003-04", "0003", "0", "via dei test, 55");
insert into POSTAZIONE values ("2727378237", "0003-05", "0003", "0", "via dei test, 55");
insert into POSTAZIONE values ("3747238924", "0003-06", "0003", "0", "via dei test, 55");
insert into POSTAZIONE values ("8582484945", "0003-07", "0003", "0", "via dei test, 55");
insert into POSTAZIONE values ("7432874987", "0001-01", "0001", 1, "via degli uffici, 12");

insert into TRASFERITO_A values ("LNYRYM72A08Z327C", "8582484945", curdate(), "calcolo bilancio", "contabilità");
insert into TRASFERITO_A values ("TXHTGD97E65H851W", "3313747567", curdate(), "calcolo bilancio", "contabilità");
truncate table TRASFERITO_A;
-- call elencaTrasferimentiDipendente("LNYRYM72A08Z327C");

insert into directory_aziendale.DIPENDENTE values ("TXHTGD97E65H851W", "Paolo", "Bonolis", null, null, null, null, "3313747567", curdate());
insert into directory_aziendale.DIPENDENTE values ("LNYRYM72A08Z327C", "Luca", "Laurenti", null, null, null, null, null, null);
insert into directory_aziendale.DIPENDENTE values ("BGNXNS34P02B229F", "Gerry", "Scotti", null, null, null, null, null, null);
insert into directory_aziendale.DIPENDENTE values ("FQFZPK35T45L146X", "Gandalf", "Il Grigio", null, null, null, null, null, null);
insert into directory_aziendale.DIPENDENTE values ("BHZDND52E64F784E", "Pagan", "Min", null, null, null, null, null, null);
insert into directory_aziendale.DIPENDENTE values ("SLYZMS53P67E762A", "Fiammetta", "Cicogna", null, null, null, null, null, null);
insert into directory_aziendale.DIPENDENTE values ("DFPOOU82M67G482U", "Gigi", "D'Alessio", null, null, null, null, null, null);
insert into directory_aziendale.DIPENDENTE values ("ZHNBDB29C66F457F", "Paolo", "The Second", null, null, null, null, null, null);
call cambiaMansioneDipendente("DFPOOU82M67G482U", "reclami", "Servizio Clienti");
-- call assumiDipendente("HMFMUO92S01A827B", "Diletta", "Leotta", null, null, null, null, "calcolo stipendi", "contabilità");

insert into DA_TRASFERIRE_A values ("TXHTGD97E65H851W", "reclami", "servizio clienti");
insert into DA_TRASFERIRE_A values ("LNYRYM72A08Z327C", "calcolo bilancio", "contabilità");
insert into DA_TRASFERIRE_A values ("BGNXNS34P02B229F", "calcolo bilancio", "contabilità");
insert into DA_TRASFERIRE_A values ("FQFZPK35T45L146X", "calcolo stipendi", "contabilità");
insert into DA_TRASFERIRE_A values ("BHZDND52E64F784E", "reclami", "servizio clienti");
insert into DA_TRASFERIRE_A values ("SLYZMS53P67E762A", "calcolo stipendi", "contabilità");
-- call generaReportDaTrasferire();



call ricercaDipendente("Paolo", "Bonolis");
/*call ricercaPerNumeroTelefono("2536485834");
call trovaUfficiConPostazioneVuota(null, null);
call trovaDipendentiScambiabili("ZHNBDB29C66F457F");
call scambiaDipendenti("TXHTGD97E65H851W", "LNYRYM72A08Z327C");
call assegnaDipendenteAPostazioneVuota("SLYZMS53P67E762A", "3747238924");
*/
call scambiaDipendenti("LNYRYM72A08Z327C","TXHTGD97E65H851W");
call checkDipendentiStessaMansione("BGNXNS34P02B229F", null, @a, @b);
-- call getMansioneDaPostazioneSeCorrispondeADaTrasferireA("LNYRYM72A08Z327C", "1230987654", @a, @b);
select @a, @b;
truncate TRASFERITO_A;
