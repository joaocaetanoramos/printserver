# Print Server · Centralize todas as impressoras legadas na sua rede

Transforme um PC velho ou um Raspberry Pi em um **hub central de impressão** para
toda a sua organização. Dê a impressoras que só falam USB um endereço de rede de
verdade, e deixe que qualquer computador — Windows, macOS, Linux — imprima nelas
pela LAN *e* pelo WiFi. Sem caça ao driver em cada máquina, sem "quem está
conectado na impressora?".

> **Impressora foi feita pra ser compartilhada. Isto é o jeito mais barato de fazer isso.**

> 🇺🇸 English? See the [`README.md`](README.md).
> A interface e os scripts seguem o idioma do sistema automaticamente
> (inglês por padrão, português do Brasil quando `LANG` é `pt_*`).

---

## Por que você quer isso

- **Sua impressora só tem USB.** Ela fica em uma mesa, e só quem está plugado
  nela imprime. Este servidor dá a ela um IP, e todo mundo imprime como se fosse
  uma impressora de rede.
- **Você lida com várias impressoras** (HP, Brother, Epson, Zebra térmica,
  genéricas chinesas). Um único servidor gerencia todas em uma interface web.
- **Compartilhamento e PDF**: imprima em pasta compartilhada, ou "imprima em PDF"
  quando só precisa do arquivo.
- **Hardware velho ainda rende.** Um PC de uma década ou um Raspberry Pi é mais
  que suficiente. Este é um servidor Debian headless e leve — sem interface, sem
  desperdício.
- **Zero caos de setup por máquina.** Os drivers moram em um lugar só. Os
  clientes só adicionam uma impressora de rede (IPP) e pronto.

---

## Recursos

| | |
|---|---|
| **Servidor CUPS/IPP** | impressão padrão da indústria, funciona em Windows/macOS/Linux, pronto p/ AirPrint |
| **Samba** | compartilhamento legado do Windows (`Adicionar impressora` via `\\servidor`) |
| **Avahi/mDNS** | impressoras são *descobertas* automaticamente na rede |
| **Raw socket (9100)** | um comando para Zebra, térmicas e genéricas — sem driver |
| **Drivers inclusos** | HP, Brother laser, Epson, térmica 58 mm, foo2zjs para clones Samsung/Xerox |
| **Localizado** | inglês por padrão; português do Brasil se o sistema for `pt_BR` |
| **Git-managed, idempotente** | instala com um comando, atualiza do mesmo jeito |

---

## O que pode rodar isso

- Qualquer PC velho (Intel/AMD, **64-bit**).
- **Raspberry Pi** e placas de baixo consumo similares (ARM).
- Distribuições baseadas em Debian. ~2 GB de armazenamento já dão um conforto.

> Este projeto instala CUPS, Avahi, Samba e UFW em um Debian mínimo.

---

## Começo rápido

Todo o servidor é provisionado com **um comando**:

```bash
sudo -i
wget -qO- https://raw.githubusercontent.com/joaocaetanoramos/printserver/main/scripts/bootstrap.sh | bash
```

O instalador:
- instala CUPS + drivers (HP, Epson, Brother laser, térmica, genéricas), Avahi, Samba, UFW;
- copia os scripts de operação, adiciona seu usuário ao `lpadmin`;
- libera as portas certas (631 CUPS, 9100 raw, 5353 Avahi, Samba);
- habilita e inicia os serviços.

Primeiro boot (manual, uma vez):
1. Instale o Debian netinst — idioma à sua escolha, hostname `printserver`, qualquer
   nome de usuário que você quiser (o instalador detecta automaticamente).
   **Não marque nenhuma seleção de pacotes.**
2. Rode o comando acima.
3. Defina um **IP fixo** com `ps-ip` (ele sugere seu IP/gateway/DNS atuais).
4. Adicione suas impressoras na interface web do CUPS — `http://IP-DO-SERVIDOR:631`.

### Adicionar impressoras

