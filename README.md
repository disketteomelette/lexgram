# lexgram
Analiza las notificaciones judiciales de tu bandeja de entrada, extrae los datos importantes, comprime y encripta el PDF y te lo manda a Telegram. Está preparado para notificaciones en español y siguiendo el estándar de España. Creado como un mix de bash + python para ser ejecutado como servicio en un servidor linux.

Asegúrate de instalar previamente las dependencias:
    sudo apt-get install python python3 python-pip python3-pip ghostscript poppler-utils python-imaplib2 

# Idea
La idea es tener un canal donde el usuario reciba un extracto de las notificaciones judiciales recibidas por e-mail. De esta forma, puede conocerse de un sólo vistazo las últimas notificaciones sin necesidad de buscarlas en el correo electrónico. Además proporciona distintos datos extraídos de las resoluciones, y una copia encriptada del PDF de la resolución para ser abierta directamente desde el móvil. Creé este programa en 2018 para mi tranquilidad, y lo comparto por si puede ser útil a la gente. 

La idea es colocar este script ejecutándose de manera automática en un servidor (yo uso una raspberry pi 3). También recomiendo no utilizar el correo electrónico propio, sino programar un reenvío de los e-mails recibidos en tu correo a otra dirección distinta, que sería a la que accedería Lexgram. Obviamente necesitas configurar un bot y las claves al principio del script en la parte modificable. 

No me hago responsable del uso de este script en absoluto, puede fallar, así que no confíes exclusivamente en él. Este programa está protegido por licencia Creative Commons, puedes usarlo y modificarlo libremente siempre que me incluyas en tus créditos. 

