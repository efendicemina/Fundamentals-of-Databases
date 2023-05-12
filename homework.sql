--Zadatak1
--1.
select distinct pr.naziv as ResNaziv
from pravno_lice pr, fizicko_lice fz
where pr.lokacija_id=fz.lokacija_id;
--2.
select distinct to_char(ug.datum_potpisivanja,'dd.MM.yyyy') "Datum Potpisivanja", pr.naziv as ResNaziv
from ugovor_za_pravno_lice ug, pravno_lice pr
where ug.pravno_lice_id=pr.pravno_lice_id and ug.datum_potpisivanja> (select min(fak.datum_kupoprodaje) 
                                                                   from faktura fak, narudzba_proizvoda n, proizvod pro
                                                                   where fak.faktura_id=n.faktura_id 
                                                                   and pro.proizvod_id=n.proizvod_id 
                                                                   and pro.broj_mjeseci_garancije is not null);
--3.
select pr.naziv as naziv
from proizvod pr
where pr.kategorija_id in (select pro.kategorija_id 
                           from kolicina k , proizvod pro
                           where k.proizvod_id=pro.proizvod_id and 
                           (select max(kolicina_proizvoda)
                           from kolicina )= k.kolicina_proizvoda);
--4.
select pr.naziv "Proizvod", pravno.naziv  "Proizvodjac"
from proizvod pr, pravno_lice pravno, proizvodjac p
where p.proizvodjac_id=pravno.pravno_lice_id and pr.proizvodjac_id=p.proizvodjac_id 
      and p.proizvodjac_id in (select pr1.proizvodjac_id
                               from proizvod pr1
                               where pr1.cijena> (select avg(pr2.cijena) 
                                                  from proizvod pr2));
--5.
select fiz.ime ||' '|| fiz.prezime "Ime i prezime", sum(fak.iznos) "iznos"
from fizicko_lice fiz, faktura fak, uposlenik up, kupac k
where fiz.fizicko_lice_id=up.uposlenik_id and fiz.fizicko_lice_id=k.kupac_id and fak.kupac_id=k.kupac_id 
group by fiz.ime ||' '|| fiz.prezime
having sum(fak.iznos)> (select round(avg(sum(fk1.iznos)),2)
                        from fizicko_lice f1, faktura fk1
                        where f1.fizicko_lice_id=fk1.kupac_id
                        group by f1.ime, f1.prezime);
--6.
select pr.naziv  "naziv"
from pravno_lice pr, kurirska_sluzba ks, narudzba_proizvoda n, faktura fak, isporuka isp
where pr.pravno_lice_id=ks.kurirska_sluzba_id and n.faktura_id=fak.faktura_id and fak.isporuka_id=isp.isporuka_id 
and isp.kurirska_sluzba_id=ks.kurirska_sluzba_id and n.popust_id is not null
having sum(n.kolicina_jednog_proizvoda) = (select max(nesto.suma) from (select sum(n1.kolicina_jednog_proizvoda) suma
                                                                     from pravno_lice pr1, kurirska_sluzba ks1, narudzba_proizvoda n1, 
                                                                     faktura fak1, isporuka isp1
                                                                     where pr1.pravno_lice_id=ks1.kurirska_sluzba_id and n1.faktura_id=fak1.faktura_id and 
                                                                     fak1.isporuka_id=isp1.isporuka_id  and isp1.kurirska_sluzba_id=ks1.kurirska_sluzba_id 
                                                                     and n1.popust_id is not null
                                                                     group by ks1.kurirska_sluzba_id) nesto)
