<?php
declare(strict_types=1);
function queue_notification(PDO $db,?int $clientId,string $subject,string $body): void{
 $db->prepare("INSERT INTO notifications(client_id,canal,objet,contenu,statut,date_programmee) VALUES(?,'email',?,?,'a_envoyer',NOW())")->execute([$clientId,$subject,$body]);
 if(MAIL_ENABLED&&$clientId){$s=$db->prepare('SELECT email FROM clients WHERE id=?');$s->execute([$clientId]);$email=$s->fetchColumn();if($email&&filter_var($email,FILTER_VALIDATE_EMAIL))@mail($email,$subject,$body,'From: '.MAIL_FROM);}
}
