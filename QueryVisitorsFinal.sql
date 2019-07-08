SET @numero=0;
set @csum := 0;
INSERT INTO visitesSweden(imsi,firstseen,lastseen,diffovernight) select imsi, firstseen, lastseen, diffovernight from(
SELECT imsi, min(timestamp) as firstseen, max(timestamp) as lastseen, timestampdiff(second,min(timestamp),max(timestamp)) as diffovernight FROM (
SELECT *,@numero:=@numero+1 AS id, (@csum := @csum + flag_firstseen) as cumulative_sum FROM (
SELECT * , CASE WHEN timestampdiff(second, last_seen,
timestamp)>=86400 OR last_seen is null THEN "1" ELSE "0" END AS flag_firstseen
FROM (
  select t1.imsi as imsi, t1.timestamp as timestamp, (
    SELECT t2.timestamp
    from visitorsSweden t2
    where t2.timestamp < t1.timestamp and t1.imsi=t2.imsi
    order by t2.timestamp DESC limit 1
  ) as last_seen from visitorsSweden t1
) j
where imsi="b998fa4c11c907414951c6a302a8171cef1f267e34050302d7e7993f15562113" or
imsi="0038fa725085058220ab59a784ecd98b506b1931778b882d412f3da922abaf23" or
imsi="006bb053d66ef99370fe5d75a683c14ca490ff8f2e1650cfe2525817d5b87bd8" group by timestamp
) i
) m group by cumulative_sum
)g;

UPDATE visitesSweden as t1 INNER JOIN
(SELECT imsi, firstseen, (CASE WHEN (day(firstseen)=day(lastseen) AND hour(firstseen)<=01 AND hour(lastseen)>=05)
  THEN datediff(lastseen,firstseen) +1
  WHEN (day(firstseen)<>day(lastseen) AND hour(firstseen)>=01 AND hour(lastseen)<=05)
  THEN datediff(lastseen,firstseen) -1
  ELSE datediff(lastseen,firstseen) END) AS overnights
  FROM visitesSweden
) as t2 ON t1.imsi = t2.imsi AND t1.firstseen=t2.firstseen
SET t1.overnights = t2.overnights;

VISITES:
select count(imsi) from visitesSweden where overnights!=0;
select count(imsi) from visitesSweden where overnights=0;
select count(imsi) from visitesSweden;

VISITANTS:
select count(distinct imsi) from visitesSweden where overnights!=0;
select count(distinct imsi) from visitesSweden where overnights=0;
select count(distinct imsi) from visitesSweden;

PAIS:
select *, country
FROM visitorsSweden
RIGHT JOIN code ON visitorsSweden.mcc=code.mcc and visitorsSweden.mnc=code.mnc
RIGHT JOIN visitesSweden ON visitesSweden.imsi=visitorsSweden.imsi
group by country;

PERNOCTACIONS:
select sum(overnights)/count(imsi) from visitesSweden where overnights!=0;

GRAFICA VISITES:
select count(imsi), day(firstseen) from visitesSweden
where overnights!=0 and firstseen>=('2019-04-06') and
firstseen<('2019-04-15T23:59:59') group by day(firstseen);

select count(imsi), day(firstseen) from visitesSweden
where overnights=0 and firstseen>=('2019-04-06') and
firstseen<('2019-04-15T23:59:59') group by day(firstseen);

VISITANTS:
SET @n=0;
SET @m=0;
SET @o=0;
SET @p=0;
SET @q=0;
SET @r=0;

SELECT tu,ex,'Del 2019-04-06 al 2019-04-15' as 'periode' FROM (
SELECT *, @n:=@n+1 AS id1 FROM(
  SELECT *,count(distinct imsi) AS tu FROM visitesSweden WHERE overnights!=0 and firstseen>=("2019-04-06") and firstseen<("2019-04-15T23:59:59")
) A
) B
INNER JOIN
(
  SELECT * FROM (
  SELECT ex, @m:=@m+1 AS id2 FROM (
    SELECT count(distinct imsi) AS ex FROM visitesSweden WHERE overnights=0 and firstseen>=("2019-04-06") and firstseen<("2019-04-15T23:59:59")
  ) C)D
) F
on B.id1 = F.id2

UNION ALL

SELECT tu,ex,'Del 2019-04-16 al 2019-04-20' as 'periode' FROM (
SELECT tu, @o:=@o+1 AS id3 FROM(
  SELECT count(distinct imsi) AS tu FROM visitesSweden WHERE overnights!=0 and firstseen>=("2019-04-16") and firstseen<("2019-04-20T23:59:59")
) G
) H
INNER JOIN
(
  SELECT * FROM (
  SELECT ex, @p:=@p+1 AS id4 FROM (
    SELECT count(distinct imsi) AS ex FROM visitesSweden WHERE overnights=0 and firstseen>=("2019-04-16") and firstseen<("2019-04-20T23:59:59")
  ) I)J
) K
on H.id3 = K.id4

UNION ALL


SELECT tu,ex,'Del 2019-04-10 al 2019-04-12' as 'periode' FROM (
SELECT tu, @q:=@q+1 AS id5 FROM(
  SELECT count(distinct imsi) AS tu FROM visitesSweden WHERE overnights!=0 and firstseen>=("2019-04-10") and firstseen<("2019-04-12T23:59:59")
) G
) H
INNER JOIN
(
  SELECT * FROM (
  SELECT ex, @r:=@r+1 AS id6 FROM (
    SELECT count(distinct imsi) AS ex FROM visitesSweden WHERE overnights=0 and firstseen>=("2019-04-10") and firstseen<("2019-04-12T23:59:59")
  ) I)J
) K
on H.id5 = K.id6;


GRAFICA:
