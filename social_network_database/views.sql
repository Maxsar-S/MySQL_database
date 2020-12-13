use social_network; 

-- просмотр сообщений
CREATE or replace VIEW v_getted_messages (sender_name, sender_lastname, getting_time, message_text )
AS 
  select u.firstname, u.lastname, mes.created_at, mes.body 
  FROM users as u
    JOIN messages as mes 
    ON u.id = mes.to_user_id
;

CREATE or replace VIEW v_sent_messages (sender_name, sender_lastname, getting_time, message_text )
AS 
  select u.firstname, u.lastname, mes.created_at, mes.body 
  FROM users as u
    JOIN messages as mes 
    ON u.id = mes.from_user_id
;
-- просмотр пользователей в группе

create or replace view v_community(id, firstname, lastname, community_name) as 
select u.id, u.firstname, u.lastname, c.name
from users as u
left join user_communities as u_c
on u.id = u_c.user_id
join communities as c 
on u_c.community_id = c.id
;

-- выбор друзей пользователя

CREATE or replace VIEW v_friends
AS 
  select *
  FROM users u
    JOIN friend_requests fr ON u.id = fr.target_user_id
  WHERE 
  fr.status = 'approved'

  	union
  	
  select *
  FROM users u
    JOIN friend_requests fr ON u.id = fr.initiator_user_id
  WHERE 
  fr.status = 'approved'
;