group by pr.naziv;
--7.
select pr.ime ||' '|| pr.prezime "Kupac", sum(n.kolicina_jednog_proizvoda*(pro.cijena*ps.postotak/100)) "Usteda"
from fizicko_lice pr, kupac kp, popust ps, narudzba_proizvoda n, faktura fak, proizvod pro
where pr.fizicko_lice_id=kp.kupac_id and  ps.popust_id=n.popust_id and fak.faktura_id=n.faktura_id and kp.kupac_id=fak.kupac_id 
and pro.proizvod_id=n.proizvod_id
group by pr.ime ||' '|| pr.prezime; 
--8.
select distinct isp.isporuka_id as idisporuke, isp.kurirska_sluzba_id as idkurirske
from isporuka isp, proizvod pro, narudzba_proizvoda n, faktura fak
where pro.proizvod_id=n.proizvod_id and fak.isporuka_id=isp.isporuka_id and n.faktura_id=fak.faktura_id 
and n.popust_id is not null and pro.broj_mjeseci_garancije is not null;
--9.
select pro.naziv as naziv, pro.cijena as cijena
from proizvod pro
where pro.cijena> (select round(avg(max(p1.cijena)),2)
                   from proizvod p1
                   group by p1.kategorija_id);
--10.
select pro.naziv as naziv, pro.cijena as cijena
from proizvod pro
where pro.cijena< all (select avg(p1.cijena)
                       from proizvod p1, kategorija kat
                       where p1.kategorija_id=kat.kategorija_id and pro.kategorija_id!=kat.nadkategorija_id
                       group by kat.kategorija_id);

--Zadatak2
create table TabelaA (id number, naziv varchar(45), datum date, cijelibroj number, realnibroj number,
                      constraint realni_a check(realnibroj> 5),
                      constraint cijeli_a check(cijelibroj not between 5 and 15),
                      constraint pk_a primary key(id));
insert into TabelaA values(1,'tekst',null,null,6.2);
insert into TabelaA values(2,null,null,3,5.26);
insert into TabelaA values(3,'tekst',null,1,null);
insert into TabelaA values(4,null,null,null,null);
insert into TabelaA values(5,'tekst',null,16,6.78);

create table TabelaB (id number, naziv varchar(45), datum date, cijelibroj number, realnibroj number, fktabelaa number not null,
                      constraint cijeli_b unique(cijelibroj),
                      constraint pk_b primary key(id),
                      constraint fk_a foreign key(fktabelaa) references TabelaA(id));
insert into TabelaB values(1,null,null,1,null,1);
insert into TabelaB values(2,null,null,3,null,1);
insert into TabelaB values(3,null,null,6,null,2);
insert into TabelaB values(4,null,null,11,null,2);
insert into TabelaB values(5,null,null,22,null,3);

create table TabelaC (id number, naziv varchar(45) not null, datum date, cijelibroj number not null, realnibroj number, fktabelab number,
                      constraint pk_c primary key (id),
                      constraint FkCnst foreign key (fktabelab) references TabelaB(id));
insert into TabelaC values(1,'YES',null,33,null,4);
insert into TabelaC values(2,'NO',null,33,null,2);
insert into TabelaC values(3,'NO',null,55,null,1);

INSERT INTO TabelaA (id,naziv,datum,cijeliBroj,realniBroj) VALUES (6,'tekst',null,null,6.20); 
--Moze se izvrsiti
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (6,null,null,1,null,1); 
--Ne moze se izvrsiti jer postoji unique constraint na cijelibroj, mora biti jedinstven, dakle 1 se ne moze ponovo unijeti
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (7,null,null,123,null,6); 
--Moze se izvrsiti
INSERT INTO TabelaC (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaB) VALUES (4,'NO',null,55,null,null);
--Moze se izvrsiti
Update TabelaA set naziv = 'tekst' Where naziv is null and cijeliBroj is not null;
--Moze se izvrsiti
Drop table tabelaB;
--Ne moze se izvrsiti jer primary key tabeleB se koristi kao foreign key u tabeliC 
Delete from TabelaA where realniBroj is null;
--Ne moze se izvrsiti, error je integrity constraint violated, ukoliko bi se izvrsilo foreign key u tabeliB ne bi vise postojao
Delete from TabelaA where id = 5;
--Moze se izvrsiti
Update TabelaB set fktabelaA = 4 where fktabelaA = 2;
--Moze se izvrsiti
Alter Table tabelaA add Constraint cst Check (naziv like 'tekst');
--Moze se izvrsiti

--Zadatak3
drop table TabelaC; drop table TabelaB; drop table TabelaA; --Brisanje tabela

