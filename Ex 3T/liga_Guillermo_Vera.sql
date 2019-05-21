delimiter //

/* EJ 1*/
drop procedure if exists calculaPuntos//
create procedure calculaPuntos()
comment 'PA que actualiza los puntos de la tabla equipo según el resultado de los partidos. Si el equipo local gana (1 punto), si el equipo gana como visitante (2 puntos), sie el equipo pierde (0 puntos).'
begin
	declare puntosGanaLocal smallint default 1;
	declare puntosGanaVisitante smallint default 2;

	declare puntosLocal smallint(6) default 0;
	declare puntosVisitante smallint(6) default 0;
	declare equipoLocal smallint(6) default 0;
	declare equipoVisitante smallint(6) default 0;

	declare puntosPartido smallint(6) default 0;

	declare fin tinyint(1) default 0;
	declare cur1 cursor for (SELECT elocal, evisitante, resul_L, resul_V FROM partido);
	declare continue handler for not found set fin = 1;

	open cur1;

	WHILE (not fin) DO 

		fetch cur1 into equipoLocal, equipoVisitante, puntosLocal, puntosVisitante;

		IF (puntosLocal > puntosVisitante) THEN
			set puntosPartido = (select puntos from equipo where id = equipoLocal);
			insert into equipo(puntos) value (puntosPartido + puntosGanaLocal) where id = equipoLocal;
		END IF;

		IF (puntosVisitante > puntosLocal) THEN
			set puntosPartido = (select puntos from liga.equipo where id = equipoVisitante);
			insert into liga.equipo(puntos) value ((puntosPartido + puntosGanaVisitante)) where id = equipoVisitante;
		END IF;

	END WHILE;

	close cur1;
end//


/* EJ 2*/
drop function if exists ganador//
create function ganador(idFila smallint(6)) returns varchar(25) deterministic
comment 'Funcion que devuelve el ganador de un partido al pasar el id'
begin
	declare puntosLocal smallint(6) default 0;
	declare puntosVisitante smallint(6) default 0;

	set puntosLocal = (select resul_L from partido where id = idFila);
	set puntosVisitante = (select resul_V from partido where id = idFila);

	if (idFila not in (select id from partido) and idFila >= 0) then
		return 'Id no encontrado';
	end if;

	if (idFila < 0) then 
		signal sqlstate '45000' set mysql_errno = 8000, message_text = 'Marcador no válido';
	end if;

	if (puntosLocal > puntosVisitante) then
		return (select nombre from equipo where id = (select elocal from partido where id = idFila));
	end if;

	if (puntosVisitante > puntosLocal) then
		return (select nombre from equipo where id = (select evisitante from partido where id = idFila));
	end if;
end//




delimiter ;