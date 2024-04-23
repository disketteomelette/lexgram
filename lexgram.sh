#!/bin/bash
# lexgram 1.2 by J.C.Rueda - github.com/disketteomelette
# NO ME HAGO RESPONSABLE DEL USO DE ESTA HERRAMIENTA.
# LICENCIA en https://github.com/disketteomelette/lexgram

### VARIABLES PARA EDITAR: DATOS DE CONEXIÓN Y PREFERENCIAS ###
buzon="xxxxxxxxxxxx@xxxx.com"
clave="xxxxxxxxxxxxxxx"
clavepdfmodificar="clavepdfmodificar"
clavepdfver="claveparaver"
server="imap.servidor.com"
teletoken="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
idteleuser="-xxxxxxxxxxxxxx"

### VARIABLES PARA NO EDITAR ###
blue="\e[94m"
back="\e[0m"
what="\033[1;33m"
bgreen='\033[1;32m'

### Función para obtener adjuntos de correo electrónico ###
get_attachments() {
    python - <<END
import email, getpass, imaplib, os, sys, datetime

mydate = datetime.datetime.now()
month = mydate.strftime("%b")
ano = mydate.strftime("%y")
since = '(SINCE "01-' + month + '-2018")'
detach_dir = '.'

if 'attachments' not in os.listdir(detach_dir):
    os.mkdir('attachments')

userName = '$buzon'
passwd = '$clave'

try:
    imapSession = imaplib.IMAP4_SSL('$server')
    typ, accountDetails = imapSession.login(userName, passwd)
    if typ != 'OK':
        print 'LOGIN-ERROR'
        raise
    imapSession.select('INBOX')
    typ, data = imapSession.search(None, since)
    if typ != 'OK':
        print 'INBOX-ERROR'
        raise
    for msgId in data[0].split():
        typ, messageParts = imapSession.fetch(msgId, '(RFC822)')
        if typ != 'OK':
            print 'FETCHING-ERROR'
            raise
        emailBody = messageParts[0][1]
        mail = email.message_from_string(emailBody)
        for part in mail.walk():
            if part.get_content_maintype() == 'multipart':
                continue
            if part.get('Content-Disposition') is None:
                continue
            fileName = part.get_filename()
            fileName = fileName.replace(" ", "")
            if bool(fileName):
                filePath = os.path.join(detach_dir, 'attachments', fileName)
                if not os.path.isfile(filePath):
                    fp = open(filePath, 'wb')
                    fp.write(part.get_payload(decode=True))
                    fp.close()
    imapSession.close()
    imapSession.logout()
except:
    exit
END
}

### Función para enviar mensaje de Telegram con adjunto ###
send_telegram_message_with_attachment() {
    python - <<END
import sys
import telepot

firstarg = sys.argv[1]
archivo = sys.argv[2]

bot = telepot.Bot('$teletoken')
bot.sendMessage('$idteleuser', firstarg)
bot.sendDocument('$idteleuser', open(archivo, 'rb'))
END
}

### Función para enviar mensaje de Telegram sin adjunto ###
send_telegram_message() {
    python - <<END
import sys
import telepot

firstarg = sys.argv[1]

bot = telepot.Bot('$teletoken')
bot.sendMessage('$idteleuser', firstarg, parse_mode='HTML')
END
}

### Inicio de la aplicación ###
echo -e "\n Busca · Encuentra · Analiza · Comprime · Encripta · A tu móvil!!"
echo -e " $blue█    █▄█ █ ▄ ▄██▄ ▄██▄ ████ █   █ --------------------------------------"
echo -e " $blue▐    ▐   █ █ ▐    █  ▐ ▐  ▐ ██ ██ $back[i] Lexgram v.1.2"
echo -e " $blue█    ██   █  █ ▄▄ ██▄█ █▄██ █ ▀ █ $back[~] Creado por José Carlos Rueda "
echo -e " $blue█    ▐   █ █ ▐  ▐ █ █  █  █ █   ▐ $back[▪] jcrueda.com"
echo -e " $blue██▄█ █▀█ █ █ █▀▀█ █  █ █  ▐ ▐   █ -------------------------------------- \n"
echo -e " $blue INFORMACION Y LICENCIA: github.com/disketteomelette/lexgram $back\n"
echo -e "$back[▪] Lexgram va a analizar$blue $buzon $back"

