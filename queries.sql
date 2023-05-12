--1.
SELECT Nvl(gr.naziv, 'Nema grada') AS Grad, Nvl (dr.naziv, 'Nema drzave')AS Drzava , kt.naziv AS Kontinent
FROM grad gr, drzava dr, kontinent kt
WHERE gr.drzava_id(+)=dr.drzava_id AND  kt.kontinent_id=dr.kontinent_id(+);
--2.
SELECT DISTINCT lice.naziv
FROM  ugovor_za_pravno_lice ugovor, pravno_lice lice 
WHERE datum_potpisivanja BETWEEN To_Date('2014', 'yyyy')  AND To_Date('2016', 'yyyy') AND lice.pravno_lice_id=ugovor.pravno_lice_id;
--3.
SELECT dr.naziv AS Drzava, pr.naziv AS proizvod, kt.kolicina_proizvoda AS Kolicina_proizvoda
FROM drzava dr, proizvod pr, kolicina kt, skladiste sl, lokacija lok, grad gr
WHERE dr.naziv NOT LIKE '%s%s%' AND kt.kolicina_proizvoda>50 AND sl.lokacija_id=lok.lokacija_id AND lok.grad_id=gr.grad_id AND gr.drzava_id=dr.drzava_id 
      AND kt.skladiste_id=sl.skladiste_id AND kt.proizvod_id=pr.proizvod_id;
--4.
SELECT DISTINCT pr.naziv, pr.broj_mjeseci_garancije
FROM proizvod pr, popust pp, narudzba_proizvoda n
WHERE MOD(pr.broj_mjeseci_garancije, 3)=0 AND n.proizvod_id=pr.proizvod_id AND n.popust_id=pp.popust_id ;
--5.
 SELECT fiz.ime ||' '|| fiz.prezime AS "ime i prezime", odj.naziv AS "Naziv odjela", '18896' AS Indeks
 FROM fizicko_lice fiz, odjel odj, uposlenik up, kupac kp
 WHERE odj.sef_id!=up.uposlenik_id AND fiz.fizicko_lice_id=up.uposlenik_id AND up.odjel_id=odj.odjel_id AND kp.kupac_id=up.uposlenik_id 
--6.
SELECT Nvl(pp.postotak,0) AS Postotak, (Nvl(pp.postotak,0))/100 AS PostotakRealni, npr.narudzba_id AS Narudzba_id, pr.cijena AS Cijena
FROM narudzba_proizvoda npr, proizvod pr, popust pp
WHERE Nvl(pp.postotak,0)/100*pr.cijena<200 AND npr.proizvod_id=pr.proizvod_id AND pp.popust_id(+)=npr.popust_id;
--7.
SELECT DECODE (k.kategorija_id,1,'Komp oprema',Nvl(k.naziv ,'Nema kategorije')) "Nadkategorija",nad.naziv "Kategorija"
FROM kategorija k, kategorija nad
WHERE k.kategorija_id(+)=nad.nadkategorija_id;
--8.
SELECT TO_DATE('10102020','ddmmyyyy')-ADD_MONTHS(datum_potpisivanja,TRUNC(months_between(TO_DATE('10102020','ddmmyyyy'), datum_potpisivanja) )) AS Dana
       ,TRUNC((MOD(months_between(TO_DATE('10102020','ddmmyyyy'), datum_potpisivanja),12))) AS Mjeseci,
       TRUNC(months_between(TO_DATE('10102020','ddmmyyyy'), datum_potpisivanja)/12) AS Godina
FROM ugovor_za_pravno_lice
WHERE TRUNC(months_between(TO_DATE('10.10.2020','dd.mm.yyyy'), datum_potpisivanja)/12)>TO_NUMBER(substr(ugovor_id, 1,2),'99');
--9.
SELECT DECODE(odj.naziv,'Human Resources','HUMAN','Managment','MANAGER','OTHER') AS odjel,ime AS ime, prezime AS prezime,
       odj.odjel_id AS odjel_id
FROM fizicko_lice fiz, odjel odj, uposlenik up
WHERE odj.odjel_id=up.odjel_id AND up.uposlenik_id=fiz.fizicko_lice_id
ORDER BY ime, prezime DESC;
--10.
SELECT z.Kategorija, p1.naziv AS Najjeftiniji, p2.naziv AS Najskuplji, (z.Najjeftiniji+z.Najskuplji) AS ZCijena
FROM(
SELECT kt.naziv AS Kategorija, MIN(pr.cijena) as Najjeftiniji, MAX(pr.cijena) AS Najskuplji
FROM kategorija kt, proizvod pr
WHERE kt.kategorija_id=pr.kategorija_id
group by kt.naziv) z, proizvod p1, proizvod p2
WHERE p1.cijena=z.Najjeftiniji AND p2.cijena=z.Najskuplji 
ORDER BY ZCijena ASC;
