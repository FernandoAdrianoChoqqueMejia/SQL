--- ############### ---
--- CREAR UNA VISTA SIMPLE
--- ############### ---
create or replace 
	view v_stats as 
		select album, 
				avg(eval) as prom,
				count(eval) as total
		from evaluacion
		group by album;

select * from v_stats;
-- insertar una nueva evaluacion
insert into evaluacion values('a', 8);

--- ############### ---
--- CREAR UNA VISTA MATERIALIZA
--- ############### ---
create materialized view m_stats as
		select album, 
				avg(eval) as prom,
				count(eval) as total
		from evaluacion
		group by album;
	
select * from m_stats;		
insert into evaluacion values('c', 4);
refresh materialized view m_stats;
select * from m_stats;	


--- ############### ---
--- CREAR UNA VISTA MATERIALIZA con un TRIGGER
--- ############### ---
create or replace function actualizarStats()
  returns trigger as
 $$
 begin 
	 refresh materialized view m_stats;
	 return new;
 end;
 $$ language plpgsql;
 
 create trigger tactualizarStats
 AFTER insert or update on evaluacion 
 for each row execute procedure actualizarStats();
--------
select * from m_stats;		
insert into evaluacion values('c', 9);
select * from m_stats;	

-------------
--- ############### ---
--- CREAR UNA TABLA Y UN TRIGGER
--- ############### ---
create table stats(
	album varchar(100),
	prom float,
	total int
);
insert into stats
  (select album, 
			avg(eval) as prom,
			count(eval) as total
	from evaluacion
	group by album);
SELECT * from stats;	

insert into evaluacion values('a', 9);
SELECT * from stats;	

create function actualizarStats2()
	returns trigger as
$$
begin
	if exists (
		select * from stats S
		where S.album = New.album)
	then 
		update stats
		set prom = R.prom, total = R.conteo
		from (
			select avg(E.eval) as prom,
			       count(E.eval) as conteo
			from evaluacion  E
			where E.album = new.album 			
		) R
		where album = new.album;
	else
		insert into stats (album, prom, total)				
			select album,
			       avg(E.eval) as prom,
				   count(E.eval) as total
			from evaluacion  E
			where E.album = new.album
			group by album;
	end if;
	return new;
end;
$$ language plpgsql;


create trigger tactualizarstats2
after insert or update on evaluacion
for each row execute procedure actualizarStats2();

select * from stats;
insert into evaluacion values('b', 8);
select * from stats;





--- ############### ---
--- CREAR UNA FUNCION ALMACENADA
--- ############### ---

create or replace function 
        estacion.get_ventas_diarias(p_mes integer, p_anio integer)
returns table(dia numeric, cantidad_venta double precision, monto_venta double precision)
as 
$$
begin return query
    select extract(day from fecha) as dia,
           sum(cantidad) as cantidad_venta, sum(montototal) as monto_venta
    from estacion.venta
    where extract(month from fecha) = p_mes and
          extract(year from fecha) = p_anio 
    group by dia;
end;
$$ language plpgsql;

select estacion.get_ventas_diarias(10, 2022);