create table TabelaA (id number, naziv varchar(45), datum date, cijelibroj number, realnibroj number,
                      constraint realni_a check(realnibroj> 5),
                      constraint cijeli_a check(cijelibroj not between 5 and 15),
                      constraint pk_a primary key(id));
insert into TabelaA values(1,'tekst',null,null,6.2);
insert into TabelaA values(2,null,null,3,5.26);
insert into TabelaA values(3,'tekst',null,1,null);
insert into TabelaA values(4,null,null,null,null);
insert into TabelaA values(5,'tekst',null,16,6.78); --Pravljenje TabeleA

create table TabelaB (id number, naziv varchar(45), datum date, cijelibroj number, realnibroj number, fktabelaa number not null,
                      constraint cijeli_b unique(cijelibroj),
                      constraint pk_b primary key(id),
                      constraint fk_a foreign key(fktabelaa) references TabelaA(id));
insert into TabelaB values(1,null,null,1,null,1);
insert into TabelaB values(2,null,null,3,null,1);
insert into TabelaB values(3,null,null,6,null,2);
insert into TabelaB values(4,null,null,11,null,2);
insert into TabelaB values(5,null,null,22,null,3); --Pravljenje TabeleB

create table TabelaC (id number, naziv varchar(45) not null, datum date, cijelibroj number not null, realnibroj number, fktabelab number,
                      constraint pk_c primary key (id),
                      constraint FkCnst foreign key (fktabelab) references TabelaB(id));
insert into TabelaC values(1,'YES',null,33,null,4);
insert into TabelaC values(2,'NO',null,33,null,2);
insert into TabelaC values(3,'NO',null,55,null,1); --Pravljenje TabeleC

create sequence seq1 increment by 1 start with 0 minvalue 0; --Pravljenje sekvence seq1
create sequence seq2 increment by 1 start with 0 minvalue 0; --Pravljenje sekvence seq2

create table TabelaABekap (id number, naziv varchar(45), datum date, cijelibroj number, realnibroj number, cijeliBrojB integer, sekvenca integer,
                      constraint realni_a_bekap check(realnibroj> 5),
                      constraint cijeli_a_bekap check(cijelibroj not between 5 and 15),
                      constraint pk_a_bekap primary key(id)); --Pravljenje TabeleABekap

create or replace trigger t1
after insert on TabelaB for each row declare
    pom integer := 0; begin
    select count(*) into pom from Tabelaabekap where id = :new.FkTabelaA;
    if(pom = 0) then
        insert into Tabelaabekap(id, naziv, datum, cijelibroj, realnibroj)
        (select * from Tabelaa where id = :new.FkTabelaA);
        update Tabelaabekap set cijelibrojb = :new.cijelibroj ,sekvenca = seq1.nextval where id = :new.FkTabelaA;
    else
        update Tabelaabekap set cijelibrojb = (cijelibrojb + :new.cijelibroj) ,sekvenca = seq1.nextval where id = :new.FkTabelaA;
    end if; end; --Pravljenje trigera t1

create table TabelaBCheck(sekvenca integer primary key); --Pravljenje TabeleBCheck

create or replace trigger t2 after delete on tabelab begin  insert into Tabelabcheck(sekvenca) values (seq2.nextval); end; --Pravljenje trigera t2

create or replace procedure p1( b1 in number) is s number;
    idpom number;
    b2 number := 0; begin
    select sum(cijelibroj) into s from tabelaa;
    while(b2 < s) loop
        select max(ROWNUM)+1 into idpom from tabelac;
        insert into tabelac (cijelibroj,naziv,id) values (b1,'tekst',idpom); b2:=b2+1; end loop; end p1;

INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (6,null,null,2,null,1);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (7,null,null,4,null,2);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (8,null,null,8,null,1);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (9,null,null,5,null,3);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (10,null,null,7,null,3);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (11,null,null,9,null,5);
Delete From TabelaB where id not in (select FkTabelaB from TabelaC);
Alter TABLE tabelaC drop constraint FkCnst;
Delete from TabelaB where 1=1; --Izvrsene komande
call p1(1); --Izvrsenje procedure
