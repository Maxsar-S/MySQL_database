use social_network; 
 
-- предложение друзей исходя из общего города, общей группы или общих друзей
 drop procedure if exists friendship_offers;

delimiter //
create procedure friendship_offers(in for_user_id INT)
  begin
	
	select p2.user_id
	from profiles p1
	join profiles p2 
	    on p1.hometown = p2.hometown
	where p1.user_id = for_user_id 
	    and p2.user_id <> for_user_id 
	
		union 		
	
	select uc2.user_id
	from users_communities uc1
	join users_communities uc2 
	    on uc1.community_id = uc2.community_id
	where uc1.user_id = for_user_id 
	    and uc2.user_id <> for_user_id 
		union 
		
	select fr3.target_user_id	
	from friend_requests fr1
		join friend_requests fr2 
		    on (fr1.target_user_id = fr2.initiator_user_id 
		        or fr1.initiator_user_id = fr2.target_user_id)
		join friend_requests fr3 
		    on (fr3.target_user_id = fr2.initiator_user_id 
		        or fr3.initiator_user_id = fr2.target_user_id)
	where (fr1.initiator_user_id = for_user_id or fr1.target_user_id = for_user_id)
	 	and fr2.status = 'approved' 
	 	and fr3.status = 'approved'
		and fr3.target_user_id <> for_user_id 
	
	order by rand() -
	limit 5; 
  END// 
DELIMITER ; 

-- Подсчет популярности из соотношения заявок в друзья
DROP FUNCTION IF EXISTS func_friendship_direction;

DELIMITER // 
CREATE FUNCTION func_friendship_direction(check_user_id INT)
RETURNS FLOAT READS SQL DATA
  BEGIN

    DECLARE requests_to_user INT;
    DECLARE requests_from_user INT;
    DECLARE `_result` FLOAT;
    
    SET requests_to_user = (
    	SELECT COUNT(*) 
        FROM friend_requests
        WHERE target_user_id = check_user_id);
    
  	SELECT COUNT(*)
  	INTO requests_from_user 
	FROM friend_requests
      WHERE initiator_user_id = check_user_id;

    	if requests_from_user > 0 then 
		set `_result` = requests_to_user / requests_from_user;
	else 
		set `_result` = 99999;
	end if;


	return `_result`;

  END// 
DELIMITER ; 

-- добавления пользователя с проверкой транзакции
DROP PROCEDURE IF EXISTS `sp_add_user`;

DELIMITER $$

CREATE PROCEDURE `sp_add_user`(firstname varchar(100), lastname varchar(100), email varchar(100), phone varchar(12), hometown varchar(50), photo_id INT, OUT tran_result varchar(200))
BEGIN
    DECLARE `_rollback` BOOL DEFAULT 0;
   	DECLARE code varchar(100);
   	DECLARE error_string varchar(100);
   DECLARE last_user_id int;

   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
   begin
    	SET `_rollback` = 1;
	GET stacked DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
    	set tran_result := concat('Error occured. Code: ', code, '. Text: ', error_string);
    end;
		        
    START TRANSACTION;
		INSERT INTO users (firstname, lastname, email, phone)
		  VALUES (firstname, lastname, email, phone);
	
		INSERT INTO profiles (user_id, hometown, photo_id)
		  VALUES (last_insert_id(), hometown, photo_id); 
	
	    IF `_rollback` THEN
	       ROLLBACK;
	    ELSE
		set tran_result := 'ok';
	       COMMIT;
	    END IF;
END$$

DELIMITER ;