| Impressora | Como |
|---|---|
| USB | plugue → UI do CUPS → Add Printer → escolha o dispositivo USB → driver |
| Rede/IPP | UI do CUPS → "IPP / Network Printer", ou descoberta automática |
| HP | `hp-setup -i` |
| Epson | gerenciada automaticamente (escpr/gutenprint) |
| Brother laser | coberta pelo `brlaser`; jato de tinta: baixar o `.deb` da Brother |
| Zebra / térmica / genérica | sem driver — fila raw: |

```bash
ps-add-raw-printer zebra-100 192.168.1.150
lpr -P zebra-100 etiqueta.zpl
```

---

## Comandos (instalados em `/usr/local/bin/ps-*`)

| Ação | Comando |
|---|---|
| Visão geral de status | `ps-status` |
| Diagnóstico completo | `ps-check` |
| Reiniciar serviços | `ps-restart` |
| Acompanhar logs | `ps-logs` |
| Backup das configs | `ps-backup` |
| Conectar no WiFi | `ps-wifi` |
| Definir IP fixo | `ps-ip` |
| Impressora raw (Zebra/genérica) | `ps-add-raw-printer nome ip` |
| Atualizar do repositório | `ps-update` |
| Ferramentas de impressora | `lpinfo -v`, `lpstat -p`, `lpq`, `cancel -a` |

---

## Atualizações

O repositório é a fonte única de verdade. Atualizar é **idempotente** — rode de novo
e só as mudanças são aplicadas:

```bash
sudo -i
ps-update
```

O `update.sh` faz `git pull`, reaplica as configs e reinicia os serviços.
As configs são copiadas do repo a cada atualização — edite em
`/opt/printserver/configs/`, não em `/etc/...`, senão seus ajustes são sobrescritos.

---

## WiFi

```bash
sudo -i
ps-wifi                # lista as redes, escolhe uma, digita a senha
ps-wifi MinhaRede MinhaSenha  # ou conecta direto
```

O NetworkManager é instalado se preciso e fica só com o WiFi — a configuração
Ethernet de `/etc/network/interfaces` não é tocada.

Prática recomendada p/ servidor só-WiFi: mantenha DHCP, mas faça uma **reserva
DHCP** da MAC do servidor no roteador — o IP nunca muda. O `ps-ip` mostra a MAC
pra você registrar.

---

## IP fixo (`ps-ip`)

Detecta a interface ativa e oferece seu IP/gateway/DNS atuais como sugestão —
você só confirma ou ajusta:

- **Ethernet** → grava `/etc/network/interfaces` (backup em `/root/net-backup`)
  e aplica sem derrubar sua sessão SSH. Fica definitivo depois de um reboot.
- **WiFi** → aplica pelo NetworkManager (`nmcli`) e reconecta (a sessão SSH cai
  por segundos).

Nada de medo com redes alheias: isto compartilha *só impressoras*, não arquivos.

---

## Solução de problemas

| Sintoma | Correção |
|---|---|
| Impressora não é descoberta na rede | `systemctl status avahi-daemon` · `avahi-browse -rt _ipp._tcp` |
| CUPS não responde | `ss -tlnp \| grep 631` · `tail -50 /var/log/cups/error_log` |
| Windows antigo não instala via Samba | use IPP: adicionar impressora → `http://IP-DO-SERVIDOR:631/printers/NOME` |
| Firmware foo2zjs faltando (clones Samsung/Xerox) | `sudo /usr/share/doc/printer-driver-foo2zjs/getweb <modelo>` |

---

## Internacionalização

Mensagens e interface seguem o locale do sistema:

- `LANG=pt_BR.*` → **Português (Brasil)**
- qualquer outra → **Inglês** (padrão)

Sobrescreva com: `PS_LANG=pt-BR ps-ip`.

---

## Passos manuais que não dá pra automatizar

| Passo | Por quê |
|---|---|
| Instalar o Debian netinst, definir senha root | só acontece na instalação/boot |
| IP fixo (agora via `ps-ip`) | depende de cada rede |
| Adicionar as impressoras de verdade | depende de modelo/firmware (HP `hp-setup`, Brother `.deb`) |
| Zebra/térmica/genérica | fila raw via `ps-add-raw-printer` |

---

## Licença e notas

Roda em sistemas baseados em Debian; tudo o que é usado aqui (CUPS, Samba, Avahi,
UFW, os pacotes `printer-driver-*`) é livre e de código aberto.