### Bucle principal ###
while true; do
    echo "[i] Revisando notificaciones..."
    get_attachments > /dev/null
    cuantas=$(wc -l < tmp)
    echo "[▪] Posibles nuevas notificaciones encontradas:$bgreen $cuantas $back"
    echo "$cuantas" > buf1

    if grep -vo "0" buf1 > /dev/null; then
        rm buf1
        echo "- Notificaciones --------------------------------------"
        cat tmp
        echo "-------------------------------------------------------"
while IFS= read -r line; do
echo "$line" > buf2
echo -e "\n[▪] Se está procesando$bgreen $line $back"
if grep -i ".pdf" buf2 > /dev/null; then
rm buf2 > /dev/null
echo -e "\n[▪] Se está extrayendo el texto del archivo $line"
pdftotext "attachments/$line" "attachments/$line.txt"
echo "[●] Reduciendo PDF para Telegram"
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -sOutputFile=attachments/optimizado.pdf attachments/$line
echo "[●] Parseando los datos interesantes"
# PARSEO DEL CONTENIDO
resolu="????"
if grep -i "providencia " "attachments/$line.txt" > /dev/null; then resolu="PROVIDENCIA"; fi
if grep -i "AUTO " "attachments/$line.txt" > /dev/null; then resolu="AUTO"; fi
if grep -i "SENTENCIA " "attachments/$line.txt" > /dev/null; then resolu="SENTENCIA"; fi
if grep -i "DILIGENCIA DE" "attachments/$line.txt" > /dev/null; then resolu="DIOR"; fi
if grep -i "DECRETO " "attachments/$line.txt" > /dev/null; then resolu="DECRETO"; fi
            recu=""
            if grep -i "reposición" "attachments/$line.txt"; then recu="Reposición~$recu"; fi
            if grep -i "apelación" "attachments/$line.txt"; then recu="Apelación~$recu"; fi
            if grep -i "súplica" "attachments/$line.txt"; then recu="Súplica~$recu"; fi
            if grep -i "suplicación" "attachments/$line.txt"; then recu="Súplica~$recu"; fi
            if grep -i "de queja" "attachments/$line.txt"; then recu="Queja~$recu"; fi
            if grep -i "casación" "attachments/$line.txt"; then recu="Casación~$recu"; fi
            if grep -i "recurso de nulidad" "attachments/$line.txt"; then recu="Nulidad~$recu"; fi
            if grep -i "reforma" "attachments/$line.txt"; then recu="Reforma~$recu"; fi
            if grep -i "de revisión" "attachments/$line.txt"; then recu="Revisión~$recu"; fi

            # PARSEO ANTIGUO
            demandante=$(grep -i "Demandante " "attachments/$line.txt" | awk "NR==1" | tr -d ",")
            demandado=$(grep -i "Demandado " "attachments/$line.txt" | awk "NR==1" | tr -d ",")
            materia=$(grep "Materia: " "attachments/$line.txt" | awk "NR==1" | cut -f2 -d":" | tr -d ",")
            de=$(grep "De: " "attachments/$line.txt" | awk "NR==1" | cut -f2 -d":" | tr -d ",")
            contra=$(grep "Contra: " "attachments/$line.txt" | awk "NR==1" | cut -f2 -d":" | tr -d ",")
            lugar=$(grep "En " "attachments/$line.txt" | awk "NR==1" | cut -f2 -d" " | tr -d ",")
            proce=$(grep "Procedimiento: " "attachments/$line.txt" | awk "NR==1" | cut -f2 -d":" | tr -d ",")
            nig=$(grep "NIG: " "attachments/$line.txt" | awk "NR==1" | cut -f2 -d" " | tr -d ",")
            audi=$(grep -i "una audiencia" "attachments/$line.txt" | tr -d ",")
            audi2=$(grep -i "audiencias" "attachments/$line.txt" | tr -d ",")
            audie=$(echo "$audi ... $audi2" | xargs)
            dias1=$(grep -i "DÍAS" "attachments/$line.txt" | tr -d ",")
            dias2=$(grep -i "días" "attachments/$line.txt" | tr -d ",")
            tota="$dias1 ... $dias2"

            if [[ $proce == *Civil* || $proce == *civil* ]]; then
                proce="Civil"
            elif [[ $proce == *Penal* || $proce == *penal* ]]; then
                proce="Penal"
            elif [[ $proce == *Mercantil* || $proce == *mercantil* ]]; then
                proce="Mercantil"
            elif [[ $proce == *Contencioso* || $proce == *contencioso* ]]; then
                proce="Contencioso"
            elif [[ $proce == *Laboral* || $proce == *laboral* ]]; then
                proce="Laboral"
            elif [[ $proce == *Administrativo* || $proce == *administrativo* ]]; then
                proce="Administrativo"
            elif [[ $proce == *Familia* || $proce == *familiar* ]]; then
                proce="Familia"
            elif [[ $proce == *Constitucional* || $proce == *constitucional* ]]; then
                proce="Constitucional"
            elif [[ $proce == *Agrario* || $proce == *agrario* ]]; then
                proce="Agrario"
            elif [[ $proce == *Laboral* || $proce == *laboral* ]]; then
                proce="Laboral"
            elif [[ $proce == *Tributario* || $proce == *tributario* ]]; then
                proce="Tributario"
            elif [[ $proce == *Insolvencia* || $proce == *insolvencia* ]]; then
                proce="Insolvencia"
            elif [[ $proce == *Seguridad* || $proce == *seguridad* ]]; then
                proce="Seguridad"
            elif [[ $proce == *Extranjería* || $proce == *extranjería* ]]; then
                proce="Extranjería"
            elif [[ $proce == *Militar* || $proce == *militar* ]]; then
                proce="Militar"
            elif [[ $proce == *Ejecución* || $proce == *ejecución* ]]; then
                proce="Ejecución"
            elif [[ $proce == *Mediación* || $proce == *mediación* ]]; then
                proce="Mediación"
            elif [[ $proce == *Arbitraje* || $proce == *arbitraje* ]]; then
                proce="Arbitraje"
            elif [[ $proce == *Bancario* || $proce == *bancario* ]]; then
                proce="Bancario"
            elif [[ $proce == *Ambiental* || $proce == *ambiental* ]]; then
                proce="Ambiental"
            elif [[ $proce == *Riesgos* || $proce == *riesgos* ]]; then
                proce="Riesgos"
            elif [[ $proce == *Intelectual* || $proce == *intelectual* ]]; then
                proce="Intelectual"
            else
                proce="Otro"
            fi

            # FIN PARSEO
            echo -e "[●] Materia: $materia"
            echo -e "[●] Procedimiento: $proce"
            echo -e "[●] NIG: $nig"
            echo -e "[●] Demandante: $demandante"
            echo -e "[●] Demandado: $demandado"
            echo -e "[●] De: $de"
            echo -e "[●] Contra: $contra"
            echo -e "[●] En: $lugar"
            echo -e "[●] Audiencia: $audie"
            echo -e "[●] Fecha de la resolución: $tota"
            echo -e "[●] Tipo de Resolución: $resolu"
            echo -e "[●] Recurso: $recu"
            # Enviar mensaje a Telegram con el texto extraído
            send_telegram_message_with_attachment "<b>Archivo PDF Analizado</b>\n\n- <b>Materia:</b> $materia\n- <b>Procedimiento:</b> $proce\n- <b>NIG:</b> $nig\n- <b>Demandante:</b> $demandante\n- <b>Demandado:</b> $demandado\n- <b>De:</b> $de\n- <b>Contra:</b> $contra\n- <b>En:</b> $lugar\n- <b>Audiencia:</b> $audie\n- <b>Fecha de la resolución:</b> $tota\n- <b>Tipo de Resolución:</b> $resolu\n- <b>Recurso:</b> $recu" "attachments/optimizado.pdf"
        else
            # Si el archivo no es un PDF, enviar solo el nombre del archivo
            send_telegram_message "<b>Archivo Adjunto:</b> $line"
        fi
    done < tmp
    echo "- - - - - - - - - - - - - - - - - - - - - - - - -"
    rm tmp
fi
echo "[▪] Esperando nuevas notificaciones..."
sleep 60
