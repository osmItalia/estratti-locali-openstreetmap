<?php
function sendMail()
{
    $subjectPrefix = '[Estratti OSM]';
    $emailTo = 'press@openstreetmap.it';

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $name    = stripslashes(trim($_POST['form-name']));
        $email   = stripslashes(trim($_POST['form-email']));
        $phone   = stripslashes(trim($_POST['form-tel']));
        $subject = 'Email di contatto';
        $message = stripslashes(trim($_POST['form-message']));
        $pattern = '/[\r\n]|Content-Type:|Bcc:|Cc:/i';
        $headers = '';
        $sendCopy= isset($_POST['form-sendCopy']);

        if (preg_match($pattern, $name) || preg_match($pattern, $email) || preg_match($pattern, $subject)) {
            die("Header injection detected");
        }

        $emailIsValid = filter_var($email, FILTER_VALIDATE_EMAIL);

        if ($name && $email && $emailIsValid && $subject && $message) {
            $subject = "$subjectPrefix $subject";
            $body = "Name: $name <br /> Email: $email <br /> Telephone: $phone <br /> Message: $message";

            $headers .= sprintf('Return-Path: %s%s', $email, PHP_EOL);
            $headers .= sprintf('From: %s%s', $email, PHP_EOL);
            $headers .= sprintf('Reply-To: %s%s', $email, PHP_EOL);
            $headers .= sprintf('Message-ID: <%s@%s>%s', md5(uniqid(rand(), true)), $_SERVER[ 'HTTP_HOST' ], PHP_EOL);
            $headers .= sprintf('X-Priority: %d%s', 3, PHP_EOL);
            $headers .= sprintf('X-Mailer: PHP/%s%s', phpversion(), PHP_EOL);
            $headers .= sprintf('Disposition-Notification-To: %s%s', $email, PHP_EOL);
            $headers .= sprintf('MIME-Version: 1.0%s', PHP_EOL);
            $headers .= sprintf('Content-Transfer-Encoding: 8bit%s', PHP_EOL);
            $headers .= sprintf('Content-Type: text/html; charset="utf-8"%s', PHP_EOL);

            mail($emailTo, "=?utf-8?B?".base64_encode($subject)."?=", $body, $headers);
            if ($sendCopy && $emailIsValid)
                mail($email, "=?utf-8?B?".base64_encode($subject)."?=", $body, $headers);
            $mailResult = true;
        } else {
            $mailResult = false;
        }
        return $mailResult;
    }
}
