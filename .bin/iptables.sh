#!/bin/bash

# Внешний интерфейс
export WAN=eth0
export WAN_IP=x.x.x.x.
# Локальная сеть
export LAN1=eth1
export LAN1_IP_RANGE=x.x.x.x./24

# Очищаем все правила
iptables -F
iptables -F -t mangle
iptables -F -t nat
iptables -X
iptables -t nat -X
iptables -t mangle -X

# Запрещаем все, на что нет разрешения
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Разрешаем локальный интерфейс (lo) и (localhost)
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i $LAN1 -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -o $LAN1 -j ACCEPT

# Рзрешаем пинги/понг
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Разрешаем исходящие подключения
iptables -A OUTPUT -o $WAN -j ACCEPT
#iptables -A INPUT -i $WAN -j ACCEPT

# разрешаем установленные подключения
iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p all -m state --state ESTABLISHED,RELATED -j ACCEPT

# Отбрасываем неопознанные пакеты
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP

# Отбрасываем нулевые пакеты
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# Закрываемся от syn-flood атак
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
iptables -A OUTPUT -p tcp ! --syn -m state --state NEW -j DROP

# Блокируем доступ/ы с адресов ниже 
iptables -A INPUT -s 173.122.11.77 -j REJECT

# Пробрасываем порт в локалку
iptables -t nat -A PREROUTING -p tcp --dport 23543 -i ${WAN} -j DNAT --to 10.1.3.50:3368
iptables -A FORWARD -i $WAN -d 10.1.3.50 -p tcp -m tcp --dport 3368 -j ACCEPT

# Разрешаем доступ из локалки наружу
iptables -A FORWARD -i $LAN1 -o $WAN -j ACCEPT

# Заурываем доступ снаружи в локалку
iptables -A FORWARD -i $WAN -o $LAN1 -j REJECT

# Открываем доступ к web серверу
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT

# Включаем NAT
iptables -t nat -A POSTROUTING -o $WAN -s $LAN1_IP_RANGE -j MASQUERADE

# открываем доступ к SSH
iptables -A INPUT -i $WAN -p tcp --dport 22 -j ACCEPT

# Открываем доступ к почтовому серверу
iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 465 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 110 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 995 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 143 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 993 -j ACCEPT

#Открываем доступ к DNS серверу
iptables -A INPUT -i $WAN -p udp --dport 53 -j ACCEPT

# Включаем логирование
#iptables -N block_in
#iptables -N block_out
#iptables -N block_fw

#iptables -A INPUT -j block_in
#iptables -A OUTPUT -j block_out
#iptables -A FORWARD -j block_fw

#iptables -A block_in -j LOG --log-level info --log-prefix "--IN--BLOCK"
#iptables -A block_in -j DROP
#iptables -A block_out -j LOG --log-level info --log-prefix "--OUT--BLOCK"
#iptables -A block_out -j DROP
#iptables -A block_fw -j LOG --log-level info --log-prefix "--FW--BLOCK"
#iptables -A block_fw -j DROP

# Сохраняем при перезагрузке запустить правила
/sbin/iptables-save > /etc/iptables/iptables-rules
