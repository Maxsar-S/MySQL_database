use social_network; 
 
-- триггеры для logs

drop trigger if exists watchlog_users
delimiter //
create trigger watchlog_users after insert on users 
for each row 
begin 
	insert into logs (created_at, table_name, id, name)
	values (now(), 'users', new.id, new.firstname);
end //

delimiter ;

drop trigger if exists watchlog_catalogs
delimiter //
create trigger watchlog_catalogs after insert on catalogs 
for each row 
begin 
	insert into logs (created_at, table_name, id, name)
	values (now(), 'catalogs', new.id, new.firstname);
end //

delimiter ;

drop trigger if exists watchlog_products
delimiter //
create trigger watchlog_products after insert on products 
for each row 
begin 
	insert into logs (created_at, table_name, id, name)
	values (now(), 'products', new.id, new.firstname);
end //

delimiter ;


-- триггер для проверки возраста пользователя перед обновлением
DROP TRIGGER IF EXISTS check_user_age_before_update;

DELIMITER //

CREATE TRIGGER check_user_age_before_update BEFORE UPDATE ON profiles
FOR EACH ROW
begin
    IF NEW.birthday >= CURRENT_DATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Update Canceled. Birthday must be in the past!';
    END IF;
END//

DELIMITER ;


-- триггер для корректировки возраста пользователя при вставке новых строк

DROP TRIGGER IF EXISTS check_user_age_before_insert;

DELIMITER //

CREATE TRIGGER check_user_age_before_insert BEFORE INSERT ON profiles
FOR EACH ROW
begin
    IF NEW.birthday > CURRENT_DATE() THEN
        SET NEW.birthday = CURRENT_DATE();
    END IF;
END//

DELIMITER ;

