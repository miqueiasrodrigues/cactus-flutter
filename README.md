# Cactus :cactus:
O cultivo de certos tipos de plantas exigem cuidados, pois existem plantas que são bastante sensíveis. O tempo de exposição à luz solar, a quantidade de água, e a temperatura, são elementos que se diferenciam para cada tipo de planta. A solução para quem deseja cultivar diferentes tipos de plantas em sua residência, mas não podem acompanhar o dia todo essas plantações, e para produtores locais que querem ter um maior domínio de sua cultura, para que tenham uma produção mais eficaz, rápida, sustentável e de baixo custo, foi um sistema automatizado que proporciona as condições ideias para o desenvolvimento adequado de uma determinada planta sem a necessidade do cultivador está presente no local, mas que tenha em mãos as informações de sua cultura. 

## Aplicativo Móvel :iphone:
O Cactus é uma aplicativo desenvolvido para o sistema operacional Android, construído utilizando a linguagem de programação Dart e o Framework Flutter que possibilita realizar uma conexão de forma indireta com o microcontrolador ESP32, por meio do banco de dados Firebase. A aplicação tem a função de enviar informações para o ESP32 ou coletar e mostrar as informações vindas dele, para fazer o monitoramento de uma determinada plantação.

A interface do Cactus é simples, possui um design que facilita sua utilização, com botões grandes e intuitivos. Ao iniciar o aplicativo o usuário deve fazer seu cadastro, assim
ele deve clicar em CRIAR SUA CONTA, nesta tela será solicitado que ele forneça os seus dados de cadastro, nome, e-mail, senha e uma foto (opcional). O e-mail fornecido será
usado como Identificador (ID) do usuário, dessa forma, não é possível cadastrar duas ou mais contas com o mesmo e-mail.

<img src="https://github.com/miqueiasrodrigues/Cactus/blob/main/assets/images/Tela_login.jpg" width="280"> 
<img src="https://github.com/miqueiasrodrigues/Cactus/blob/main/assets/images/Tela_cadastro.jpg" width="280">
<img src="https://github.com/miqueiasrodrigues/Cactus/blob/main/assets/images/video-2.gif" width="280">
<img src="https://github.com/miqueiasrodrigues/Cactus/blob/main/assets/images/video-1.gif" width="280">

Para fazer o cadastro de uma cultura é necessário apertar no botão verde com o símbolo (:heavy_plus_sign:), onde o aplicativo vai redirecionar para a tela de cadastro de cultura, onde é inserido as informações da plantação. Depois de ter cadastrado a plantação vai aparecer na tela de início a cultura criada, mas com a situação Desativada, pois o ESP32 ainda não configurado para fazer a conexão com essa plantação. Para fazer isso, é preciso apertar na plantação que deseja ativar, e baixar o arquivo que está em Código do arquivo. Após ter baixado o arquivo que vai fazer a configuração do ESP32 é necessário renomear o arquivo para ***conf.txt***, pois o ESP32 vai ler o arquivo com esse nome, logo depois é preciso mover esse arquivo para um micro SD e inserir no local apropriado do protótipo. Após ter realizado a conexão com o protótipo a cultura vai ser ativada automaticamente, e dessa forma o usuário vai ter acesso ao monitoramento da sua plantação.

<img src="https://github.com/miqueiasrodrigues/Cactus/blob/main/assets/images/video-3.gif" width="280">
<img src="https://github.com/miqueiasrodrigues/Cactus/blob/main/assets/images/Tela_ainda_não_recebeu_tempo_ideal.jpg" width="280">

## Sistema de Irrigação :seedling:
O sistema de irrigação automatizado que vai se conectar com o aplicativo móvel é desenvolvido utilizando o ESP32 e para sua programação, utilizou-se a linguagem de programação
C/C++ que vai possibilitar fazer a coleta e envio das informações dos sensores para o banco de dados Firebase. O sistema de irrigação não pode iniciar sem o arquivo que faz a integração com o aplicativo móvel, pois é por meio do arquivo que o sistema se conecte com a internet e valida o usuário e a cultura, para poder operar de maneira adequada, de acordo com as informações daquela plantação que o usuário previamente definiu no aplicativo.

