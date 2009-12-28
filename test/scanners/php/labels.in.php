<?php
goto a;
echo 'Foo';
 
a:
echo 'Bar';
?>

<?php

$headers = Array('subject', 'bcc', 'to', 'cc', 'date', 'sender');
$position = 0;

hIterator: {

    $c = 0;
    echo $headers[$position] . PHP_EOL;

    cIterator: {
        echo ' ' . $headers[$position][$c] . PHP_EOL;

        if(!isset($headers[$position][++$c])) {
            goto cIteratorExit;
        }
        goto cIterator;
    }

    cIteratorExit: {
        if(isset($headers[++$position])) {
            goto hIterator;
        }
    }
}
?>